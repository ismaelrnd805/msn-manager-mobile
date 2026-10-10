<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\MessageService;
use App\Models\Echange;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/** Communications : préparation, copie, confirmation manuelle d'envoi (spec §6.Communication, §7.5). */
final class CommunicationsController extends ApiController
{
    /** POST /communications/prepare : texte prérempli, variables manquantes signalées. */
    public function prepare(Request $request, MessageService $service): JsonResponse
    {
        $d = $request->validate([
            'modele_code' => ['nullable', 'string', 'max:60'],
            'objectif' => ['required_without:modele_code', 'nullable', 'string', 'max:120'],
            'demande_id' => ['nullable', 'uuid'],
            'commande_id' => ['nullable', 'uuid'],
            'canal' => ['nullable', 'in:messenger,facebook,whatsapp,email,telephone,presentiel,autre'],
        ]);
        $code = $d['modele_code'] ?? match ($d['objectif'] ?? '') {
            'demander_informations_manquantes' => 'DEMANDE_INFORMATIONS_MANQUANTES',
            'presenter_devis' => 'PROPOSITION_DEVIS',
            'confirmer_demarrage' => 'CONFIRMATION_DEMARRAGE',
            default => 'REPONSE_INFO_SERVICE',
        };
        $resultat = $service->prepare($code, $d['demande_id'] ?? null, $d['commande_id'] ?? null, $d['canal'] ?? null);

        return $this->ok($resultat);
    }

    /** POST /communications : enregistre un échange (brouillon/prete). */
    public function store(Request $request, MessageService $service): JsonResponse
    {
        $d = $request->validate([
            'id' => ['nullable', 'uuid'],
            'client_id' => ['required', 'uuid'],
            'demande_id' => ['nullable', 'uuid'],
            'commande_id' => ['nullable', 'uuid'],
            'modele_id' => ['nullable', 'uuid'],
            'canal' => ['required', 'in:messenger,facebook,whatsapp,email,telephone,presentiel,autre'],
            'direction' => ['required', 'in:entrant,sortant,interne'],
            'contenu' => ['required', 'string'],
            'statut_envoi' => ['sometimes', 'in:brouillon,prete'],
        ]);
        $echange = $service->enregistre($d, $request->header('X-Device-Id'), optional($request->user())->id);

        return $this->ok($echange, 201);
    }

    /** POST /communications/{id}/mark-copied : copier ≠ envoyer. */
    public function markCopied(Request $request, string $id, MessageService $service): JsonResponse
    {
        $echange = Echange::query()->whereNull('deleted_at')->findOrFail($id);
        $d = $request->validate(['version' => ['required', 'integer', 'min:1']]);
        try {
            $echange = $service->transitionEchange($echange, 'copiee', (int) $d['version'], $request->header('X-Device-Id'), optional($request->user())->id);
        } catch (\App\Domain\TransitionInvalideException $e) {
            return $this->erreur('INVALID_TRANSITION', $e->getMessage(), 409);
        }

        return $this->ok($echange);
    }

    /** POST /communications/{id}/confirm-manual-send : action explicite de l'utilisateur. */
    public function confirmManualSend(Request $request, string $id, MessageService $service): JsonResponse
    {
        $echange = Echange::query()->whereNull('deleted_at')->findOrFail($id);
        $d = $request->validate([
            'version' => ['required', 'integer', 'min:1'],
            'external_reference' => ['nullable', 'string', 'max:190'],
        ]);
        try {
            $echange = $service->transitionEchange($echange, 'envoi_manuel_confirme', (int) $d['version'], $request->header('X-Device-Id'), optional($request->user())->id);
            if (! empty($d['external_reference'])) {
                $echange->external_reference = $d['external_reference'];
                $echange->save();
            }
        } catch (\App\Domain\TransitionInvalideException $e) {
            return $this->erreur('INVALID_TRANSITION', $e->getMessage(), 409);
        }

        return $this->ok($echange);
    }

    /** GET /communications : historique paginé. */
    public function index(Request $request): JsonResponse
    {
        $q = Echange::query()->whereNull('deleted_at')->with('client');
        if ($cid = $request->query('client_id')) {
            $q->where('client_id', $cid);
        }
        if ($did = $request->query('demande_id')) {
            $q->where('demande_id', $did);
        }
        if ($st = $request->query('statut_envoi')) {
            $q->where('statut_envoi', $st);
        }
        $q->orderByDesc('created_at');

        return $this->page($request, $q);
    }
}

/** Planning éditorial Facebook : préparation et suivi — PAS de publication automatique. */
