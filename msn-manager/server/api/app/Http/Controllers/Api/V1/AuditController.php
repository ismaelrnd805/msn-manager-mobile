<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Api\V1\ApiController;
use App\Domain\AuditService;
use App\Domain\SyncService;
use App\Models\Appareil;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

/** Synchronisation (spec §8) : push, pull, statut + pièces jointes séparées. */
final class AuditController extends ApiController
{
    public function __construct(private readonly AuditService $audit) {}

    /** GET /audit?entity_type=...&entity_id=... (spec §7.2). */
    public function index(Request $request): JsonResponse
    {
        $d = $request->validate([
            'entity_type' => ['nullable', 'string', 'max:60'],
            'entity_id' => ['nullable', 'uuid'],
        ]);
        $q = \App\Models\JournalAction::query()->orderBy('date_action');
        if (! empty($d['entity_type'])) {
            $q->where('entite_type', $d['entity_type']);
        }
        if (! empty($d['entity_id'])) {
            $q->where('entite_id', $d['entity_id']);
        }

        return $this->page($request, $q, 200);
    }

    public function historiqueClient(string $clientId): JsonResponse
    {
        return $this->ok(['evenements' => $this->audit->historique('client', $clientId)]);
    }
}
