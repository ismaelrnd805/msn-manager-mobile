<?php

namespace App\Domain;

use App\Models\Commande;
use App\Models\LigneCommande;
use App\Models\PieceJointe;
use App\Models\Projet;
use App\Models\Tache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Commandes (spec §6.F-G) : transitions contrôlées, projets multiples,
 * livraison obligatoire avant « livrée », annulation avec motif auditée.
 */
final class CommandeService
{
    public function __construct(
        private readonly NumeroService $numeros,
        private readonly AuditService $audit,
    ) {}

    /** Création directe (exception documentée — spec §9 règle 6) : exige devis accepté + clé d'idempotence. */
    public function creer(string $demandeId, string $devisAccepteId, string $cleIdempotence, ?string $appareilId = null, ?string $acteurId = null): Commande
    {
        $devis = \App\Models\Devis::query()->whereNull('deleted_at')->findOrFail($devisAccepteId);
        if ($devis->statut !== 'accepte') {
            throw new RegleMetierException('DEVIS_NON_ACCEPTE', 'La commande exige un devis accepté.');
        }
        if ($devis->demande_id !== $demandeId) {
            throw new RegleMetierException('DEVIS_DEMANDE_INCOHERENTS', 'Le devis ne correspond pas à cette demande.');
        }

        $commande = app(DevisService::class)->creeCommandeDeAcceptation($devis, $cleIdempotence, $appareilId, $acteurId);

        return $commande;
    }

    public function transition(Commande $commande, string $vers, int $versionAttendue, ?string $motif = null, ?string $appareilId = null, ?string $acteurId = null): Commande
    {
        if ($versionAttendue !== $commande->version) {
            throw new ConflitVersionException('commande', $commande->id, $commande->version, $commande->toArray());
        }
        if (! Statuts::transitionAutorisee('commande', $commande->statut, $vers)) {
            throw new TransitionInvalideException('commande', $commande->statut, $vers);
        }
        if ($vers === 'livree') {
            throw new RegleMetierException('LIVRAISON_REQUISE', 'La transition vers « livrée » passe par l\'enregistrement d\'une livraison (POST /commandes/{id}/delivery).');
        }
        if ($vers === 'annulee' && ($motif === null || trim($motif) === '')) {
            throw new RegleMetierException('MOTIF_REQUIS', 'Un motif est requis pour annuler une commande.');
        }

        return DB::transaction(function () use ($commande, $vers, $motif, $appareilId, $acteurId) {
            $avant = $commande->toArray();
            $commande->statut = $vers;
            if ($vers === 'annulee') {
                $commande->motif_annulation = $motif;
            }
            $commande->version += 1;
            $commande->save();

            $this->audit->journalise('commande', $commande->id, 'transition', $avant, $commande->toArray(), $motif, $appareilId, $acteurId);

            return $commande;
        });
    }

    /** Ajout d'un projet (une commande peut contenir plusieurs projets — spec §10.17). */
    public function ajouteProjet(Commande $commande, array $donnees, ?string $appareilId = null, ?string $acteurId = null): Projet
    {
        return DB::transaction(function () use ($commande, $donnees, $appareilId, $acteurId) {
            $projet = Projet::create([
                'id' => (string) Str::uuid(),
                'commande_id' => $commande->id,
                'nom' => $donnees['nom'],
                'description' => $donnees['description'] ?? null,
                'statut' => 'en_preparation',
                'date_limite' => $donnees['date_limite'] ?? null,
                'version' => 1,
            ]);

            $this->audit->journalise('projet', $projet->id, 'creation', null, $projet->toArray(), null, $appareilId, $acteurId);

            return $projet;
        });
    }

