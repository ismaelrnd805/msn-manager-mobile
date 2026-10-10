<?php

namespace App\Domain;

use App\Models\Commande;
use App\Models\Devis;
use App\Models\LigneDevis;
use App\Models\Demande;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Devis (spec §6.E) : instantanés de prix, révisions historisées, présentation,
 * modification (nouvelle révision), acceptation → création de commande ATOMIQUE
 * et IDEMPOTENTE (spec §6.F, test §10.16/§10.37).
 */
final class DevisService
{
    public function __construct(
        private readonly NumeroService $numeros,
        private readonly AuditService $audit,
    ) {}

    /** Crée un devis brouillon + lignes (montants calculés serveur, jamais lus du client). */
    public function creer(string $demandeId, array $lignes, ?string $commandeId = null, ?string $appareilId = null, ?string $acteurId = null): Devis
    {
        return DB::transaction(function () use ($demandeId, $lignes, $commandeId, $appareilId, $acteurId) {
            $demande = Demande::query()->whereNull('deleted_at')->findOrFail($demandeId);
            $derniereRevision = (int) Devis::query()->where('demande_id', $demandeId)->max('revision');

            $devis = Devis::create([
                'id' => (string) Str::uuid(),
                'numero' => $this->numeros->suivant('DEVIS'),
                'demande_id' => $demandeId,
                'commande_id' => $commandeId,
                'revision' => $derniereRevision + 1,
                'statut' => 'brouillon',
                'date_validite' => $lignes['date_validite'] ?? now()->addDays(15)->toDateString(),
                'conditions' => $lignes['conditions'] ?? null,
                'total_ht' => 0,
                'devise' => 'MGA',
                'version' => 1,
            ]);

            $total = 0;
            foreach ($lignes['lignes'] ?? [] as $l) {
                $quantite = app(DemandeService::class)->normaliseQuantite($l['quantite']);
                $montant = (int) round((float) $quantite * (int) $l['prix_unitaire']);
                $total += $montant;
                LigneDevis::create([
                    'id' => (string) Str::uuid(),
                    'devis_id' => $devis->id,
                    'service_id' => $l['service_id'] ?? null,
                    'description' => $l['description'],
                    'quantite' => $quantite,
                    'unite_snapshot' => $l['unite_snapshot'] ?? 'unité',
                    'prix_unitaire' => (int) $l['prix_unitaire'],
                    'montant_ligne' => $montant,
                    'version' => 1,
                ]);
            }

            $devis->total_ht = $total;
            $devis->save();

            $this->audit->journalise('devis', $devis->id, 'creation', null, $devis->toArray(), null, $appareilId, $acteurId);

            return $devis->refresh();
        });
    }

    /** Présentation : exige au moins une ligne valide (spec §9 règle 4). */
    public function presente(Devis $devis, int $versionAttendue, ?string $appareilId = null, ?string $acteurId = null): Devis
    {
        if ($versionAttendue !== $devis->version) {
            throw new ConflitVersionException('devis', $devis->id, $devis->version, $devis->toArray());
        }
        if ($devis->lignes()->whereNull('deleted_at')->count() === 0) {
            throw new RegleMetierException('DEVIS_SANS_LIGNE', 'Un devis doit avoir au moins une ligne valide avant présentation.');
        }
        // Une seule version courante proposée à la fois pour cette demande (C1)
        $courantPresente = Devis::query()
            ->where('demande_id', $devis->demande_id)
            ->whereNull('deleted_at')
            ->whereIn('statut', ['presente', 'modification_demandee'])
            ->where('id', '!=', $devis->id)
            ->exists();
        if ($courantPresente) {
            throw new RegleMetierException('DEVIS_COURANT_EXISTANT', 'Une autre version de devis est déjà présentée pour cette demande.');
        }

        return DB::transaction(function () use ($devis, $appareilId, $acteurId) {
            $avant = $devis->toArray();
            $devis->statut = 'presente';
            $devis->date_emission = now()->toDateString();
            $devis->version += 1;
            $devis->save();

            app(DemandeService::class)->transition($devis->demande, 'devis_a_preparer', $devis->demande->version, null, $appareilId, $acteurId);
            $this->audit->journalise('devis', $devis->id, 'presentation', $avant, $devis->toArray(), null, $appareilId, $acteurId);

            return $devis;
        });
    }

