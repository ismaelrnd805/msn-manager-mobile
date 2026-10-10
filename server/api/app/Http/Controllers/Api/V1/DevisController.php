<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\DevisService;
use App\Models\Devis;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/** Devis (spec §6.E, §7.2) : présentation, modification (révisions), acceptation → commande. */
final class DevisController extends ApiController
{
    public function index(Request $request): JsonResponse
    {
        $q = Devis::query()->whereNull('deleted_at')->with('lignes', 'demande.client');
        if ($statut = $request->query('statut')) {
            $q->where('statut', $statut);
        }
        if ($did = $request->query('demande_id')) {
            $q->where('demande_id', $did);
        }
        $q->orderByDesc('created_at');

        return $this->page($request, $q);
    }

    public function show(string $id): JsonResponse
    {
        return $this->ok(Devis::query()->whereNull('deleted_at')->with('lignes', 'demande', 'commande')->findOrFail($id));
    }

    public function store(Request $request, DevisService $service): JsonResponse
    {
        $d = $request->validate([
            'demande_id' => ['required', 'uuid'],
            'lignes' => ['required', 'array', 'min:1'],
            'lignes.*.description' => ['required', 'string'],
            'lignes.*.quantite' => ['required'],
            'lignes.*.prix_unitaire' => ['required', 'integer', 'min:0'],
            'lignes.*.service_id' => ['nullable', 'uuid'],
            'lignes.*.unite_snapshot' => ['nullable', 'string', 'max:30'],
            'conditions' => ['nullable', 'string'],
            'date_validite' => ['nullable', 'date'],
        ]);

        $devis = $service->creer($d['demande_id'], $d, null, $request->header('X-Device-Id'), optional($request->user())->id);

        return $this->ok($devis, 201);
    }

    /** POST /devis/{id}/present */
    public function presente(Request $request, string $id, DevisService $service): JsonResponse
    {
        $devis = Devis::query()->whereNull('deleted_at')->findOrFail($id);
        $d = $request->validate(['version' => ['required', 'integer', 'min:1']]);
        try {
            $devis = $service->presente($devis, (int) $d['version'], $request->header('X-Device-Id'), optional($request->user())->id);
        } catch (\App\Domain\RegleMetierException $e) {
            return $this->erreur($e->codeErreur, $e->getMessage(), 409);
        } catch (\App\Domain\ConflitVersionException $e) {
            return $this->erreur('VERSION_CONFLICT', $e->getMessage(), 409, ['version_serveur' => $e->versionServeur, 'etat_serveur' => $e->etatServeur]);
        }

        return $this->ok($devis);
    }

    /**
     * POST /devis/{id}/accept
     * body: { version, confirmee: true, cle_idempotence }
     * Crée la commande de façon ATOMIQUE et IDEMPOTENTE (spec §6.F, §10.16).
     */
    public function accepte(Request $request, string $id, DevisService $service): JsonResponse
    {
        $devis = Devis::query()->whereNull('deleted_at')->findOrFail($id);
        $d = $request->validate([
            'version' => ['required', 'integer', 'min:1'],
            'confirmee' => ['sometimes', 'boolean'],
            'cle_idempotence' => ['required', 'string', 'max:64'],
        ]);
        try {
            $resultat = $service->accepte(
                $devis,
                (int) $d['version'],
                $d['confirmee'] ?? true,
                $d['cle_idempotence'],
                $request->header('X-Device-Id'),
                optional($request->user())->id,
            );
        } catch (\App\Domain\TransitionInvalideException $e) {
            return $this->erreur('INVALID_TRANSITION', $e->getMessage(), 409);
        } catch (\App\Domain\RegleMetierException $e) {
            return $this->erreur($e->codeErreur, $e->getMessage(), 409);
        } catch (\App\Domain\ConflitVersionException $e) {
            return $this->erreur('VERSION_CONFLICT', $e->getMessage(), 409, ['version_serveur' => $e->versionServeur, 'etat_serveur' => $e->etatServeur]);
        }

        return $this->ok([
            'devis' => $resultat['devis'],
            'commande' => $resultat['commande'],
            'idempotent' => $resultat['idempotent'],
        ]);
    }

    /** POST /devis/{id}/request-change */
    public function demandeModification(Request $request, string $id, DevisService $service): JsonResponse
    {
        $devis = Devis::query()->whereNull('deleted_at')->findOrFail($id);
        $d = $request->validate([
            'motif' => ['required', 'string', 'min:3'],
            'version' => ['required', 'integer', 'min:1'],
        ]);
        try {
            $devis = $service->demandeModification($devis, $d['motif'], (int) $d['version'], $request->header('X-Device-Id'), optional($request->user())->id);
        } catch (\App\Domain\ConflitVersionException $e) {
            return $this->erreur('VERSION_CONFLICT', $e->getMessage(), 409);
        }

        return $this->ok($devis);
    }

    /** POST /devis/{id}/reject */
    public function refuse(Request $request, string $id, DevisService $service): JsonResponse
    {
        $devis = Devis::query()->whereNull('deleted_at')->findOrFail($id);
        $d = $request->validate([
            'motif' => ['nullable', 'string'],
            'version' => ['required', 'integer', 'min:1'],
        ]);
        try {
            $devis = $service->refuse($devis, $d['motif'] ?? null, (int) $d['version'], $request->header('X-Device-Id'), optional($request->user())->id);
        } catch (\App\Domain\TransitionInvalideException $e) {
            return $this->erreur('INVALID_TRANSITION', $e->getMessage(), 409);
        } catch (\App\Domain\ConflitVersionException $e) {
            return $this->erreur('VERSION_CONFLICT', $e->getMessage(), 409);
        }

        return $this->ok($devis);
    }

    /** POST /devis/{id}/revise : nouvelle révision (ne détruit jamais l'historique). */
    public function revise(Request $request, string $id, DevisService $service): JsonResponse
    {
        $ancien = Devis::query()->whereNull('deleted_at')->findOrFail($id);
        $d = $request->validate([
            'lignes' => ['required', 'array', 'min:1'],
            'lignes.*.description' => ['required', 'string'],
            'lignes.*.quantite' => ['required'],
            'lignes.*.prix_unitaire' => ['required', 'integer', 'min:0'],
            'lignes.*.service_id' => ['nullable', 'uuid'],
            'lignes.*.unite_snapshot' => ['nullable', 'string', 'max:30'],
        ]);
        $devis = $service->nouvelleRevision($ancien, $d['lignes'], $request->header('X-Device-Id'), optional($request->user())->id);

        return $this->ok($devis, 201);
    }
}
