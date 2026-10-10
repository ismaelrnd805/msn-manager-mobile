<?php

namespace App\Http\Controllers\Api\V1;

use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Client;
use App\Models\Contact;
use App\Http\Controllers\Api\V1\ApiController;
/** Contacts : CRUD lié aux clients. */
final class ContactsController extends ApiController
{
    public function index(Request $request): JsonResponse
    {
        $q = Contact::query()->whereNull('deleted_at')->with('client');
        if ($clientId = $request->query('client_id')) {
            $q->where('client_id', $clientId);
        }

        return $this->page($request, $q);
    }

    public function store(Request $request): JsonResponse
    {
        $d = $request->validate([
            'id' => ['nullable', 'uuid'],
            'client_id' => ['required', 'uuid'],
            'nom' => ['required', 'string', 'max:190'],
            'role' => ['nullable', 'string', 'max:120'],
            'telephone' => ['nullable', 'string', 'max:40'],
            'email' => ['nullable', 'email', 'max:190'],
            'canal_prefere' => ['nullable', 'in:messenger,whatsapp,email,telephone,autre'],
            'principal' => ['sometimes', 'boolean'],
        ]);
        Client::query()->whereNull('deleted_at')->findOrFail($d['client_id']);

        $contact = \Illuminate\Support\Facades\DB::transaction(function () use ($d) {
            if (! empty($d['principal'])) {
                Contact::query()->where('client_id', $d['client_id'])->update(['principal' => false]);
            }
            $contact = Contact::create($d + ['id' => $d['id'] ?? (string) Str::uuid(), 'version' => 1]);
            app(\App\Domain\AuditService::class)->journalise('contact', $contact->id, 'creation', null, $contact->toArray());

            return $contact;
        });

        return $this->ok($contact, 201);
    }

    public function show(string $id): JsonResponse
    {
        return $this->ok(Contact::query()->whereNull('deleted_at')->findOrFail($id));
    }

    public function update(Request $request, string $id): JsonResponse
    {
        $contact = Contact::query()->whereNull('deleted_at')->findOrFail($id);
        $d = $request->validate([
            'nom' => ['sometimes', 'string', 'max:190'],
            'role' => ['nullable', 'string', 'max:120'],
            'telephone' => ['nullable', 'string', 'max:40'],
            'email' => ['nullable', 'email', 'max:190'],
            'canal_prefere' => ['nullable', 'in:messenger,whatsapp,email,telephone,autre'],
            'principal' => ['sometimes', 'boolean'],
            'version' => ['required', 'integer', 'min:1'],
        ]);
        $versionAttendue = (int) array_pull($d, 'version');
        if ($versionAttendue !== $contact->version) {
            return $this->erreur('VERSION_CONFLICT', 'Version obsolète.', 409, ['version_serveur' => $contact->version]);
        }

        return \Illuminate\Support\Facades\DB::transaction(function () use ($contact, $d) {
            $avant = $contact->toArray();
            $contact->fill($d);
            $contact->version += 1;
            $contact->save();
            app(\App\Domain\AuditService::class)->journalise('contact', $contact->id, 'modification', $avant, $contact->toArray());

            return $this->ok($contact);
        });
    }

    public function destroy(Request $request, string $id): JsonResponse
    {
        $contact = Contact::query()->whereNull('deleted_at')->findOrFail($id);
        $d = $request->validate(['motif' => ['required', 'string', 'min:3']]);
        \Illuminate\Support\Facades\DB::transaction(function () use ($contact, $d) {
            $avant = $contact->toArray();
            $contact->deleted_at = now();
            $contact->version += 1;
            $contact->save();
            app(\App\Domain\AuditService::class)->journalise('contact', $contact->id, 'suppression_logique', $avant, null, $d['motif']);
        });

        return response()->json([], 204);
    }
}
