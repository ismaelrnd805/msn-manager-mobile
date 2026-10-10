<?php

namespace App\Domain;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Synchronisation serveur (spec §8) :
 *  - push : idempotence (sync_push_log), contrôle base_version, règles métier,
 *    réponse opération par opération (synced/conflict/failed) ;
 *  - pull : journal de séquence monotone (sync_journal), lots bornés, tombstones ;
 *  - aucune écriture métier n'échappe à l'audit et au journal de sync.
 */
final class SyncService
{
    /** Registre des entités synchronisables : type → classe modèle (liste blanche). */
    public const ENTITES = [
        'client' => \App\Models\Client::class,
        'contact' => \App\Models\Contact::class,
        'demande' => \App\Models\Demande::class,
        'demande_prestation' => \App\Models\DemandePrestation::class,
        'echange' => \App\Models\Echange::class,
        'devis' => \App\Models\Devis::class,
        'lignes_devis' => \App\Models\LigneDevis::class,
        'commande' => \App\Models\Commande::class,
        'lignes_commande' => \App\Models\LigneCommande::class,
        'projet' => \App\Models\Projet::class,
        'cahiers_charges' => \App\Models\CahierCharges::class,
        'tache' => \App\Models\Tache::class,
        'facture' => \App\Models\Facture::class,
        'lignes_facture' => \App\Models\LigneFacture::class,
        'paiement' => \App\Models\Paiement::class,
        'depense' => \App\Models\Depense::class,
        'pieces_jointes' => \App\Models\PieceJointe::class,
        'publications_facebook' => \App\Models\PublicationFacebook::class,
    ];

    private const LOT_MAX = 100;

    /**
     * Traite un lot d'opérations push. Répond opération par opération.
     * Ne marque JAMAIS une opération en échec réseau comme perdue : le client décide.
     */
    public function push(array $operations, string $appareilId, ?string $acteurId = null): array
    {
        if (count($operations) > self::LOT_MAX) {
            throw new RegleMetierException('LOT_TROP_GRAND', 'Taille maximale du lot : '.self::LOT_MAX.' opérations.');
        }

        $resultats = [];
        foreach ($operations as $op) {
            $resultats[] = $this->traiteOperation($op, $appareilId, $acteurId);
        }

        return $resultats;
    }

    private function traiteOperation(array $op, string $appareilId, ?string $acteurId): array
    {
        $operationId = $op['operation_id'] ?? null;
        $cle = $op['idempotency_key'] ?? null;

        if (! $operationId || ! $cle) {
            return ['operation_id' => $operationId, 'resultat' => 'failed', 'code' => 'OPERATION_INCOMPLETE', 'message' => 'operation_id et idempotency_key requis.'];
        }

        // 1. Idempotence : résultat précédent renvoyé tel quel (spec §8.3 point 3)
        $deja = DB::table('sync_push_log')->where('idempotency_key', $cle)->first();
        if ($deja !== null) {
            $precedent = json_decode($deja->resultat_json, true) ?? [];

            return $precedent + ['idempotent' => true];
        }

        try {
            $resultat = DB::transaction(function () use ($op, $appareilId, $acteurId) {
                return $this->appliqueOperation($op, $appareilId, $acteurId);
            });
        } catch (ConflitVersionException $e) {
            $resultat = [
                'operation_id' => $operationId,
                'resultat' => 'conflict',
                'code' => 'VERSION_CONFLICT',
                'version_serveur' => $e->versionServeur,
                'serveur' => $e->etatServeur,
            ];
        } catch (TransitionInvalideException $e) {
            $resultat = ['operation_id' => $operationId, 'resultat' => 'failed', 'code' => 'INVALID_TRANSITION', 'message' => $e->getMessage()];
        } catch (RegleMetierException $e) {
            $resultat = ['operation_id' => $operationId, 'resultat' => 'failed', 'code' => $e->codeErreur, 'message' => $e->getMessage()];
        } catch (\Illuminate\Validation\ValidationException $e) {
            $resultat = ['operation_id' => $operationId, 'resultat' => 'failed', 'code' => 'VALIDATION_ERROR', 'details' => $e->errors()];
        } catch (\Throwable $e) {
            $resultat = ['operation_id' => $operationId, 'resultat' => 'failed', 'code' => 'ERREUR_SERVEUR', 'message' => 'Traitement refusé (détail non exposé).'];
        }

        $resultat['operation_id'] = $operationId;
        $resultat['device_id'] = $appareilId;

        // Journal d'idempotence (dans une transaction dédiée — toujours persisté)
        DB::table('sync_push_log')->insert([
            'idempotency_key' => $cle,
            'device_id' => $appareilId,
            'operation_id' => $operationId,
            'resultat' => $resultat['resultat'],
            'resultat_json' => json_encode($resultat),
            'created_at' => now(),
        ]);

        return $resultat;
    }

