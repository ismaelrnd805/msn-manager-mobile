<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\V1\ApiController;
use App\Domain\DemandeService;
use App\Domain\MessageService;
use App\Models\Demande;
use App\Models\Service;
use App\Models\Tarif;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/** Catalogue : services et tarifs administrables (spec module 3, §7.2). */
final class DemandesController extends ApiController
{
    public function index(Request $request): JsonResponse
    {
        $q = Demande::query()->whereNull('deleted_at')->with('client', 'prestations.service');
        if ($statut = $request->query('statut')) {
            $q->where('statut', $statut);
        }
        if ($clientId = $request->query('client_id')) {
            $q->where('client_id', $clientId);
        }
        $tris = ['created_at' => 'created_at', 'statut' => 'statut'];
        $q->orderBy($tris[$request->query('sort', 'created_at')] ?? 'created_at', 'desc');

        return $this->page($request, $q);
    }

    public function store(Request $request, DemandeService $service): JsonResponse
    {
        $d = $request->validate([
            'id' => ['nullable', 'uuid'],
            'client_id' => ['required', 'uuid'],
            'contact_id' => ['nullable', 'uuid'],
            'canal_origine' => ['required', 'in:messenger,facebook,whatsapp,email,telephone,presentiel,autre'],
            'message_initial' => ['required', 'string', 'min:1'],
            'besoin_resume' => ['nullable', 'string'],
            'date_limite_souhaitee' => ['nullable', 'date'],
            'budget_indicatif' => ['nullable', 'integer', 'min:0'],
            'prestations' => ['sometimes', 'array'],
            'prestations.*.service_id' => ['required', 'uuid'],
            'prestations.*.quantite' => ['required'],
            'prestations.*.unite_snapshot' => ['nullable', 'string', 'max:30'],
            'prestations.*.details' => ['nullable', 'array'],
        ]);
        // Le client doit exister (spec §9 règle 1)
        \App\Models\Client::query()->whereNull('deleted_at')->findOrFail($d['client_id']);

        $resultat = $service->creer($d, $d['prestations'] ?? [], $request->header('X-Device-Id'), optional($request->user())->id);
        $demande = $resultat['demande'];

        return response()->json([
            'data' => array_merge($demande->toArray(), [
                'informations_manquantes' => $service->informationsManquantes($demande),
                'prix_indicatif' => $resultat['prix_indicatif'],
            ]),
        ], 201);
    }

    public function show(string $id, DemandeService $service): JsonResponse
    {
        $demande = Demande::query()->whereNull('deleted_at')->with('prestations.service')->findOrFail($id);

        return $this->ok(array_merge($demande->toArray(), [
            'informations_manquantes' => $service->informationsManquantes($demande),
        ]));
    }

    public function update(Request $request, string $id, DemandeService $service): JsonResponse
    {
        $demande = Demande::query()->whereNull('deleted_at')->findOrFail($id);
        $d = $request->validate([
            'besoin_resume' => ['nullable', 'string'],
            'date_limite_souhaitee' => ['nullable', 'date'],
            'budget_indicatif' => ['nullable', 'integer', 'min:0'],
            'motif_perte' => ['nullable', 'string'],
            'version' => ['required', 'integer', 'min:1'],
        ]);
        $versionAttendue = (int) array_pull($d, 'version');
        if ($versionAttendue !== $demande->version) {
            return $this->erreur('VERSION_CONFLICT', 'Version obsolète.', 409, ['version_serveur' => $demande->version]);
        }
        DB::transaction(function () use ($demande, $d) {
            $avant = $demande->toArray();
            $demande->fill($d);
            $demande->version += 1;
            $demande->save();
            app(\App\Domain\AuditService::class)->journalise('demande', $demande->id, 'modification', $avant, $demande->toArray());
        });

        return $this->ok(array_merge($demande->refresh()->toArray(), [
            'informations_manquantes' => $service->informationsManquantes($demande),
        ]));
    }

