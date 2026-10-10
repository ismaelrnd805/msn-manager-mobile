<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\DemandeService;
use App\Domain\MessageService;
use App\Models\Demande;
use App\Models\Service;
use App\Models\Tarif;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/** Catalogue : services et tarifs administrables (spec module 3, §7.2). */
final class CatalogueController extends ApiController
{
    public function servicesIndex(Request $request): JsonResponse
    {
        $q = Service::query()->whereNull('deleted_at');
        if (! $request->boolean('inclure_inactifs')) {
            $q->where('actif', true);
        }
        if ($cat = $request->query('categorie')) {
            $q->where('categorie', $cat);
        }

        return $this->page($request, $q);
    }

    public function servicesStore(Request $request): JsonResponse
    {
        $d = $request->validate([
            'id' => ['nullable', 'uuid'],
            'code' => ['required', 'string', 'max:40', 'unique:services,code'],
            'nom' => ['required', 'string', 'max:190'],
            'description' => ['nullable', 'string'],
            'categorie' => ['required', 'string', 'max:60'],
            'unite_tarifaire' => ['required', 'string', 'max:30'],
            'actif' => ['sometimes', 'boolean'],
            'necessite_cahier_charges' => ['sometimes', 'boolean'],
            'questions_qualification_json' => ['sometimes', 'array'],
        ]);

        return DB::transaction(function () use ($d) {
            $s = Service::create($d + ['version' => 1]);
            app(\App\Domain\AuditService::class)->journalise('service', $s->id, 'creation', null, $s->toArray());

            return $this->ok($s, 201);
        });
    }

    public function servicesShow(string $id): JsonResponse
    {
        $s = Service::query()->whereNull('deleted_at')->with('tarifs')->findOrFail($id);

        return $this->ok($s);
    }

    public function servicesUpdate(Request $request, string $id): JsonResponse
    {
        $s = Service::query()->whereNull('deleted_at')->findOrFail($id);
        $d = $request->validate([
            'nom' => ['sometimes', 'string', 'max:190'],
            'description' => ['nullable', 'string'],
            'categorie' => ['sometimes', 'string', 'max:60'],
            'unite_tarifaire' => ['sometimes', 'string', 'max:30'],
            'actif' => ['sometimes', 'boolean'],
            'necessite_cahier_charges' => ['sometimes', 'boolean'],
            'questions_qualification_json' => ['sometimes', 'array'],
            'version' => ['required', 'integer', 'min:1'],
        ]);
        $versionAttendue = (int) array_pull($d, 'version');
        if ($versionAttendue !== $s->version) {
            return $this->erreur('VERSION_CONFLICT', 'Version obsolète.', 409, ['version_serveur' => $s->version]);
        }

        return DB::transaction(function () use ($s, $d) {
            $avant = $s->toArray();
            $s->fill($d);
            $s->version += 1;
            $s->save();
            app(\App\Domain\AuditService::class)->journalise('service', $s->id, 'modification', $avant, $s->toArray());

            return $this->ok($s);
        });
    }

    public function tarifsIndex(Request $request): JsonResponse
    {
        $q = Tarif::query()->whereNull('deleted_at')->with('service');
        if ($sid = $request->query('service_id')) {
            $q->where('service_id', $sid);
        }
        if ($request->boolean('actifs_seulement', true)) {
            $aujourdhui = now()->toDateString();
            $q->where('actif', true)
                ->where('date_debut_validite', '<=', $aujourdhui)
                ->where(fn ($qq) => $qq->whereNull('date_fin_validite')->orWhere('date_fin_validite', '>=', $aujourdhui));
        }

        return $this->page($request, $q);
    }

    public function tarifsStore(Request $request): JsonResponse
    {
        $d = $request->validate([
            'id' => ['nullable', 'uuid'],
            'service_id' => ['required', 'uuid'],
            'prix_unitaire' => ['required', 'integer', 'min:0'],
            'date_debut_validite' => ['required', 'date'],
            'date_fin_validite' => ['nullable', 'date', 'after_or_equal:date_debut_validite'],
        ]);
        Service::query()->whereNull('deleted_at')->findOrFail($d['service_id']);

        return DB::transaction(function () use ($d) {
            // Ferme le tarif courant (historique conservé, anciens devis intacts)
            $aujourdhui = now()->toDateString();
            Tarif::query()
                ->where('service_id', $d['service_id'])
                ->whereNull('date_fin_validite')
                ->whereNull('deleted_at')
                ->update(['date_fin_validite' => $aujourdhui, 'version' => DB::raw('version + 1')]);
            $t = Tarif::create($d + ['devise' => 'MGA', 'actif' => true, 'version' => 1]);
            app(\App\Domain\AuditService::class)->journalise('tarif', $t->id, 'creation', null, $t->toArray());

            return $this->ok($t, 201);
        });
    }

    public function templatesIndex(Request $request): JsonResponse
    {
        $q = \App\Models\ModeleMessage::query()->whereNull('deleted_at');

        return $this->page($request, $q);
    }

    public function templatesStore(Request $request): JsonResponse
    {
        $d = $request->validate([
            'id' => ['nullable', 'uuid'],
            'code' => ['required', 'string', 'max:60', 'unique:modeles_messages,code'],
            'nom' => ['required', 'string', 'max:190'],
            'objectif' => ['required', 'string', 'max:120'],
            'canal' => ['required', 'in:messenger,whatsapp,email,telephone,autre'],
            'corps_template' => ['required', 'string'],
            'actif' => ['sometimes', 'boolean'],
        ]);

        $variables = [];
        preg_match_all('/\{([a-z_]+)\}/', $d['corps_template'], $m);
        $variables = array_values(array_unique($m[1]));

        return DB::transaction(function () use ($d, $variables) {
            $t = \App\Models\ModeleMessage::create($d + ['variables_json' => $variables, 'version' => 1]);
            app(\App\Domain\AuditService::class)->journalise('modele_message', $t->id, 'creation', null, $t->toArray());

            return $this->ok($t, 201);
        });
    }
}

/** Demandes commerciales (spec §6.A-D, §7.3). */
