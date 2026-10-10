<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\AuditService;
use App\Domain\SyncService;
use App\Models\Appareil;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

/** Synchronisation (spec §8) : push, pull, statut + pièces jointes séparées. */
final class SyncController extends ApiController
{
    /** POST /sync/push — lot borné, réponse opération par opération. */
    public function push(Request $request, SyncService $service): JsonResponse
    {
        $d = $request->validate([
            'operations' => ['required', 'array', 'max:100'],
            'operations.*.operation_id' => ['required', 'uuid'],
            'operations.*.entity_type' => ['required', 'string', 'max:60'],
            'operations.*.entity_id' => ['required', 'uuid'],
            'operations.*.operation' => ['required', 'in:upsert,delete'],
            'operations.*.base_version' => ['nullable', 'integer', 'min:1'],
            'operations.*.payload' => ['required', 'array'],
            'operations.*.idempotency_key' => ['required', 'string', 'max:64'],
            'operations.*.client_timestamp' => ['nullable', 'date'],
        ]);

        $appareil = $this->appareilCourant($request);
        try {
            $resultats = $service->push($d['operations'], $appareil->id, optional($request->user())->id);
        } catch (\App\Domain\RegleMetierException $e) {
            return $this->erreur($e->codeErreur, $e->getMessage(), 409);
        }

        // Marque l'appareil comme actif
        $appareil->dernier_sync_at = now();
        $appareil->save();

        return $this->ok(['resultats' => $resultats]);
    }

    /** GET /sync/pull?cursor=...&limit=... — séquence monotone, lot borné. */
    public function pull(Request $request, SyncService $service): JsonResponse
    {
        $d = $request->validate([
            'cursor' => ['nullable', 'integer', 'min:0'],
            'limit' => ['nullable', 'integer', 'min:1', 'max:500'],
        ]);
        $appareil = $this->appareilCourant($request);
        $appareil->dernier_sync_at = now();
        $appareil->save();

        return $this->ok($service->pull($d['cursor'] ?? '0', (int) ($d['limit'] ?? 100)));
    }

    /** GET /sync/status — état : opérations en attente côté serveur, dernière sync par appareil. */
    public function status(Request $request): JsonResponse
    {
        $appareils = Appareil::query()->where('user_id', $request->user()->id)->orderBy('created_at')->get();

        return $this->ok([
            'appareils' => $appareils->map(fn ($a) => [
                'id' => $a->id, 'nom' => $a->nom, 'plateforme' => $a->plateforme,
                'actif' => $a->actif, 'dernier_sync_at' => $a->dernier_sync_at?->toIso8601String(),
            ]),
            'journal_seq_courante' => (int) (DB::table('sync_journal')->max('seq') ?? 0),
            'operations_traitees' => (int) DB::table('sync_push_log')->count(),
        ]);
    }

    /** L'appareil est identifié par son jeton (nom = access-<device_id>) ou l'en-tête X-Device-Id. */
    private function appareilCourant(Request $request): Appareil
    {
        $deviceId = $request->header('X-Device-Id');
        if ($deviceId) {
            return Appareil::query()->where('id', $deviceId)->where('user_id', $request->user()->id)->firstOrFail();
        }
        $jeton = $request->user()->currentAccessToken();
        $deviceId = $jeton ? str($jeton->name)->after('access-')->toString() : null;
        if ($deviceId) {
            $a = Appareil::query()->where('id', $deviceId)->first();
            if ($a) {
                return $a;
            }
        }
        throw new \Illuminate\Auth\Access\AuthorizationException('Appareil non identifié : fournissez X-Device-Id.');
    }
}

/** Pièces jointes : sessions de transfert, contenu, complétion SHA-256 (spec §8.2, §9 fichiers). */