    private function appliqueOperation(array $op, string $appareilId, ?string $acteurId): array
    {
        $type = $op['entity_type'] ?? null;
        $entiteId = $op['entity_id'] ?? null;
        $operation = $op['operation'] ?? null;
        $payload = $op['payload'] ?? [];

        if (! isset(self::ENTITES[$type])) {
            throw new RegleMetierException('ENTITE_INCONNUE', "Type d'entité non synchronisable : $type");
        }
        if (! in_array($operation, ['upsert', 'delete'], true)) {
            throw new RegleMetierException('OPERATION_INCONNUE', "Opération non supportée : $operation");
        }
        if (! is_string($entiteId) || ! preg_match('/^[0-9a-f-]{36}$/i', $entiteId)) {
            throw new RegleMetierException('ID_INVALIDE', 'entity_id doit être un UUID.');
        }

        $classe = self::ENTITES[$type];

        /** @var \Illuminate\Database\Eloquent\Model $existante */
        $existante = $classe::query()->whereKey($entiteId)->first();

        if ($operation === 'delete') {
            if ($existante === null) {
                // Déjà supprimé côté serveur : résultat idempotent
                return ['resultat' => 'synced', 'tombstone' => true];
            }
            // Documents financiers et audit : pas d'effacement silencieux (spec §9 règle 10)
            if (in_array($type, ['facture', 'paiement', 'devis'], true) && $existante->getAttribute('statut') !== 'brouillon') {
                throw new RegleMetierException('SUPPRESSION_INTERDITE', "Un(e) $type émis(e) ne peut pas être supprimé(e) silencieusement : procédure de rectification requise.");
            }
            $avant = $existante->toArray();
            $existante->deleted_at = now();
            $existante->version = ($existante->version ?? 1) + 1;
            $existante->save();

            $this->ecritJournal($type, $entiteId, (int) $existante->version, true, ['deleted' => true]);
            app(AuditService::class)->journalise($type, $entiteId, 'suppression_logique', $avant, null, $payload['motif'] ?? 'Suppression synchronisée', $appareilId, $acteurId);

            return ['resultat' => 'synced', 'version' => (int) $existante->version, 'tombstone' => true];
        }

        // UPSERT
        $versionBase = $op['base_version'] ?? null;

        if ($existante !== null) {
            $versionServeur = (int) $existante->version;
            if ($versionBase !== null && (int) $versionBase !== $versionServeur) {
                throw new ConflitVersionException($type, $entiteId, $versionServeur, $existante->toArray());
            }
            // Fusion par défaut des champs non protégés ; champs protégés refusés
            $proteges = $this->champsProteges($type, $existante);
            $donnees = array_intersect_key($payload, array_flip($this->champsModifiables($type)));
            foreach ($proteges as $champ => $pourquoi) {
                if (array_key_exists($champ, $donnees)) {
                    throw new RegleMetierException('CHAMP_PROTEGE', "Le champ $champ est $pourquoi — action métier explicite requise.");
                }
            }
            $avant = $existante->toArray();
            $existante->fill($donnees);
            $existante->version = $versionServeur + 1;
            $existante->save();

            $this->ecritJournal($type, $entiteId, (int) $existante->version, false, $existante->toArray());
            app(AuditService::class)->journalise($type, $entiteId, 'modification_sync', $avant, $existante->toArray(), null, $appareilId, $acteurId);

            return ['resultat' => 'synced', 'version' => (int) $existante->version, 'serveur' => $existante->toArray()];
        }

        // Création : id fourni par le client (UUID stable), version 1
        $donnees = array_intersect_key($payload, array_flip($this->champsModifiables($type)));
        $donnees['id'] = $entiteId;
        if (! array_key_exists('version', $donnees)) {
            $donnees['version'] = 1;
        }
        $existante = new $classe;
        $existante->fill($donnees);
        $existante->save();
        $existante->refresh();

        $this->ecritJournal($type, $entiteId, (int) ($existante->version ?? 1), false, $existante->toArray());
        app(AuditService::class)->journalise($type, $entiteId, 'creation_sync', null, $existante->toArray(), null, $appareilId, $acteurId);

        return ['resultat' => 'synced', 'version' => (int) ($existante->version ?? 1), 'serveur' => $existante->toArray()];
    }

    /** Champs jamais écrasables par une opération sync générique (transitions protégées). */
    private function champsProteges(string $type, $existante): array
    {
        $base = [
            'id' => 'immuable',
            'version' => 'géré par le serveur',
            'created_at' => 'immuable',
        ];
        $metier = match ($type) {
            'commande' => ['statut' => 'transition métier contrôlée', 'numero' => 'attribué par le serveur'],
            'devis' => ['statut' => 'transition métier contrôlée', 'numero' => 'attribué par le serveur', 'total_ht' => 'recalculé serveur'],
            'facture' => ['statut' => 'statut financier calculé', 'numero' => 'attribué par le serveur', 'total' => 'recalculé serveur'],
            'paiement' => ['statut' => 'confirmation métier contrôlée'],
            'demande' => ['statut' => 'transition métier contrôlée'],
            'echange' => ['statut_envoi' => 'confirmation d\'envoi contrôlée'],
            default => [],
        };

        return $base + $metier;
    }

