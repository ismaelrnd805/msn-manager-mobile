<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\CommandeService;
use App\Models\Commande;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/** Commandes (spec §6.F-G, §7.2/§7.4) : création exceptionnelle, transitions, projets, livraison, tâches. */
final class CommandesController extends ApiController
{
    public function index(Request $request): JsonResponse
    {
        $q = Commande::query()->whereNull('deleted_at')->with('lignes', 'projets', 'demande.client');
        if ($statut = $request->query('statut')) {
            $q->where('statut', $statut);
        }
        $q->orderByDesc('created_at');

        return $this->page($request, $q);
    }

    public function show(string $id): JsonResponse
    {
        $c = Commande::query()->whereNull('deleted_at')->with(['lignes', 'projets', 'taches', 'demande.client', 'facture.paiements'])->findOrFail($id);

        return $this->ok(array_merge($c->toArray(), [
            'actions_autorisees' => $this->actionsAutorisees($c),
            'total_lignes' => $c->lignes->sum(fn ($l) => (int) round((float) $l->quantite * (int) $l->prix_unitaire)),
        ]));
    }

    /** Transitions autorisées depuis l'état courant (affichage UI + contrôle serveur). */
    private function actionsAutorisees(Commande $c): array
    {
        $toutes = ['en_attente_validation', 'validee', 'en_production', 'en_correction', 'livree', 'annulee'];

        return array_values(array_filter($toutes, fn ($vers) => \App\Domain\Statuts::transitionAutorisee('commande', $c->statut, $vers)));
    }

    /** POST /commandes : exception documentée (devis accepté requis + idempotence). */
    public function store(Request $request, CommandeService $service): JsonResponse
    {
        $d = $request->validate([
            'demande_id' => ['required', 'uuid'],
            'devis_accepte_id' => ['required', 'uuid'],
            'cle_idempotence' => ['required', 'string', 'max:64'],
        ]);
        try {
            $commande = $service->creer($d['demande_id'], $d['devis_accepte_id'], $d['cle_idempotence'], $request->header('X-Device-Id'), optional($request->user())->id);
        } catch (\App\Domain\RegleMetierException $e) {
            return $this->erreur($e->codeErreur, $e->getMessage(), 409);
        }

        return $this->ok($commande, 201);
    }

    /** POST /commandes/{id}/transition (spec §7.4). */
    public function transition(Request $request, string $id, CommandeService $service): JsonResponse
    {
        $c = Commande::query()->whereNull('deleted_at')->findOrFail($id);
        $d = $request->validate([
            'transition' => ['required', 'in:en_preparation,en_attente_validation,validee,en_production,en_correction,livree,annulee'],
            'expected_version' => ['required', 'integer', 'min:1'],
            'motif' => ['nullable', 'string'],
        ]);
        try {
            $c = $service->transition($c, $d['transition'], (int) $d['expected_version'], $d['motif'] ?? null, $request->header('X-Device-Id'), optional($request->user())->id);
        } catch (\App\Domain\TransitionInvalideException $e) {
            return $this->erreur('INVALID_TRANSITION', $e->getMessage(), 409);
        } catch (\App\Domain\RegleMetierException $e) {
            return $this->erreur($e->codeErreur, $e->getMessage(), 409);
        } catch (\App\Domain\ConflitVersionException $e) {
            return $this->erreur('VERSION_CONFLICT', $e->getMessage(), 409, ['version_serveur' => $e->versionServeur, 'etat_serveur' => $e->etatServeur]);
        }

        return $this->ok($c);
    }

    /** POST /commandes/{id}/projects — plusieurs projets par commande (spec §10.17). */
    public function ajouteProjet(Request $request, string $id, CommandeService $service): JsonResponse
    {
        $c = Commande::query()->whereNull('deleted_at')->findOrFail($id);
        $d = $request->validate([
            'nom' => ['required', 'string', 'max:190'],
            'description' => ['nullable', 'string'],
            'date_limite' => ['nullable', 'date'],
        ]);
        $projet = $service->ajouteProjet($c, $d, $request->header('X-Device-Id'), optional($request->user())->id);

        return $this->ok($projet, 201);
    }

