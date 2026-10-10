<?php

namespace App\Domain;

use App\Models\Commande;
use App\Models\Depense;
use App\Models\Facture;
use App\Models\LigneFacture;
use App\Models\Paiement;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Finances (spec §6.H, §9 règles 10-12) :
 *  - au plus une facture par commande (UNIQUE commande_id) ;
 *  - totaux recalculés serveur à partir des lignes ;
 *  - seuls les paiements CONFIRMÉS réduisent le solde ;
 *  - statut financier calculé par PaiementService (jamais éditable librement) ;
 *  - facture émise : modification interdite, rectification auditable ;
 *  - idempotence des paiements (clé unique).
 */
final class FactureService
{
    public function __construct(
        private readonly NumeroService $numeros,
        private readonly AuditService $audit,
    ) {}

    /** Crée une facture brouillon depuis les lignes de commande (instantanés). */
    public function creerDepuisCommande(Commande $commande, ?string $dateEcheance = null, ?string $appareilId = null, ?string $acteurId = null): Facture
    {
        return DB::transaction(function () use ($commande, $dateEcheance, $appareilId, $acteurId) {
            $existante = Facture::query()->where('commande_id', $commande->id)->whereNull('deleted_at')->first();
            if ($existante !== null) {
                return $existante; // idempotent : une seule facture par commande
            }

            $facture = Facture::create([
                'id' => (string) Str::uuid(),
                'numero' => $this->numeros->suivant('FAC'),
                'commande_id' => $commande->id,
                'statut' => 'brouillon',
                'date_echeance' => $dateEcheance,
                'total' => 0,
                'devise' => 'MGA',
                'version' => 1,
            ]);

            $total = 0;
            foreach ($commande->lignes()->whereNull('deleted_at')->get() as $ligne) {
                $montant = (int) round((float) $ligne->quantite * (int) $ligne->prix_unitaire);
                $total += $montant;
                LigneFacture::create([
                    'id' => (string) Str::uuid(),
                    'facture_id' => $facture->id,
                    'description' => $ligne->description,
                    'quantite' => $ligne->quantite,
                    'unite_snapshot' => $ligne->unite_snapshot,
                    'prix_unitaire' => $ligne->prix_unitaire,
                    'montant_ligne' => $montant,
                    'version' => 1,
                ]);
            }

            $facture->total = $total;
            $facture->save();
            $this->audit->journalise('facture', $facture->id, 'creation', null, $facture->toArray(), null, $appareilId, $acteurId);

            return $facture->refresh();
        });
    }

    /** Émission : plus de modification directe ensuite (rectification auditable). */
    public function emet(Facture $facture, int $versionAttendue, ?string $appareilId = null, ?string $acteurId = null): Facture
    {
        if ($versionAttendue !== $facture->version) {
            throw new ConflitVersionException('facture', $facture->id, $facture->version, $facture->toArray());
        }
        if ($facture->lignes()->whereNull('deleted_at')->count() === 0) {
            throw new RegleMetierException('FACTURE_SANS_LIGNE', 'Une facture doit avoir au moins une ligne avant émission.');
        }

        return DB::transaction(function () use ($facture, $appareilId, $acteurId) {
            $avant = $facture->toArray();
            $facture->statut = 'emise';
            $facture->date_emission = now()->toDateString();
            $facture->version += 1;
            $facture->save();
            $this->audit->journalise('facture', $facture->id, 'emission', $avant, $facture->toArray(), null, $appareilId, $acteurId);

            return $facture;
        });
    }

    /** Rectification auditable d'une facture émise (motif obligatoire, aucun effacement silencieux). */
    public function rectifie(Facture $facture, string $motif, array $nouvellesLignes, int $versionAttendue, ?string $appareilId = null, ?string $acteurId = null): Facture
    {
        if ($versionAttendue !== $facture->version) {
            throw new ConflitVersionException('facture', $facture->id, $facture->version, $facture->toArray());
        }
        if (in_array($facture->statut, ['payee', 'annulee'], true)) {
            throw new RegleMetierException('RECTIFICATION_INTERDITE', "Une facture $facture->statut ne peut pas être rectifiée.");
        }

        return DB::transaction(function () use ($facture, $motif, $nouvellesLignes, $appareilId, $acteurId) {
            $avant = $facture->toArray();
            $total = 0;
            foreach ($nouvellesLignes as $l) {
                $quantite = app(DemandeService::class)->normaliseQuantite($l['quantite']);
                $montant = (int) round((float) $quantite * (int) $l['prix_unitaire']);
                $total += $montant;
                LigneFacture::create([
                    'id' => (string) Str::uuid(),
                    'facture_id' => $facture->id,
                    'description' => '[RECTIFICATION] '.$l['description'],
                    'quantite' => $quantite,
                    'unite_snapshot' => $l['unite_snapshot'] ?? 'unité',
                    'prix_unitaire' => (int) $l['prix_unitaire'],
                    'montant_ligne' => $montant,
                    'version' => 1,
                ]);
            }
            $facture->total = $total;
            $facture->version += 1;
            $facture->save();
            $this->audit->journalise('facture', $facture->id, 'rectification', $avant, $facture->toArray(), $motif, $appareilId, $acteurId);

            return $facture;
        });
    }

