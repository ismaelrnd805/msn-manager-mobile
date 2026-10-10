<?php

namespace App\Http\Controllers\Api\V1;

use Illuminate\Support\Str;
use App\Http\Controllers\Api\V1\ApiController;
use App\Domain\MessageService;
use App\Models\Echange;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/** Communications : préparation, copie, confirmation manuelle d'envoi (spec §6.Communication, §7.5). */
final class PublicationsFacebookController extends ApiController
{
    public function index(Request $request): JsonResponse
    {
        $q = \App\Models\PublicationFacebook::query()->whereNull('deleted_at')->orderBy('date_planifiee');
        if ($st = $request->query('statut')) {
            $q->where('statut', $st);
        }

        return $this->page($request, $q);
    }

    public function store(Request $request): JsonResponse
    {
        $d = $request->validate([
            'id' => ['nullable', 'uuid'],
            'client_id' => ['nullable', 'uuid'],
            'titre' => ['required', 'string', 'max:190'],
            'contenu' => ['required', 'string'],
            'date_planifiee' => ['required', 'date'],
            'notes' => ['nullable', 'string'],
        ]);

        return DB::transaction(function () use ($d, $request) {
            $p = \App\Models\PublicationFacebook::create($d + ['id' => $d['id'] ?? \Illuminate\Support\Str::uuid(), 'statut' => 'planifie', 'canal' => 'facebook', 'version' => 1]);
            app(\App\Domain\AuditService::class)->journalise('publication_facebook', $p->id, 'creation', null, $p->toArray(), null, $request->header('X-Device-Id'), optional($request->user())->id);

            return $this->ok($p, 201);
        });
    }

    public function update(Request $request, string $id): JsonResponse
    {
        $p = \App\Models\PublicationFacebook::query()->whereNull('deleted_at')->findOrFail($id);
        $d = $request->validate([
            'titre' => ['sometimes', 'string', 'max:190'],
            'contenu' => ['sometimes', 'string'],
            'date_planifiee' => ['sometimes', 'date'],
            'statut' => ['sometimes', 'in:planifie,prete,publie_manuellement,annule'],
            'notes' => ['nullable', 'string'],
            'version' => ['required', 'integer', 'min:1'],
        ]);
        $versionAttendue = (int) array_pull($d, 'version');
        if ($versionAttendue !== $p->version) {
            return $this->erreur('VERSION_CONFLICT', 'Version obsolète.', 409);
        }
        if (isset($d['statut']) && ! \App\Domain\Statuts::transitionAutorisee('publication_facebook', $p->statut, $d['statut'])) {
            return $this->erreur('INVALID_TRANSITION', "Transition {$p->statut} → {$d['statut']} interdite.", 409);
        }

        return DB::transaction(function () use ($p, $d, $request) {
            $avant = $p->toArray();
            $p->fill($d);
            $p->version += 1;
            if (($d['statut'] ?? null) === 'publie_manuellement') {
                $p->publie_at = now();
            }
            $p->save();
            app(\App\Domain\AuditService::class)->journalise('publication_facebook', $p->id, 'modification', $avant, $p->toArray(), null, $request->header('X-Device-Id'), optional($request->user())->id);

            return $this->ok($p);
        });
    }
}
