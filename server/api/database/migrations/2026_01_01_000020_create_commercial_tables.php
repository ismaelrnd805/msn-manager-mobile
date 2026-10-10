<?php

use App\Support\MigrationChecks;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Tables commerciales : demandes, demande_prestations, commandes, lignes_commande,
 * projets, cahiers_charges, taches.
 * Corrections documentées : commande.demande_id UNIQUE (1 demande → 0..1 commande, spec §4.1) ;
 * demande_prestations UNIQUE(demande_id, service_id) conservée (spéc. §5.1) — lots multiples
 * via details_json.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('demandes', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('client_id')->constrained('clients')->restrictOnDelete();
            $table->foreignUuid('contact_id')->nullable()->constrained('contacts')->restrictOnDelete();
            $table->string('canal_origine', 20);
            $table->text('message_initial');
            $table->text('besoin_resume')->nullable();
            $table->string('statut', 30)->default('a_qualifier');
            $table->date('date_limite_souhaitee')->nullable();
            $table->unsignedBigInteger('budget_indicatif')->nullable();
            $table->string('devise_budget', 3)->default('MGA');
            $table->text('motif_perte')->nullable();
            $table->unsignedInteger('version')->default(1);
            $table->timestampsTz();
            $table->softDeletesTz();
            $table->index(['client_id', 'created_at'], 'idx_demandes_client_date');
            $table->index('statut', 'idx_demandes_statut');
        });

        Schema::create('demande_prestations', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('demande_id')->constrained('demandes')->restrictOnDelete();
            $table->foreignUuid('service_id')->constrained('services')->restrictOnDelete();
            $table->decimal('quantite', 12, 3)->default(1);
            $table->string('unite_snapshot', 30);
            $table->unsignedBigInteger('prix_indicatif_unitaire')->nullable();
            $table->string('devise', 3)->default('MGA');
            $table->json('details_json')->default('{}');
            $table->unsignedInteger('version')->default(1);
            $table->timestampsTz();
            $table->softDeletesTz();
            $table->unique(['demande_id', 'service_id']);
        });

        Schema::create('commandes', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('numero', 30)->unique();
            $table->foreignUuid('demande_id')->unique()->constrained('demandes')->restrictOnDelete();
            $table->string('statut', 30)->default('en_preparation');
            $table->timestampTz('date_confirmation')->nullable();
            $table->date('date_debut_prevue')->nullable();
            $table->date('date_limite_confirmee')->nullable();
            $table->text('instructions')->nullable();
            $table->text('motif_annulation')->nullable();
            $table->unsignedInteger('version')->default(1);
            $table->timestampsTz();
            $table->softDeletesTz();
        });

        Schema::create('lignes_commande', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('commande_id')->constrained('commandes')->restrictOnDelete();
            $table->foreignUuid('service_id')->nullable()->constrained('services')->restrictOnDelete();
            $table->string('description');
            $table->decimal('quantite', 12, 3);
            $table->string('unite_snapshot', 30);
            $table->unsignedBigInteger('prix_unitaire');
            $table->string('devise', 3)->default('MGA');
            $table->unsignedInteger('version')->default(1);
            $table->timestampsTz();
            $table->softDeletesTz();
            $table->index('commande_id');
        });

        Schema::create('projets', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('commande_id')->constrained('commandes')->restrictOnDelete();
            $table->string('nom');
            $table->text('description')->nullable();
            $table->string('statut', 30)->default('en_preparation');
            $table->date('date_limite')->nullable();
            $table->unsignedInteger('version')->default(1);
            $table->timestampsTz();
            $table->softDeletesTz();
            $table->index('commande_id');
        });

        Schema::create('cahiers_charges', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('projet_id')->constrained('projets')->restrictOnDelete();
            $table->unsignedInteger('version_document')->default(1);
            $table->json('contenu_json');
            $table->string('statut', 20)->default('brouillon');
            $table->timestampTz('date_validation')->nullable();
            $table->unsignedInteger('version')->default(1);
            $table->timestampsTz();
            $table->softDeletesTz();
            $table->unique(['projet_id', 'version_document']);
        });

        Schema::create('taches', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('commande_id')->constrained('commandes')->restrictOnDelete();
            $table->foreignUuid('projet_id')->nullable()->constrained('projets')->restrictOnDelete();
            $table->string('titre');
            $table->text('description')->nullable();
            $table->string('statut', 20)->default('a_faire');
            $table->string('priorite', 20)->default('normale');
            $table->timestampTz('echeance')->nullable();
            $table->timestampTz('terminee_at')->nullable();
            $table->unsignedInteger('version')->default(1);
            $table->timestampsTz();
            $table->softDeletesTz();
            $table->index(['commande_id', 'statut']);
            $table->index('echeance');
        });

        MigrationChecks::applique([
        "ALTER TABLE demandes ADD CONSTRAINT chk_demandes_canal CHECK (canal_origine IN ('messenger','facebook','whatsapp','email','telephone','presentiel','autre'))",
        "ALTER TABLE demandes ADD CONSTRAINT chk_demandes_statut CHECK (statut IN ('a_qualifier','offre_presentee','en_attente_client','devis_a_preparer','gagnee','perdue'))",
        "ALTER TABLE demandes ADD CONSTRAINT chk_demandes_budget CHECK (budget_indicatif IS NULL OR budget_indicatif >= 0)",
        "ALTER TABLE demandes ADD CONSTRAINT chk_demandes_devise CHECK (devise_budget = 'MGA')",
        "ALTER TABLE demande_prestations ADD CONSTRAINT chk_dp_quantite CHECK (quantite > 0)",
        "ALTER TABLE demande_prestations ADD CONSTRAINT chk_dp_prix CHECK (prix_indicatif_unitaire IS NULL OR prix_indicatif_unitaire >= 0)",
        "ALTER TABLE demande_prestations ADD CONSTRAINT chk_dp_devise CHECK (devise = 'MGA')",
        "ALTER TABLE commandes ADD CONSTRAINT chk_commandes_statut CHECK (statut IN ('en_preparation','en_attente_validation','validee','en_production','en_correction','livree','annulee'))",
        "ALTER TABLE lignes_commande ADD CONSTRAINT chk_lc_quantite CHECK (quantite > 0)",
        "ALTER TABLE lignes_commande ADD CONSTRAINT chk_lc_prix CHECK (prix_unitaire >= 0)",
        "ALTER TABLE projets ADD CONSTRAINT chk_projets_statut CHECK (statut IN ('en_preparation','en_cours','en_correction','termine','annule'))",
        "ALTER TABLE cahiers_charges ADD CONSTRAINT chk_cc_statut CHECK (statut IN ('brouillon','a_valider','valide','remplace'))",
        "ALTER TABLE cahiers_charges ADD CONSTRAINT chk_cc_version CHECK (version_document >= 1)",
        "ALTER TABLE taches ADD CONSTRAINT chk_taches_statut CHECK (statut IN ('a_faire','en_cours','bloquee','terminee','annulee'))",
        "ALTER TABLE taches ADD CONSTRAINT chk_taches_prio CHECK (priorite IN ('basse','normale','haute','urgente'))",
        ]);
    }

    public function down(): void
    {
        foreach (['taches', 'cahiers_charges', 'projets', 'lignes_commande', 'commandes', 'demande_prestations', 'demandes'] as $t) {
            Schema::dropIfExists($t);
        }
    }
};
