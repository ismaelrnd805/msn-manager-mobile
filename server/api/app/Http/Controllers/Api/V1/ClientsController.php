<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\ClientService;
use App\Domain\ConflitVersionException;
use App\Domain\RegleMetierException;
use App\Models\Client;
use App\Models\Contact;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

/** Clients et contacts (spec §7.2) : CRUD versionné, recherche, doublons, historique. */
final class ClientsController extends ApiController
{
    public function index(Request $request): JsonResponse
    {
        $q = Client::query()->whereNull('deleted_at');
        if ($terme = $request->query('q')) {
            $tel = preg_replace('/[^0-9+]/', '', $terme);
            $q->where(function ($qq) use ($terme, $tel) {
                $qq->whereRaw('lower(nom_affiche) like ?', ['%'.mb_strtolower($terme).'%'])
                    ->orWhereRaw('lower(coalesce(email_principal,"")) like ?', ['%'.mb_strtolower($terme).'%']);
                if ($tel !== '') {
                    $qq->orWhere('telephone_principal', 'like', "%$tel%");
                }
            });
        }
        $tris = ['nom_affiche' => 'nom_affiche', 'created_at' => 'created_at'];
        $tri = $tris[$request->query('sort', 'nom_affiche')] ?? 'nom_affiche';
        $q->orderBy($tri);

        return $this->page($request, $q);
    }

    public function store(Request $request, ClientService $clients): JsonResponse
    {
        $d = $request->validate([
            'id' => ['nullable', 'uuid'],
            'type_client' => ['required', 'in:particulier,entreprise'],
            'nom_affiche' => ['required', 'string', 'max:190'],
            'nom_legal' => ['nullable', 'string', 'max:190'],
            'telephone_principal' => ['nullable', 'string', 'max:40'],
            'email_principal' => ['nullable', 'email', 'max:190'],
            'adresse' => ['nullable', 'string'],
            'notes' => ['nullable', 'string'],
        ]);

        $doublons = $clients->doublonsPotentiels($d['nom_affiche'], $d['telephone_principal'] ?? null, $d['email_principal'] ?? null);
        $client = $clients->creer($d, $request->header('X-Device-Id'), optional($request->user())->id);

        return response()->json([
            'data' => $client,
            'doublons_potentiels' => $doublons,
        ], 201);
    }

    public function show(string $id): JsonResponse
    {
        $client = Client::query()->whereNull('deleted_at')->with('contacts')->findOrFail($id);

        return $this->ok($client);
    }

    public function update(Request $request, string $id, ClientService $clients): JsonResponse
    {
        $client = Client::query()->whereNull('deleted_at')->findOrFail($id);
        $d = $request->validate([
            'type_client' => ['sometimes', 'in:particulier,entreprise'],
            'nom_affiche' => ['sometimes', 'string', 'max:190'],
            'nom_legal' => ['nullable', 'string', 'max:190'],
            'telephone_principal' => ['nullable', 'string', 'max:40'],
            'email_principal' => ['nullable', 'email', 'max:190'],
            'adresse' => ['nullable', 'string'],
            'notes' => ['nullable', 'string'],
            'actif' => ['sometimes', 'boolean'],
            'version' => ['required', 'integer', 'min:1'],
        ]);
        $versionAttendue = (int) array_pull($d, 'version');

        try {
            $client = $clients->modifier($client, $d, $versionAttendue, $request->header('X-Device-Id'), optional($request->user())->id);
        } catch (ConflitVersionException $e) {
            return $this->erreur('VERSION_CONFLICT', $e->getMessage(), 409,
                ['version_serveur' => $e->versionServeur, 'etat_serveur' => $e->etatServeur]);
        }

        return $this->ok($client);
    }

    public function destroy(Request $request, string $id, ClientService $clients): JsonResponse
    {
        $client = Client::query()->whereNull('deleted_at')->findOrFail($id);
        $d = $request->validate(['motif' => ['required', 'string', 'min:3']]);
        try {
            $clients->supprimer($client, $d['motif'], $request->header('X-Device-Id'), optional($request->user())->id);
        } catch (RegleMetierException $e) {
            return $this->erreur('REGLE_METIER', $e->getMessage(), 409);
        }

        return response()->json([], 204);
    }

    public function doublons(Request $request, ClientService $clients): JsonResponse
    {
        $d = $request->validate([
            'nom_affiche' => ['required_without_all:telephone_principal,email_principal', 'nullable', 'string', 'max:190'],
            'telephone_principal' => ['nullable', 'string', 'max:40'],
            'email_principal' => ['nullable', 'email', 'max:190'],
            'exclure_id' => ['nullable', 'uuid'],
        ]);

        return $this->ok(['doublons' => $clients->doublonsPotentiels($d['nom_affiche'] ?? '', $d['telephone_principal'] ?? null, $d['email_principal'] ?? null, $d['exclure_id'] ?? null)]);
    }

    public function historique(string $id): JsonResponse
    {
        $client = Client::query()->findOrFail($id);

        return $this->ok([
            'client' => $client,
            'contacts' => $client->contacts()->get(),
            'demandes' => $client->demandes()->get(),
            'echanges' => $client->echanges()->orderBy('created_at')->limit(200)->get(),
            'audit' => app(\App\Domain\AuditService::class)->historique('client', $client->id),
        ]);
    }
}
