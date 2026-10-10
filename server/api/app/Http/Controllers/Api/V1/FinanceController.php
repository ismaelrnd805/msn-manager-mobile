<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\FactureService;
use App\Domain\PaiementService;
use App\Models\Depense;
use App\Models\Facture;
use App\Models\Paiement;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/** Factures, paiements, dépenses et synthèse financière (spec §6.H, §7.2). */
final class FinanceController extends ApiController
{
    public function indexFactures(Request $request): JsonResponse
    {
        $q = Facture::query()->whereNull('deleted_at')->with('commande', 'lignes');
        if ($statut = $request->query('statut')) {
            $q->where('statut', $statut);
        }
        $q->orderByDesc('created_at');

        return $this->page($request, $q);
    }

    public function showFacture(string $id): JsonResponse
    {
        $f = Facture::query()->whereNull('deleted_at')->with(['commande', 'lignes', 'paiements' => function ($q) {
            $q->orderBy('created_at');
        }])->findOrFail($id);
        $service = app(FactureService::class);

        return $this->ok(array_merge($f->toArray(), [
            'solde' => $service->solde($f),
            'encaisse' => (int) Paiement::query()->where('facture_id', $f->id)->where('statut', 'confirme')->whereNull('deleted_at')->sum('montant'),
        ]));
    }

    /** POST /commandes/{id}/invoice (routé ici) : facture brouillon depuis les lignes de commande. */
    public function creeDepuisCommande(Request $request, string $commandeId): JsonResponse
    {
        $c = \App\Models\Commande::query()->whereNull('deleted_at')->findOrFail($commandeId);
        $d = $request->validate(['date_echeance' => ['nullable', 'date']]);
        $facture = app(FactureService::class)->creerDepuisCommande($c, $d['date_echeance'] ?? null, $request->header('X-Device-Id'), optional($request->user())->id);

        return $this->ok($facture, 201);
    }

    /** PATCH /factures/{id} : émission ou annulation uniquement — pas d'édition libre. */
    public function updateFacture(Request $request, string $id): JsonResponse
    {
        $f = Facture::query()->whereNull('deleted_at')->findOrFail($id);
        $d = $request->validate([
            'action' => ['required', 'in:emettre,annuler'],
            'motif' => ['required_if:action,annuler', 'nullable', 'string'],
            'version' => ['required', 'integer', 'min:1'],
        ]);
        $service = app(FactureService::class);
        try {
            $f = match ($d['action']) {
                'emettre' => $service->emet($f, (int) $d['version'], $request->header('X-Device-Id'), optional($request->user())->id),
                'annuler' => $service->annule($f, (string) $d['motif'], (int) $d['version'], $request->header('X-Device-Id'), optional($request->user())->id),
            };
        } catch (\App\Domain\RegleMetierException $e) {
            return $this->erreur($e->codeErreur, $e->getMessage(), 409);
        } catch (\App\Domain\ConflitVersionException $e) {
            return $this->erreur('VERSION_CONFLICT', $e->getMessage(), 409, ['version_serveur' => $e->versionServeur]);
        }

        return $this->ok($f);
    }

    /** POST /factures/{id}/rectify : rectification auditable (motif obligatoire). */
    public function rectifie(Request $request, string $id): JsonResponse
    {
        $f = Facture::query()->whereNull('deleted_at')->findOrFail($id);
        $d = $request->validate([
            'motif' => ['required', 'string', 'min:3'],
            'lignes' => ['required', 'array', 'min:1'],
            'lignes.*.description' => ['required', 'string'],
            'lignes.*.quantite' => ['required'],
            'lignes.*.prix_unitaire' => ['required', 'integer', 'min:0'],
            'version' => ['required', 'integer', 'min:1'],
        ]);
        try {
            $f = app(FactureService::class)->rectifie($f, $d['motif'], $d['lignes'], (int) $d['version'], $request->header('X-Device-Id'), optional($request->user())->id);
        } catch (\App\Domain\RegleMetierException $e) {
            return $this->erreur($e->codeErreur, $e->getMessage(), 409);
        }

        return $this->ok($f);
    }