    /** Demande de modification : statut modification_demandee, historique intact. */
    public function demandeModification(Devis $devis, string $motif, int $versionAttendue, ?string $appareilId = null, ?string $acteurId = null): Devis
    {
        if ($versionAttendue !== $devis->version) {
            throw new ConflitVersionException('devis', $devis->id, $devis->version, $devis->toArray());
        }
        if (! Statuts::transitionAutorisee('devis', $devis->statut, 'modification_demandee')) {
            throw new TransitionInvalideException('devis', $devis->statut, 'modification_demandee');
        }

        return DB::transaction(function () use ($devis, $motif, $appareilId, $acteurId) {
            $avant = $devis->toArray();
            $devis->statut = 'modification_demandee';
            $devis->version += 1;
            $devis->save();
            $this->audit->journalise('devis', $devis->id, 'modification_demandee', $avant, $devis->toArray(), $motif, $appareilId, $acteurId);

            return $devis;
        });
    }

    /** Nouvelle révision : copie des lignes modifiables ; l'ancienne révision devient remplace. */
    public function nouvelleRevision(Devis $ancien, array $nouvellesLignes, ?string $appareilId = null, ?string $acteurId = null): Devis
    {
        return DB::transaction(function () use ($ancien, $nouvellesLignes, $appareilId, $acteurId) {
            if ($ancien->statut !== 'modification_demandee' && $ancien->statut !== 'brouillon') {
                throw new RegleMetierException('REVISION_INTERDITE', "Une nouvelle révision ne peut partir que d'un devis modification_demandee (statut actuel : {$ancien->statut}).");
            }
            $devis = $this->creer($ancien->demande_id, [
                'lignes' => $nouvellesLignes,
                'conditions' => $ancien->conditions,
                'date_validite' => $ancien->date_validite?->toDateString(),
            ], $ancien->commande_id, $appareilId, $acteurId);

            $avant = $ancien->toArray();
            $ancien->statut = 'remplace';
            $ancien->version += 1;
            $ancien->save();
            $this->audit->journalise('devis', $ancien->id, 'remplace_par_revision', $avant, ['revision_suivante' => $devis->numero], null, $appareilId, $acteurId);

            return $devis;
        });
    }

    /** Refus client : motif enregistré. */
    public function refuse(Devis $devis, ?string $motif, int $versionAttendue, ?string $appareilId = null, ?string $acteurId = null): Devis
    {
        if ($versionAttendue !== $devis->version) {
            throw new ConflitVersionException('devis', $devis->id, $devis->version, $devis->toArray());
        }
        if (! Statuts::transitionAutorisee('devis', $devis->statut, 'refuse')) {
            throw new TransitionInvalideException('devis', $devis->statut, 'refuse');
        }

        return DB::transaction(function () use ($devis, $motif, $appareilId, $acteurId) {
            $avant = $devis->toArray();
            $devis->statut = 'refuse';
            $devis->version += 1;
            $devis->save();
            app(DemandeService::class)->transition($devis->demande, 'perdue', $devis->demande->version, $motif ?? 'Devis refusé', $appareilId, $acteurId);
            $this->audit->journalise('devis', $devis->id, 'refus', $avant, $devis->toArray(), $motif, $appareilId, $acteurId);

            return $devis;
        });
    }