    /** Champs modifiables via sync — whitelist par entité. */
    private function champsModifiables(string $type): array
    {
        return match ($type) {
            'client' => ['type_client', 'nom_affiche', 'nom_legal', 'telephone_principal', 'email_principal', 'adresse', 'notes', 'actif', 'deleted_at'],
            'contact' => ['client_id', 'nom', 'role', 'telephone', 'email', 'canal_prefere', 'principal', 'deleted_at'],
            'demande' => ['client_id', 'contact_id', 'canal_origine', 'message_initial', 'besoin_resume', 'date_limite_souhaitee', 'budget_indicatif', 'devise_budget', 'motif_perte', 'deleted_at'],
            'demande_prestation' => ['demande_id', 'service_id', 'quantite', 'unite_snapshot', 'prix_indicatif_unitaire', 'devise', 'details_json', 'deleted_at'],
            'echange' => ['client_id', 'demande_id', 'commande_id', 'modele_id', 'canal', 'direction', 'contenu', 'date_preparation', 'external_reference', 'deleted_at'],
            'devis' => ['demande_id', 'commande_id', 'revision', 'date_emission', 'date_validite', 'conditions', 'accepte_at', 'deleted_at'],
            'lignes_devis' => ['devis_id', 'service_id', 'description', 'quantite', 'unite_snapshot', 'prix_unitaire', 'montant_ligne', 'deleted_at'],
            'commande' => ['date_debut_prevue', 'date_limite_confirmee', 'instructions', 'deleted_at'],
            'lignes_commande' => ['service_id', 'description', 'quantite', 'unite_snapshot', 'prix_unitaire', 'devise', 'deleted_at'],
            'projet' => ['commande_id', 'nom', 'description', 'date_limite', 'deleted_at'],
            'cahiers_charges' => ['projet_id', 'version_document', 'contenu_json', 'date_validation', 'deleted_at'],
            'tache' => ['commande_id', 'projet_id', 'titre', 'description', 'priorite', 'echeance', 'deleted_at'],
            'facture' => ['date_echeance', 'conditions', 'deleted_at'],
            'lignes_facture' => ['facture_id', 'description', 'quantite', 'unite_snapshot', 'prix_unitaire', 'montant_ligne', 'deleted_at'],
            'paiement' => ['facture_id', 'montant', 'devise', 'date_paiement', 'moyen', 'reference', 'statut', 'notes', 'idempotency_key', 'deleted_at'],
            'depense' => ['date_depense', 'categorie', 'description', 'montant', 'devise', 'moyen', 'reference', 'deleted_at'],
            'pieces_jointes' => ['client_id', 'demande_id', 'commande_id', 'projet_id', 'nom_fichier', 'mime_type', 'taille_octets', 'sha256', 'chemin_local', 'statut_transfert', 'deleted_at'],
            'publications_facebook' => ['client_id', 'titre', 'contenu', 'date_planifiee', 'canal', 'notes', 'deleted_at'],
            default => [],
        };
    }

    /** Écrit une entrée du journal de séquence (curseur monotone du pull). */
    private function ecritJournal(string $type, string $entiteId, int $version, bool $tombstone, array $payload): void
    {
        DB::table('sync_journal')->insert([
            'entite_type' => $type,
            'entite_id' => $entiteId,
            'version' => $version,
            'tombstone' => $tombstone,
            'payload_json' => json_encode($payload),
            'created_at' => now(),
        ]);
    }

    /** Pull : changements depuis un curseur, lot borné, séquence monotone. */
    public function pull(string $curseur, int $limite = 100): array
    {
        $limite = min(max($limite, 1), 500);
        $curseurInt = (int) ($curseur ?: 0);

        $lignes = DB::table('sync_journal')
            ->where('seq', '>', $curseurInt)
            ->orderBy('seq')
            ->limit($limite)
            ->get();

        $changements = $lignes->map(function ($l) {
            return [
                'seq' => (int) $l->seq,
                'entity_type' => $l->entite_type,
                'entity_id' => $l->entite_id,
                'version' => (int) $l->version,
                'tombstone' => (bool) $l->tombstone,
                'payload' => json_decode($l->payload_json, true),
                'created_at' => $l->created_at,
            ];
        })->all();

        $prochainCurseur = $lignes->isEmpty() ? $curseurInt : (int) $lignes->last()->seq;

        return [
            'changements' => $changements,
            'prochain_curseur' => (string) $prochainCurseur,
            'a_suivre' => $lignes->count() === $limite,
        ];
    }
}
