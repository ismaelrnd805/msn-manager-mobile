<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/**
 * Catalogue initial V1 (spéc. §2 produit + exemple §6.C de la spec).
 * Seeder versionné : les données de catalogue ne sont jamais codées dans les widgets.
 * Tarifs indicatifs en Ariary (entiers) — modifiables via l'administration.
 */
final class CatalogueSeeder extends Seeder
{
    public function run(): void
    {
        $now = now();

        $services = [
            ['code' => 'SAISIE_DOC', 'nom' => 'Saisie et mise en forme de documents', 'categorie' => 'Documents',
             'unite' => 'page', 'complex' => false,
             'questions' => ['texte_complet', 'format_source', 'consignes'],
             'prix' => 700],
            ['code' => 'MISE_EN_PAGE_ACADEMIQUE', 'nom' => 'Mise en page académique (mémoires, thèses, rapports)', 'categorie' => 'Documents',
             'unite' => 'page', 'complex' => false,
             'questions' => ['texte_complet', 'format_source', 'consignes_etablissement'],
             'prix' => 1500],
            ['code' => 'CV_LETTRE', 'nom' => 'CV et lettres professionnelles', 'categorie' => 'Documents',
             'unite' => 'document', 'complex' => false,
             'questions' => ['informations_personnelles', 'parcours', 'modele_souhaite'],
             'prix' => 10000],
            ['code' => 'TABLEAUX_PRESENTATIONS', 'nom' => 'Tableaux, graphiques et présentations', 'categorie' => 'Bureautique',
             'unite' => 'document', 'complex' => false,
             'questions' => ['donnees_sources', 'format_livrable', 'charte_graphique'],
             'prix' => 15000],
            ['code' => 'LOGO', 'nom' => 'Création de logo', 'categorie' => 'Design graphique',
             'unite' => 'projet', 'complex' => true,
             'questions' => ['brief_marque', 'references', 'variantes_souhaitees', 'fichiers_sources'],
             'prix' => 80000],
            ['code' => 'AFFICHE_BROCHURE', 'nom' => 'Affiches, brochures et cartes de visite', 'categorie' => 'Design graphique',
             'unite' => 'visuel', 'complex' => false,
             'questions' => ['format_impression', 'contenus_texte', 'visuels_fournis'],
             'prix' => 25000],
            ['code' => 'SITE_WEB', 'nom' => 'Services web et projets numériques', 'categorie' => 'Web',
             'unite' => 'projet', 'complex' => true,
             'questions' => ['cahier_charges', 'hebergement', 'nom_domaine', 'delai_souhaite'],
             'prix' => 250000],
            ['code' => 'COM_FACEBOOK', 'nom' => 'Communication et planification Facebook', 'categorie' => 'Communication',
             'unite' => 'forfait_mensuel', 'complex' => false,
             'questions' => ['frequence_publications', 'acces_page', 'ton_editorial'],
             'prix' => 60000],
        ];

        foreach ($services as $s) {
            $id = (string) Str::uuid();
            DB::table('services')->insert([
                'id' => $id,
                'code' => $s['code'],
                'nom' => $s['nom'],
                'description' => null,
                'categorie' => $s['categorie'],
                'unite_tarifaire' => $s['unite'],
                'actif' => true,
                'necessite_cahier_charges' => $s['complex'],
                'questions_qualification_json' => json_encode($s['questions']),
                'created_at' => $now,
                'updated_at' => $now,
                'version' => 1,
            ]);
            DB::table('tarifs')->insert([
                'id' => (string) Str::uuid(),
                'service_id' => $id,
                'prix_unitaire' => $s['prix'],
                'devise' => 'MGA',
                'date_debut_validite' => '2026-01-01',
                'date_fin_validite' => null,
                'actif' => true,
                'created_at' => $now,
                'updated_at' => $now,
                'version' => 1,
            ]);
        }

        $modeles = [
            ['code' => 'REPONSE_INFO_SERVICE', 'nom' => 'Réponse à une demande de renseignements',
             'objectif' => 'repondre_information', 'canal' => 'messenger',
             'corps' => "Bonjour {client_prenom},\n\nMerci pour votre message. Pour {service_nom}, le tarif indicatif est de {prix_indicatif} Ar par {unite}.\n\nPour vous donner un prix confirmé, il me manque : {questions_manquantes}.\n\nDès réception de ces éléments, je vous prépare un devis détaillé.\n\nCordialement,\nMSN"],
            ['code' => 'PROPOSITION_DEVIS', 'nom' => 'Proposition de devis',
             'objectif' => 'presenter_devis', 'canal' => 'messenger',
             'corps' => "Bonjour {client_prenom},\n\nVoici le devis pour {service_nom} : {montant_devis} Ar au total ({detail_quantite}). Valable jusqu'au {date_validite}.\n\nDites-moi si cela vous convient ; dès votre confirmation, je démarre la production.\n\nCordialement,\nMSN"],
            ['code' => 'DEMANDE_INFORMATIONS_MANQUANTES', 'nom' => 'Demande d\'informations manquantes',
             'objectif' => 'demander_informations_manquantes', 'canal' => 'whatsapp',
             'corps' => "Bonjour {client_prenom},\n\nPour avancer sur votre demande ({besoin_resume}), il me manque : {questions_manquantes}.\n\nDès que je les ai, je vous confirme le prix et le délai.\n\nCordialement,\nMSN"],
            ['code' => 'CONFIRMATION_DEMARRAGE', 'nom' => 'Confirmation de démarrage de commande',
             'objectif' => 'confirmer_demarrage', 'canal' => 'whatsapp',
             'corps' => "Bonjour {client_prenom},\n\nC'est confirmé : votre commande {numero_commande} est lancée. Livraison prévue le {date_limite_confirmee}.\n\nJe vous tiens informé à chaque étape.\n\nCordialement,\nMSN"],
        ];

        foreach ($modeles as $m) {
            DB::table('modeles_messages')->insert([
                'id' => (string) Str::uuid(),
                'code' => $m['code'],
                'nom' => $m['nom'],
                'objectif' => $m['objectif'],
                'canal' => $m['canal'],
                'corps_template' => $m['corps'],
                'variables_json' => json_encode($this->variablesDe($m['corps'])),
                'actif' => true,
                'created_at' => $now,
                'updated_at' => $now,
                'version' => 1,
            ]);
        }

        // Utilisateur unique applicatif (identifiants de développement — changer en production)
        DB::table('users')->insert([
            'name' => 'MSN Admin',
            'email' => 'admin@msn.mg',
            'password' => bcrypt('change-moi-2026'),
            'created_at' => $now,
            'updated_at' => $now,
        ]);
    }

    /** Extrait les variables {xxx} d'un modèle de message. */
    private function variablesDe(string $corps): array
    {
        preg_match_all('/\{([a-z_]+)\}/', $corps, $m);

        return array_values(array_unique($m[1]));
    }
}