    /**
     * ACCEPTATION : crée la commande une seule fois (idempotent).
     * $cleIdempotence réutilisée → renvoie la commande existante (jamais de doublon).
     * $confirmee = false → enregistre seulement l'acceptation sans commande (spec §10.15).
     */
    public function accepte(Devis $devis, int $versionAttendue, bool $confirmee = true, ?string $cleIdempotence = null, ?string $appareilId = null, ?string $acteurId = null): array
    {
        if ($versionAttendue !== $devis->version) {
            throw new ConflitVersionException('devis', $devis->id, $devis->version, $devis->toArray());
        }

        // Raccourci idempotent AVANT tout contrôle de transition : si le devis est déjà
        // accepté ET lié à une commande, renvoyer cette commande (jamais de doublon).
        if ($devis->statut === 'accepte' && $devis->commande_id !== null) {
            return ['devis' => $devis, 'commande' => Commande::find($devis->commande_id), 'idempotent' => true];
        }

        if (! Statuts::transitionAutorisee('devis', $devis->statut, 'accepte')) {
            throw new TransitionInvalideException('devis', $devis->statut, 'accepte');
        }
        if ($devis->lignes()->whereNull('deleted_at')->count() === 0) {
            throw new RegleMetierException('DEVIS_SANS_LIGNE', 'Impossible d\'accepter un devis sans lignes.');
        }

        // Raccourci idempotent : si le devis est déjà accepté ET lié à une commande, renvoyer cette commande
        if ($devis->statut === 'accepte' && $devis->commande_id !== null) {
            return ['devis' => $devis, 'commande' => Commande::find($devis->commande_id), 'idempotent' => true];
        }

        return DB::transaction(function () use ($devis, $versionAttendue, $confirmee, $cleIdempotence, $appareilId, $acteurId) {
            $avant = $devis->toArray();
            $devis->statut = 'accepte';
            $devis->accepte_at = now();
            $devis->version += 1;
            $devis->save();

            app(DemandeService::class)->transition($devis->demande, 'gagnee', $devis->demande->version, 'Devis accepté', $appareilId, $acteurId);
            $this->audit->journalise('devis', $devis->id, 'acceptation', $avant, $devis->toArray(), null, $appareilId, $acteurId);

            $commande = null;
            if ($confirmee) {
                $commande = $this->creeCommandeDeAcceptation($devis, $cleIdempotence, $appareilId, $acteurId);
            }

            return ['devis' => $devis->refresh(), 'commande' => $commande, 'idempotent' => false];
        });
    }

    /**
     * Création de commande depuis un devis accepté — ATOMIQUE + IDEMPOTENTE.
     * Règle : une demande → au plus une commande (UNIQUE en base) ;
     * re-appel avec la même clé → commande existante.
     */
    public function creeCommandeDeAcceptation(Devis $devis, ?string $cleIdempotence = null, ?string $appareilId = null, ?string $acteurId = null): Commande
    {
        if ($devis->statut !== 'accepte') {
            throw new RegleMetierException('DEVIS_NON_ACCEPTE', 'La commande exige un devis accepté (spéc. §9 règle 6).');
        }
        if ($devis->commande_id !== null) {
            return Commande::findOrFail($devis->commande_id);
        }

        return DB::transaction(function () use ($devis, $cleIdempotence, $appareilId, $acteurId) {
            // Verrou pessimiste sur le devis pour sérialiser les créations concurrentes
            $devisVerrouille = Devis::query()->whereKey($devis->id)->lockForUpdate()->first();

            if ($devisVerrouille->commande_id !== null) {
                return Commande::findOrFail($devisVerrouille->commande_id);
            }

            // Doublon déjà créé par une transaction concurrente (demande UNIQUE)
            $existante = Commande::query()->where('demande_id', $devisVerrouille->demande_id)->first();
            if ($existante !== null) {
                $devisVerrouille->commande_id = $existante->id;
                $devisVerrouille->save();

                return $existante;
            }

            $commande = Commande::create([
                'id' => (string) Str::uuid(),
                'numero' => $this->numeros->suivant('CMD'),
                'demande_id' => $devisVerrouille->demande_id,
                'statut' => 'en_preparation',
                'date_confirmation' => now(),
                'instructions' => $devisVerrouille->demande->besoin_resume,
                'version' => 1,
            ]);

            // Les lignes de commande reprennent les lignes du devis accepté (prix historiques figés)
            foreach ($devisVerrouille->lignes()->whereNull('deleted_at')->get() as $ligne) {
                \App\Models\LigneCommande::create([
                    'id' => (string) Str::uuid(),
                    'commande_id' => $commande->id,
                    'service_id' => $ligne->service_id,
                    'description' => $ligne->description,
                    'quantite' => $ligne->quantite,
                    'unite_snapshot' => $ligne->unite_snapshot,
                    'prix_unitaire' => $ligne->prix_unitaire,
                    'devise' => 'MGA',
                    'version' => 1,
                ]);
            }

            $devisVerrouille->commande_id = $commande->id;
            $devisVerrouille->save();

            $this->audit->journalise('commande', $commande->id, 'creation_depuis_devis', null,
                ['commande' => $commande->toArray(), 'devis_numero' => $devisVerrouille->numero, 'cle_idempotence' => $cleIdempotence],
                null, $appareilId, $acteurId);

            return $commande;
        });
    }
}
