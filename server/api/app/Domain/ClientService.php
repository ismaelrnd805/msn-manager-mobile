<?php

namespace App\Domain;

use App\Models\Client;
use Illuminate\Support\Str;

/**
 * Clients : création, mise à jour versionnée, détection de doublons (spec §10.A3,
 * §1 règle 2 — un client a plusieurs contacts/demandes/commandes).
 */
final class ClientService
{
    /** Recherche des doublons potentiels par téléphone, email ou nom normalisé. */
    public function doublonsPotentiels(string $nomAffiche, ?string $telephone = null, ?string $email = null, ?string $exclureId = null): array
    {
        $q = Client::query()->whereNull('deleted_at');

        $q->where(function ($qq) use ($nomAffiche, $telephone, $email) {
            $nomNormalise = mb_strtolower(trim($nomAffiche));
            $qq->whereRaw('lower(nom_affiche) = ?', [$nomNormalise]);
            if ($telephone !== null && $telephone !== '') {
                $tel = preg_replace('/[^0-9+]/', '', $telephone);
                $qq->orWhere('telephone_principal', $tel);
            }
            if ($email !== null && $email !== '') {
                $qq->orWhereRaw('lower(email_principal) = ?', [mb_strtolower(trim($email))]);
            }
        });

        if ($exclureId) {
            $q->where('id', '!=', $exclureId);
        }

        return $q->limit(10)->get(['id', 'nom_affiche', 'telephone_principal', 'email_principal', 'type_client'])
            ->map(fn (Client $c) => [
                'id' => $c->id,
                'nom_affiche' => $c->nom_affiche,
                'telephone_principal' => $c->telephone_principal,
                'email_principal' => $c->email_principal,
                'type_client' => $c->type_client,
            ])->all();
    }

    /** Recherche multi-critères : téléphone, email, nom (contient). */
    public function recherche(string $terme, int $limite = 20): array
    {
        $terme = trim($terme);
        if ($terme === '') {
            return [];
        }
        $tel = preg_replace('/[^0-9+]/', '', $terme);

        return Client::query()
            ->whereNull('deleted_at')
            ->where(function ($qq) use ($terme, $tel) {
                $qq->whereRaw('lower(nom_affiche) like ?', ['%'.mb_strtolower($terme).'%'])
                    ->orWhereRaw('lower(email_principal) like ?', ['%'.mb_strtolower($terme).'%']);
                if ($tel !== '') {
                    $qq->orWhere('telephone_principal', 'like', "%$tel%");
                }
            })
            ->orderBy('nom_affiche')
            ->limit($limite)
            ->get(['id', 'nom_affiche', 'type_client', 'telephone_principal', 'email_principal'])
            ->toArray();
    }

    public function creer(array $donnees, ?string $appareilId = null, ?string $acteurId = null): Client
    {
        return \Illuminate\Support\Facades\DB::transaction(function () use ($donnees, $appareilId, $acteurId) {
            $client = Client::create([
                'id' => $donnees['id'] ?? (string) Str::uuid(),
                'type_client' => $donnees['type_client'],
                'nom_affiche' => $donnees['nom_affiche'],
                'nom_legal' => $donnees['nom_legal'] ?? null,
                'telephone_principal' => $donnees['telephone_principal'] ?? null,
                'email_principal' => $donnees['email_principal'] ?? null,
                'adresse' => $donnees['adresse'] ?? null,
                'notes' => $donnees['notes'] ?? null,
                'actif' => $donnees['actif'] ?? true,
                'version' => 1,
            ]);

            app(AuditService::class)->journalise('client', $client->id, 'creation', null, $client->toArray(), null, $appareilId, $acteurId);

            return $client;
        });
    }

    /** Mise à jour optimiste : échoue si la version transmise n'est pas la version courante. */
    public function modifier(Client $client, array $donnees, int $versionAttendue, ?string $appareilId = null, ?string $acteurId = null): Client
    {
        if ($versionAttendue !== $client->version) {
            throw new ConflitVersionException('client', $client->id, $client->version, $client->toArray());
        }

        return \Illuminate\Support\Facades\DB::transaction(function () use ($client, $donnees, $appareilId, $acteurId) {
            $avant = $client->toArray();
            $client->fill($donnees);
            $client->version = $client->version + 1;
            $client->save();

            app(AuditService::class)->journalise('client', $client->id, 'modification', $avant, $client->toArray(), null, $appareilId, $acteurId);

            return $client;
        });
    }

    /** Suppression logique : interdite si le client a des demandes ou commandes. */
    public function supprimer(Client $client, string $motif, ?string $appareilId = null, ?string $acteurId = null): void
    {
        if ($client->demandes()->exists()) {
            throw new \DomainException('Impossible de supprimer un client ayant des demandes enregistrées.');
        }
        \Illuminate\Support\Facades\DB::transaction(function () use ($client, $motif, $appareilId, $acteurId) {
            $avant = $client->toArray();
            $client->deleted_at = now();
            $client->version += 1;
            $client->save();
            app(AuditService::class)->journalise('client', $client->id, 'suppression_logique', $avant, null, $motif, $appareilId, $acteurId);
        });
    }
}