    /**
     * LIVRAISON (spec §6.G) : exige des pièces jointes rattachées OU un livrable décrit.
     * Enregistre l'événement de livraison, puis marque la commande livrée.
     */
    public function livre(Commande $commande, string $description, int $versionAttendue, array $piecesJointesIds = [], ?string $dateLivraison = null, ?string $appareilId = null, ?string $acteurId = null): Commande
    {
        if ($versionAttendue !== $commande->version) {
            throw new ConflitVersionException('commande', $commande->id, $commande->version, $commande->toArray());
        }
        if (! Statuts::transitionAutorisee('commande', $commande->statut, 'livree')) {
            throw new TransitionInvalideException('commande', $commande->statut, 'livree');
        }
        $hasPieces = ! empty($piecesJointesIds) && PieceJointe::query()->whereIn('id', $piecesJointesIds)->where('commande_id', $commande->id)->exists();
        if (! $hasPieces && trim($description) === '') {
            throw new RegleMetierException('LIVRAISON_SANS_LIVRABLE', 'Une livraison exige des fichiers joints ou un livrable décrit.');
        }

        return DB::transaction(function () use ($commande, $description, $piecesJointesIds, $dateLivraison, $appareilId, $acteurId) {
            $avant = $commande->toArray();
            $commande->statut = 'livree';
            $commande->version += 1;
            $commande->save();

            $this->audit->journalise('commande', $commande->id, 'livraison', $avant, [
                'statut' => 'livree',
                'livrable' => $description,
                'pieces_jointes' => $piecesJointesIds,
                'date_livraison' => $dateLivraison ?? now()->toDateString(),
            ], null, $appareilId, $acteurId);

            return $commande;
        });
    }

    /** Tâches de production (titre, priorité, échéance). */
    public function ajouteTache(Commande $commande, array $donnees, ?string $appareilId = null, ?string $acteurId = null): Tache
    {
        return DB::transaction(function () use ($commande, $donnees, $appareilId, $acteurId) {
            $tache = Tache::create([
                'id' => (string) Str::uuid(),
                'commande_id' => $commande->id,
                'projet_id' => $donnees['projet_id'] ?? null,
                'titre' => $donnees['titre'],
                'description' => $donnees['description'] ?? null,
                'statut' => 'a_faire',
                'priorite' => $donnees['priorite'] ?? 'normale',
                'echeance' => $donnees['echeance'] ?? null,
                'version' => 1,
            ]);
            $this->audit->journalise('tache', $tache->id, 'creation', null, $tache->toArray(), null, $appareilId, $acteurId);

            return $tache;
        });
    }

    public function transitionTache(Tache $tache, string $vers, int $versionAttendue, ?string $appareilId = null, ?string $acteurId = null): Tache
    {
        $permis = ['a_faire' => ['en_cours', 'annulee'], 'en_cours' => ['bloquee', 'terminee'], 'bloquee' => ['en_cours', 'annulee'], 'terminee' => [], 'annulee' => []];
        if (! in_array($vers, $permis[$tache->statut] ?? [], true)) {
            throw new TransitionInvalideException('tache', $tache->statut, $vers);
        }
        if ($versionAttendue !== $tache->version) {
            throw new ConflitVersionException('tache', $tache->id, $tache->version, $tache->toArray());
        }

        return DB::transaction(function () use ($tache, $vers, $appareilId, $acteurId) {
            $avant = $tache->toArray();
            $tache->statut = $vers;
            if ($vers === 'terminee') {
                $tache->terminee_at = now();
            }
            $tache->version += 1;
            $tache->save();
            $this->audit->journalise('tache', $tache->id, 'transition', $avant, $tache->toArray(), null, $appareilId, $acteurId);

            return $tache;
        });
    }

    /** Ligne de commande supplémentaire (prix figé, jamais recalculé du catalogue). */
    public function ajouteLigne(Commande $commande, array $donnees, ?string $appareilId = null, ?string $acteurId = null): LigneCommande
    {
        return DB::transaction(function () use ($commande, $donnees, $appareilId, $acteurId) {
            $quantite = app(DemandeService::class)->normaliseQuantite($donnees['quantite']);
            $ligne = LigneCommande::create([
                'id' => (string) Str::uuid(),
                'commande_id' => $commande->id,
                'service_id' => $donnees['service_id'] ?? null,
                'description' => $donnees['description'],
                'quantite' => $quantite,
                'unite_snapshot' => $donnees['unite_snapshot'] ?? 'unité',
                'prix_unitaire' => (int) $donnees['prix_unitaire'],
                'devise' => 'MGA',
                'version' => 1,
            ]);
            $this->audit->journalise('ligne_commande', $ligne->id, 'ajout', null, $ligne->toArray(), null, $appareilId, $acteurId);

            return $ligne;
        });
    }
}