    /** POST /demandes/{id}/present-offer (spec §7.2). */
    public function presenteOffre(Request $request, string $id, DemandeService $service): JsonResponse
    {
        $demande = Demande::query()->whereNull('deleted_at')->findOrFail($id);
        $d = $request->validate([
            'canal' => ['required', 'in:messenger,facebook,whatsapp,email,telephone,presentiel,autre'],
            'texte' => ['nullable', 'string'],
            'version' => ['required', 'integer', 'min:1'],
        ]);
        $resultat = $service->presenteOffre($demande, $d['canal'], $d['texte'] ?? null, $request->header('X-Device-Id'), optional($request->user())->id);

        return $this->ok([
            'demande' => $resultat['demande'],
            'echange' => $resultat['echange'],
            'informations_manquantes' => $service->informationsManquantes($resultat['demande']),
        ]);
    }

    /** POST /demandes/{id}/prepare-quote → prépare le devis depuis le catalogue actif (brouillon). */
    public function prepareQuote(Request $request, string $id, \App\Domain\DevisService $devisService): JsonResponse
    {
        $demande = Demande::query()->whereNull('deleted_at')->with('prestations.service')->findOrFail($id);
        if ($demande->prestations->isEmpty()) {
            return $this->erreur('REGLE_METIER', 'Aucune prestation à deviser pour cette demande.', 409);
        }
        $lignes = [];
        foreach ($demande->prestations as $p) {
            if ($p->prix_indicatif_unitaire === null) {
                return $this->erreur('REGLE_METIER', "Aucun tarif actif pour le service {$p->service->nom} : prix confirmé impossible tant que le périmètre n'est pas vérifié.", 409);
            }
            $lignes[] = [
                'service_id' => $p->service_id,
                'description' => $p->service->nom.' — '.$p->unite_snapshot.' × '.$p->quantite,
                'quantite' => $p->quantite,
                'unite_snapshot' => $p->unite_snapshot,
                'prix_unitaire' => $p->prix_indicatif_unitaire,
            ];
        }
        $devis = $devisService->creer($demande->id, ['lignes' => $lignes], null, $request->header('X-Device-Id'), optional($request->user())->id);

        return $this->ok($devis, 201);
    }

    /** POST /demandes/{id}/transition. */
    public function transition(Request $request, string $id, DemandeService $service): JsonResponse
    {
        $demande = Demande::query()->whereNull('deleted_at')->findOrFail($id);
        $d = $request->validate([
            'statut' => ['required', 'in:a_qualifier,offre_presentee,en_attente_client,devis_a_preparer,gagnee,perdue'],
            'motif' => ['nullable', 'string'],
            'version' => ['required', 'integer', 'min:1'],
        ]);
        try {
            $demande = $service->transition($demande, $d['statut'], (int) $d['version'], $d['motif'] ?? null, $request->header('X-Device-Id'), optional($request->user())->id);
        } catch (\App\Domain\TransitionInvalideException $e) {
            return $this->erreur('INVALID_TRANSITION', $e->getMessage(), 409);
        } catch (\App\Domain\RegleMetierException $e) {
            return $this->erreur($e->codeErreur, $e->getMessage(), 409);
        }

        return $this->ok($demande);
    }

    /** POST /demandes/{id}/qualifications : enregistre des réponses sans écraser sans trace. */
    public function qualifications(Request $request, string $id, DemandeService $service): JsonResponse
    {
        $demande = Demande::query()->whereNull('deleted_at')->findOrFail($id);
        $d = $request->validate([
            'prestation_id' => ['required', 'uuid'],
            'reponses' => ['required', 'array'],
        ]);
        $p = $service->repondreQualification($demande, $d['prestation_id'], $d['reponses'], $request->header('X-Device-Id'), optional($request->user())->id);

        return $this->ok(['prestation' => $p, 'informations_manquantes' => $service->informationsManquantes($demande->refresh())]);
    }
}
