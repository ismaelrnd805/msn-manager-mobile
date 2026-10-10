<?php

namespace App\Domain;

use App\Models\Demande;
use App\Models\DemandePrestation;
use App\Models\Tarif;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Demandes commerciales (spec §6.A-D) :
 *  - une demande n'est pas une commande ; elle peut rester sans commande ;
 *  - message initial conservé tel quel ;
 *  - prix INDICATIF calculé depuis le tarif actif, jamais confirmé avant qualification ;
 *  - informations manquantes calculées depuis les questions de qualification du service
 *    et les réponses déjà enregistrées (une info déjà fournie n'est jamais redemandée).
 */
final class DemandeService
{
    /**
     * Crée une demande + ses prestations avec prix indicatif (dans une transaction).
     * $donnees = champs demande ; $prestations = [[service_id, quantite, unite_snapshot?, details?]]
     */
    public function creer(array $donnees, array $prestations = [], ?string $appareilId = null, ?string $acteurId = null): array
    {
        return DB::transaction(function () use ($donnees, $prestations, $appareilId, $acteurId) {
            $demande = Demande::create([
                'id' => $donnees['id'] ?? (string) Str::uuid(),
                'client_id' => $donnees['client_id'],
                'contact_id' => $donnees['contact_id'] ?? null,
                'canal_origine' => $donnees['canal_origine'],
                'message_initial' => $donnees['message_initial'],
                'besoin_resume' => $donnees['besoin_resume'] ?? null,
                'statut' => 'a_qualifier',
                'date_limite_souhaitee' => $donnees['date_limite_souhaitee'] ?? null,
                'budget_indicatif' => $donnees['budget_indicatif'] ?? null,
                'devise_budget' => 'MGA',
                'version' => 1,
            ]);

            $totalIndicatif = 0;
            $tarifManquant = false;

            foreach ($prestations as $p) {
                $service = \App\Models\Service::query()->whereNull('deleted_at')->findOrFail($p['service_id']);
                if (! $service->actif) {
                    throw new RegleMetierException('SERVICE_INACTIF', "Le service {$service->nom} n'est plus actif et ne peut pas être proposé.");
                }
                $tarif = $this->tarifActif($service->id);
                $quantite = $this->normaliseQuantite($p['quantite']);
                $prixUnitaire = $tarif?->prix_unitaire;
                if ($prixUnitaire === null) {
                    $tarifManquant = true;
                } else {
                    $totalIndicatif += (int) round($quantite * $prixUnitaire);
                }

                DemandePrestation::create([
                    'id' => (string) Str::uuid(),
                    'demande_id' => $demande->id,
                    'service_id' => $service->id,
                    'quantite' => $quantite,
                    'unite_snapshot' => $p['unite_snapshot'] ?? $service->unite_tarifaire,
                    'prix_indicatif_unitaire' => $prixUnitaire,
                    'devise' => 'MGA',
                    'details_json' => $p['details'] ?? [],
                    'version' => 1,
                ]);
            }

            app(AuditService::class)->journalise('demande', $demande->id, 'creation', null, $demande->toArray(), null, $appareilId, $acteurId);

            return [
                'demande' => $demande->refresh(),
                'prix_indicatif' => [
                    'montant' => $tarifManquant && $totalIndicatif === 0 ? null : $totalIndicatif,
                    'devise' => 'MGA',
                    'avertissement' => 'Estimation indicative, à confirmer après vérification du périmètre.',
                ],
            ];
        });
    }

    /** Tarif actif à date (date_fin_validite nulle ou future). */
    public function tarifActif(string $serviceId): ?Tarif
    {
        $aujourdhui = now()->toDateString();

        return Tarif::query()
            ->where('service_id', $serviceId)
            ->whereNull('deleted_at')
            ->where('actif', true)
            ->where('date_debut_validite', '<=', $aujourdhui)
            ->where(function ($q) use ($aujourdhui) {
                $q->whereNull('date_fin_validite')->orWhere('date_fin_validite', '>=', $aujourdhui);
            })
            ->orderByDesc('date_debut_validite')
            ->first();
    }

    /** Quantité décimale exacte : entrée chaîne/numérique → format canonique (3 décimales max). */
    public function normaliseQuantite(mixed $quantite): string
    {
        $dec = (string) $quantite;
        if (! preg_match('/^\d+(\.\d{1,3})?$/', $dec)) {
            throw new \InvalidArgumentException("Quantité invalide : $quantite (décimale exacte requise, 3 chiffres max).");
        }
        // Canonisation : suppression des zéros inutiles
        if (str_contains($dec, '.')) {
            $dec = rtrim(rtrim($dec, '0'), '.');
        }

        return $dec;
    }

    /**
     * Informations manquantes : questions de qualification des services de la demande
     * moins les réponses déjà présentes dans details_json (jamais redemandées).
     */
    public function informationsManquantes(Demande $demande): array
    {
        $demande->load('prestations.service');
        $manquantes = [];
        foreach ($demande->prestations as $p) {
            $questions = $p->service->questions_qualification_json ?? [];
            $reponses = array_keys($p->details_json ?? []);
            foreach ($questions as $q) {
                if (! in_array($q, $reponses, true) && ! in_array($q, $manquantes, true)) {
                    $manquantes[] = $q;
                }
            }
        }

        return $manquantes;
    }

    /**
     * Enregistre des réponses de qualification sans écraser sans trace (spec §6.D) :
     * fusion dans details_json + audit de la modification.
     */
    public function repondreQualification(Demande $demande, string $prestationId, array $reponses, ?string $appareilId = null, ?string $acteurId = null): DemandePrestation
    {
        return DB::transaction(function () use ($demande, $prestationId, $reponses, $appareilId, $acteurId) {
            $p = DemandePrestation::query()->where('demande_id', $demande->id)->findOrFail($prestationId);
            $avant = $p->toArray();
            $p->details_json = array_merge($p->details_json ?? [], $reponses);
            $p->version += 1;
            $p->save();

            app(AuditService::class)->journalise('demande_prestation', $p->id, 'qualification', $avant, $p->toArray(), null, $appareilId, $acteurId);

            return $p;
        });
    }

    /** Transition de statut de demande avec machine à états + audit. */
    public function transition(Demande $demande, string $vers, int $versionAttendue, ?string $motif = null, ?string $appareilId = null, ?string $acteurId = null): Demande
    {
        if ($versionAttendue !== $demande->version) {
            throw new ConflitVersionException('demande', $demande->id, $demande->version, $demande->toArray());
        }
        if (! Statuts::transitionAutorisee('demande', $demande->statut, $vers)) {
            throw new TransitionInvalideException('demande', $demande->statut, $vers);
        }
        if ($vers === 'perdue' && ($motif === null || trim($motif) === '')) {
            throw new RegleMetierException('MOTIF_REQUIS', 'Un motif est requis pour marquer une demande comme perdue.');
        }

        return DB::transaction(function () use ($demande, $vers, $motif, $appareilId, $acteurId) {
            $avant = $demande->toArray();
            $demande->statut = $vers;
            if ($vers === 'perdue') {
                $demande->motif_perte = $motif;
            }
            $demande->version += 1;
            $demande->save();

            app(AuditService::class)->journalise('demande', $demande->id, 'transition', $avant, $demande->toArray(), $motif, $appareilId, $acteurId);

            return $demande;
        });
    }

    /** Présentation d'offre : enregistre un échange + passe la demande à offre_presentee. */
    public function presenteOffre(Demande $demande, string $canal, ?string $texteLibre = null, ?string $appareilId = null, ?string $acteurId = null): array
    {
        return DB::transaction(function () use ($demande, $canal, $texteLibre, $appareilId, $acteurId) {
            $this->transition($demande, 'offre_presentee', $demande->version, null, $appareilId, $acteurId);

            $echange = app(MessageService::class)->enregistre([
                'client_id' => $demande->client_id,
                'demande_id' => $demande->id,
                'canal' => $canal,
                'direction' => 'sortant',
                'contenu' => $texteLibre ?? 'Offre présentée pour : '.($demande->besoin_resume ?? 'demande '.$demande->id),
                'statut_envoi' => 'prete',
            ], $appareilId, $acteurId);

            return ['demande' => $demande, 'echange' => $echange];
        });
    }
}
