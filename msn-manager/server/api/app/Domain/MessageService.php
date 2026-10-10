<?php

namespace App\Domain;

use App\Models\Echange;
use App\Models\ModeleMessage;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Communications (spec §6.Communication, §7.5) :
 *  - préparation = remplissage des variables connues, liste des variables manquantes ;
 *  - préparé/copié ≠ envoyé ; l'envoi manuel est une confirmation explicite distincte ;
 *  - le modèle global n'est jamais modifié quand l'utilisateur édite un texte préparé.
 */
final class MessageService
{
    /**
     * Prépare un message à partir d'un modèle + contexte (demande).
     * Retourne texte prérempli, variables utilisées et manquantes.
     */
    public function prepare(string $codeModele, ?string $demandeId = null, ?string $commandeId = null, ?string $canal = null): array
    {
        $modele = ModeleMessage::query()->where('code', $codeModele)->where('actif', true)->firstOrFail();

        $contexte = $this->construitContexte($demandeId, $commandeId);
        $texte = $modele->corps_template;
        $manquantes = [];

        foreach ($modele->variables_json ?? [] as $variable) {
            $valeur = $contexte[$variable] ?? null;
            if ($valeur === null || $valeur === '') {
                $manquantes[] = $variable;
            } else {
                $texte = str_replace('{'.$variable.'}', (string) $valeur, $texte);
            }
        }

        return [
            'modele' => ['id' => $modele->id, 'code' => $modele->code, 'nom' => $modele->nom],
            'canal' => $canal ?? $modele->canal,
            'texte_prepare' => $texte,
            'variables_manquantes' => $manquantes,
            'note' => 'Le texte reste modifiable. La préparation ne marque jamais le message comme envoyé.',
        ];
    }

    /** Enregistre un échange (brouillon/prete) lié au client. */
    public function enregistre(array $donnees, ?string $appareilId = null, ?string $acteurId = null): Echange
    {
        return DB::transaction(function () use ($donnees, $appareilId, $acteurId) {
            $echange = Echange::create([
                'id' => $donnees['id'] ?? (string) Str::uuid(),
                'client_id' => $donnees['client_id'],
                'demande_id' => $donnees['demande_id'] ?? null,
                'commande_id' => $donnees['commande_id'] ?? null,
                'modele_id' => $donnees['modele_id'] ?? null,
                'canal' => $donnees['canal'],
                'direction' => $donnees['direction'],
                'contenu' => $donnees['contenu'],
                'statut_envoi' => $donnees['statut_envoi'] ?? 'brouillon',
                'date_preparation' => in_array($donnees['statut_envoi'] ?? 'brouillon', ['prete', 'copiee'], true) ? now() : null,
                'version' => 1,
            ]);

            app(AuditService::class)->journalise('echange', $echange->id, 'creation', null, $echange->toArray(), null, $appareilId, $acteurId);

            return $echange;
        });
    }

    public function transitionEchange(Echange $echange, string $vers, int $versionAttendue, ?string $appareilId = null, ?string $acteurId = null): Echange
    {
        if ($versionAttendue !== $echange->version) {
            throw new ConflitVersionException('echange', $echange->id, $echange->version, $echange->toArray());
        }
        if (! Statuts::transitionAutorisee('echange', $echange->statut_envoi, $vers)) {
            throw new TransitionInvalideException('echange', $echange->statut_envoi, $vers);
        }

        return DB::transaction(function () use ($echange, $vers, $appareilId, $acteurId) {
            $avant = $echange->toArray();
            $echange->statut_envoi = $vers;
            if ($vers === 'copiee') {
                $echange->date_copie = now();
            }
            if ($vers === 'envoi_manuel_confirme') {
                $echange->date_envoi_confirme = now();
            }
            $echange->version += 1;
            $echange->save();

            app(AuditService::class)->journalise('echange', $echange->id, 'transition', $avant, $echange->toArray(), null, $appareilId, $acteurId);

            return $echange;
        });
    }

    /** Contexte de remplissage depuis demande/commande + catalogue. */
    private function construitContexte(?string $demandeId, ?string $commandeId): array
    {
        $contexte = [];
        if ($demandeId) {
            $d = \App\Models\Demande::with(['client', 'prestations.service'])->find($demandeId);
            if ($d) {
                $contexte['client_prenom'] = explode(' ', $d->client->nom_affiche)[0] ?? $d->client->nom_affiche;
                $contexte['besoin_resume'] = $d->besoin_resume;
                $contexte['date_limite'] = $d->date_limite_souhaitee?->format('d/m/Y');
                $p = $d->prestations->first();
                if ($p) {
                    $contexte['service_nom'] = $p->service->nom;
                    $contexte['unite'] = $p->unite_snapshot;
                    $contexte['detail_quantite'] = $this->quantiteLisible($p->quantite).' '.$p->unite_snapshot;
                    if ($p->prix_indicatif_unitaire !== null) {
                        $contexte['prix_indicatif'] = number_format($p->prix_indicatif_unitaire, 0, ',', ' ');
                        if (! str_contains($p->quantite, '.')) {
                            $total = (int) $p->quantite * (int) $p->prix_indicatif_unitaire;
                            $contexte['prix_total_indicatif'] = number_format($total, 0, ',', ' ');
                        }
                    }
                    // Les questions déjà répondues ne sont PAS remises dans questions_manquantes
                    $manquantes = app(DemandeService::class)->informationsManquantes($d);
                    $contexte['questions_manquantes'] = implode(', ', $manquantes) !== '' ? implode(', ', $manquantes) : '—';
                }
            }
        }
        if ($commandeId) {
            $c = \App\Models\Commande::find($commandeId);
            if ($c) {
                $contexte['numero_commande'] = $c->numero;
                $contexte['date_limite_confirmee'] = $c->date_limite_confirmee?->format('d/m/Y');
            }
        }
        if (isset($contexte['prix_total_indicatif'])) {
            $contexte['prix_indicatif'] = $contexte['prix_indicatif'].' Ar par '.$contexte['unite'].' (total indicatif '.$contexte['prix_total_indicatif'].' Ar)';
        }

        return $contexte;
    }

    private function quantiteLisible(string $quantite): string
    {
        return str_replace('.', ',', $quantite);
    }
}