    /** POST /factures/{id}/payments (spec §7.2). */
    public function ajoutePaiement(Request $request, string $id, PaiementService $service): JsonResponse
    {
        $f = Facture::query()->whereNull('deleted_at')->findOrFail($id);
        $d = $request->validate([
            'montant' => ['required', 'integer', 'min:1'],
            'moyen' => ['required', 'in:especes,mobile_money,virement,autre'],
            'date_paiement' => ['nullable', 'date'],
            'reference' => ['nullable', 'string', 'max:120'],
            'statut' => ['sometimes', 'in:en_attente,confirme'],
            'notes' => ['nullable', 'string'],
            'idempotency_key' => ['required', 'string', 'max:64'],
        ]);
        try {
            $resultat = $service->enregistrer($f, $d, $request->header('X-Device-Id'), optional($request->user())->id);
        } catch (\App\Domain\RegleMetierException $e) {
            return $this->erreur($e->codeErreur, $e->getMessage(), 409);
        }

        return response()->json([
            'data' => ['paiement' => $resultat['paiement'], 'facture' => $resultat['facture']],
            'idempotent' => $resultat['idempotent'],
        ], $resultat['idempotent'] ? 200 : 201);
    }

    /** PATCH /payments/{id} : confirmation ou annulation explicite. */
    public function updatePaiement(Request $request, string $id, PaiementService $service): JsonResponse
    {
        $p = Paiement::query()->whereNull('deleted_at')->findOrFail($id);
        $d = $request->validate([
            'action' => ['required', 'in:confirmer,annuler'],
            'motif' => ['required_if:action,annuler', 'nullable', 'string'],
            'version' => ['required', 'integer', 'min:1'],
        ]);
        try {
            $p = match ($d['action']) {
                'confirmer' => $service->confirme($p, (int) $d['version'], $request->header('X-Device-Id'), optional($request->user())->id),
                'annuler' => $service->annule($p, (string) $d['motif'], (int) $d['version'], $request->header('X-Device-Id'), optional($request->user())->id),
            };
        } catch (\App\Domain\TransitionInvalideException $e) {
            return $this->erreur('INVALID_TRANSITION', $e->getMessage(), 409);
        } catch (\App\Domain\ConflitVersionException $e) {
            return $this->erreur('VERSION_CONFLICT', $e->getMessage(), 409);
        }

        return $this->ok($p);
    }

    /** GET /finance/summary (spec §7.2). */
    public function synthese(Request $request): JsonResponse
    {
        return $this->ok(app(FactureService::class)->synthese($request->query('depuis'), $request->query('jusqu_a')));
    }

    /** GET|POST /depenses. */
    public function indexDepenses(Request $request): JsonResponse
    {
        $q = Depense::query()->whereNull('deleted_at')->orderByDesc('date_depense');

        return $this->page($request, $q);
    }

    public function storeDepense(Request $request): JsonResponse
    {
        $d = $request->validate([
            'id' => ['nullable', 'uuid'],
            'date_depense' => ['required', 'date'],
            'categorie' => ['required', 'string', 'max:60'],
            'description' => ['required', 'string'],
            'montant' => ['required', 'integer', 'min:1'],
            'moyen' => ['required', 'in:especes,mobile_money,virement,autre'],
            'reference' => ['nullable', 'string', 'max:120'],
        ]);

        return DB::transaction(function () use ($d, $request) {
            $dep = Depense::create($d + ['id' => $d['id'] ?? \Illuminate\Support\Str::uuid(), 'devise' => 'MGA', 'version' => 1]);
            app(\App\Domain\AuditService::class)->journalise('depense', $dep->id, 'creation', null, $dep->toArray(), null, $request->header('X-Device-Id'), optional($request->user())->id);

            return $this->ok($dep, 201);
        });
    }
}
