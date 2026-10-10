<?php

namespace App\Domain;

use App\Models\Facture;
use App\Models\Paiement;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Paiements (spec §6.H, §9 règle 11, tests D21-D25) :
 *  - idempotence par clé : répéter un paiement ne compte jamais deux fois ;
 *  - seul un paiement confirmé réduit le solde ;
 *  - trop-perçu refusé sans règle explicite.
 */
final class PaiementService
{
    public function __construct(
        private readonly FactureService $factures,
        private readonly AuditService $audit,
    ) {}

    /**
     * Enregistre un paiement. Si la clé d'idempotence a déjà été traitée,
     * renvoie le paiement existant (aucun double comptage).
     */
    public function enregistrer(Facture $facture, array $donnees, ?string $appareilId = null, ?string $acteurId = null): array
    {
        $cle = $donnees['idempotency_key'] ?? null;
        if ($cle) {
            $existant = Paiement::query()->where('idempotency_key', $cle)->first();
            if ($existant !== null) {
                return ['paiement' => $existant, 'idempotent' => true, 'facture' => Facture::find($existant->facture_id)];
            }
        }

        if (in_array($facture->statut, ['annulee'], true)) {
            throw new RegleMetierException('FACTURE_ANNULEE', 'Impossible de payer une facture annulée.');
        }

        $montant = (int) $donnees['montant'];
        if ($montant <= 0) {
            throw new RegleMetierException('MONTANT_INVALIDE', 'Le montant du paiement doit être strictement positif.');
        }

        // Trop-perçu : solde confirmé + nouveau paiement ne doit pas dépasser le total
        $solde = $this->factures->solde($facture);
        if ($facture->statut !== 'brouillon' && $montant > $solde) {
            throw new RegleMetierException('TROP_PERCU', "Paiement de $montant Ar supérieur au solde restant ($solde Ar). Aucune règle de trop-perçu n'est active en V1.");
        }

        return DB::transaction(function () use ($facture, $donnees, $montant, $cle, $appareilId, $acteurId) {
            $paiement = Paiement::create([
                'id' => (string) Str::uuid(),
                'facture_id' => $facture->id,
                'montant' => $montant,
                'devise' => 'MGA',
                'date_paiement' => $donnees['date_paiement'] ?? now()->toDateString(),
                'moyen' => $donnees['moyen'],
                'reference' => $donnees['reference'] ?? null,
                'statut' => $donnees['statut'] ?? 'confirme',
                'notes' => $donnees['notes'] ?? null,
                'idempotency_key' => $cle,
                'version' => 1,
            ]);

            if ($paiement->statut === 'confirme') {
                app(FactureService::class)->recalculeStatutFinancier($facture);
            }

            $this->audit->journalise('paiement', $paiement->id, 'creation', null, $paiement->toArray(), null, $appareilId, $acteurId);

            return ['paiement' => $paiement, 'idempotent' => false, 'facture' => $facture->refresh()];
        });
    }

    /** Confirmation d'un paiement en attente → recalcule le statut financier. */
    public function confirme(Paiement $paiement, int $versionAttendue, ?string $appareilId = null, ?string $acteurId = null): Paiement
    {
        if ($versionAttendue !== $paiement->version) {
            throw new ConflitVersionException('paiement', $paiement->id, $paiement->version, $paiement->toArray());
        }
        if ($paiement->statut !== 'en_attente') {
            throw new TransitionInvalideException('paiement', $paiement->statut, 'confirme');
        }

        return DB::transaction(function () use ($paiement, $appareilId, $acteurId) {
            $avant = $paiement->toArray();
            $paiement->statut = 'confirme';
            $paiement->version += 1;
            $paiement->save();

            $facture = Facture::find($paiement->facture_id);
            app(FactureService::class)->recalculeStatutFinancier($facture);
            $this->audit->journalise('paiement', $paiement->id, 'confirmation', $avant, $paiement->toArray(), null, $appareilId, $acteurId);

            return $paiement;
        });
    }

    /** Annulation d'un paiement → recalcule le statut financier (trace conservée). */
    public function annule(Paiement $paiement, string $motif, int $versionAttendue, ?string $appareilId = null, ?string $acteurId = null): Paiement
    {
        if ($versionAttendue !== $paiement->version) {
            throw new ConflitVersionException('paiement', $paiement->id, $paiement->version, $paiement->toArray());
        }

        return DB::transaction(function () use ($paiement, $motif, $appareilId, $acteurId) {
            $avant = $paiement->toArray();
            $paiement->statut = 'annule';
            $paiement->version += 1;
            $paiement->save();

            $facture = Facture::find($paiement->facture_id);
            app(FactureService::class)->recalculeStatutFinancier($facture);
            $this->audit->journalise('paiement', $paiement->id, 'annulation', $avant, $paiement->toArray(), $motif, $appareilId, $acteurId);

            return $paiement;
        });
    }
}