    /** POST /commandes/{id}/delivery — livraison obligatoire avant « livrée » (spec §10.19). */
    public function livraison(Request $request, string $id, CommandeService $service): JsonResponse
    {
        $c = Commande::query()->whereNull('deleted_at')->findOrFail($id);
        $d = $request->validate([
            'description' => ['nullable', 'string'],
            'pieces_jointes_ids' => ['sometimes', 'array'],
            'pieces_jointes_ids.*' => ['uuid'],
            'date_livraison' => ['nullable', 'date'],
            'expected_version' => ['required', 'integer', 'min:1'],
        ]);
        try {
            $c = $service->livre($c, $d['description'] ?? '', (int) $d['expected_version'], $d['pieces_jointes_ids'] ?? [], $d['date_livraison'] ?? null, $request->header('X-Device-Id'), optional($request->user())->id);
        } catch (\App\Domain\TransitionInvalideException $e) {
            return $this->erreur('INVALID_TRANSITION', $e->getMessage(), 409);
        } catch (\App\Domain\RegleMetierException $e) {
            return $this->erreur($e->codeErreur, $e->getMessage(), 409);
        } catch (\App\Domain\ConflitVersionException $e) {
            return $this->erreur('VERSION_CONFLICT', $e->getMessage(), 409, ['version_serveur' => $e->versionServeur]);
        }

        return $this->ok($c);
    }

    /** POST /commandes/{id}/tasks. */
    public function ajouteTache(Request $request, string $id, CommandeService $service): JsonResponse
    {
        $c = Commande::query()->whereNull('deleted_at')->findOrFail($id);
        $d = $request->validate([
            'titre' => ['required', 'string', 'max:190'],
            'description' => ['nullable', 'string'],
            'priorite' => ['sometimes', 'in:basse,normale,haute,urgente'],
            'echeance' => ['nullable', 'date'],
            'projet_id' => ['nullable', 'uuid'],
        ]);
        $tache = $service->ajouteTache($c, $d, $request->header('X-Device-Id'), optional($request->user())->id);

        return $this->ok($tache, 201);
    }

    /** PATCH /tasks/{taskId} : transition de tâche. */
    public function transitionTache(Request $request, string $taskId, CommandeService $service): JsonResponse
    {
        $tache = \App\Models\Tache::query()->whereNull('deleted_at')->findOrFail($taskId);
        $d = $request->validate([
            'statut' => ['required', 'in:a_faire,en_cours,bloquee,terminee,annulee'],
            'version' => ['required', 'integer', 'min:1'],
        ]);
        try {
            $tache = $service->transitionTache($tache, $d['statut'], (int) $d['version'], $request->header('X-Device-Id'), optional($request->user())->id);
        } catch (\App\Domain\TransitionInvalideException $e) {
            return $this->erreur('INVALID_TRANSITION', $e->getMessage(), 409);
        } catch (\App\Domain\ConflitVersionException $e) {
            return $this->erreur('VERSION_CONFLICT', $e->getMessage(), 409);
        }

        return $this->ok($tache);
    }

    /** POST /commandes/{id}/lignes : ligne supplémentaire (prix figé). */
    public function ajouteLigne(Request $request, string $id, CommandeService $service): JsonResponse
    {
        $c = Commande::query()->whereNull('deleted_at')->findOrFail($id);
        $d = $request->validate([
            'description' => ['required', 'string'],
            'quantite' => ['required'],
            'prix_unitaire' => ['required', 'integer', 'min:0'],
            'service_id' => ['nullable', 'uuid'],
            'unite_snapshot' => ['nullable', 'string', 'max:30'],
        ]);
        $ligne = $service->ajouteLigne($c, $d, $request->header('X-Device-Id'), optional($request->user())->id);

        return $this->ok($ligne, 201);
    }
}