    /** Annulation contrôlée et auditée (jamais silencieuse). */
    public function annule(Facture $facture, string $motif, int $versionAttendue, ?string $appareilId = null, ?string $acteurId = null): Facture
    {
        if ($versionAttendue !== $facture->version) {
            throw new ConflitVersionException('facture', $facture->id, $facture->version, $facture->toArray());
        }
        $encaisse = (int) Paiement::query()->where('facture_id', $facture->id)->where('statut', 'confirme')->whereNull('deleted_at')->sum('montant');
        if ($encaisse > 0) {
            throw new RegleMetierException('ANNULATION_IMPOSSIBLE', 'Impossible d\'annuler une facture avec des paiements confirmés : remboursement à traiter d\'abord.');
        }

        return DB::transaction(function () use ($facture, $motif, $appareilId, $acteurId) {
            $avant = $facture->toArray();
            $facture->statut = 'annulee';
            $facture->version += 1;
            $facture->save();
            $this->audit->journalise('facture', $facture->id, 'annulation', $avant, $facture->toArray(), $motif, $appareilId, $acteurId);

            return $facture;
        });
    }

    /** Solde dû : total − paiements confirmés (en attente/annulés exclus). */
    public function solde(Facture $facture): int
    {
        $encaisse = (int) Paiement::query()
            ->where('facture_id', $facture->id)
            ->where('statut', 'confirme')
            ->whereNull('deleted_at')
            ->sum('montant');

        return max(0, (int) $facture->total - $encaisse);
    }

    /** Recalcule le statut financier depuis les paiements confirmés (C6). */
    public function recalculeStatutFinancier(Facture $facture): Facture
    {
        return DB::transaction(function () use ($facture) {
            $encaisse = (int) Paiement::query()->where('facture_id', $facture->id)->where('statut', 'confirme')->whereNull('deleted_at')->sum('montant');
            $avant = $facture->toArray();

            if ($encaisse >= (int) $facture->total) {
                $facture->statut = 'payee';
            } elseif ($encaisse > 0) {
                $facture->statut = 'partiellement_payee';
            } else {
                $facture->statut = 'emise';
            }
            $facture->version += 1;
            $facture->save();
            if ($facture->wasChanged('statut')) {
                $this->audit->journalise('facture', $facture->id, 'statut_financier_recalcule', $avant, $facture->toArray(), null, null, null);
            }

            return $facture;
        });
    }

    /** Synthèse financière : recettes ≠ encaissements ≠ bénéfice (spec §10.D27). */
    public function synthese(?string $depuis = null, ?string $jusquA = null): array
    {
        $entre = function ($q) use ($depuis, $jusquA) {
            if ($depuis) {
                $q->whereDate('created_at', '>=', $depuis);
            }
            if ($jusquA) {
                $q->whereDate('created_at', '<=', $jusquA);
            }

            return $q;
        };

        $facture = (int) $entre(Facture::query()->whereNull('deleted_at')->whereIn('statut', ['emise', 'partiellement_payee', 'payee']))->sum('total');
        $recettes = (int) $entre(Paiement::query()->whereNull('deleted_at')->where('statut', 'confirme'))->sum('montant');
        $enAttente = (int) $entre(Paiement::query()->whereNull('deleted_at')->where('statut', 'en_attente'))->sum('montant');
        $depenses = (int) $entre(Depense::query()->whereNull('deleted_at'))->sum('montant');

        return [
            'devise' => 'MGA',
            'facture_emise' => $facture,          // montants facturés (droits constatés)
            'recettes_encaissees' => $recettes,   // paiements confirmés uniquement
            'paiements_en_attente' => $enAttente, // jamais comptés comme encaissés
            'depenses' => $depenses,
            'benefice_estime' => $recettes - $depenses,
            'note' => 'Recettes = paiements confirmés ; facture = totaux émis ; bénéfice = recettes − dépenses. Trois notions distinctes.',
        ];
    }
}
