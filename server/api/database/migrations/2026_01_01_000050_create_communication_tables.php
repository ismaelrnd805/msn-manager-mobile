<?php

use App\Support\MigrationChecks;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Communications (échanges) et planning Facebook.
 * Ajout justifié C7 : publications_facebook — préparation et suivi du calendrier éditorial,
 * sans publication automatique (aucune intégration de publication n'existe en V1).
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('echanges', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('client_id')->constrained('clients')->restrictOnDelete();
            $table->foreignUuid('demande_id')->nullable()->constrained('demandes')->restrictOnDelete();
            $table->foreignUuid('commande_id')->nullable()->constrained('commandes')->restrictOnDelete();
            $table->foreignUuid('modele_id')->nullable()->constrained('modeles_messages')->restrictOnDelete();
            $table->string('canal', 20);
            $table->string('direction', 10);
            $table->text('contenu');
            $table->string('statut_envoi', 40)->default('brouillon');
            $table->timestampTz('date_preparation')->nullable();
            $table->timestampTz('date_copie')->nullable();
            $table->timestampTz('date_envoi_confirme')->nullable();
            $table->string('external_reference', 190)->nullable();
            $table->unsignedInteger('version')->default(1);
            $table->timestampsTz();
            $table->softDeletesTz();
            $table->index(['client_id', 'created_at'], 'idx_echanges_client_date');
        });

        Schema::create('publications_facebook', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('client_id')->nullable()->constrained('clients')->restrictOnDelete();
            $table->string('titre');
            $table->text('contenu');
            $table->date('date_planifiee');
            $table->string('statut', 30)->default('planifie');
            $table->string('canal', 20)->default('facebook');
            $table->timestampTz('publie_at')->nullable();
            $table->text('notes')->nullable();
            $table->unsignedInteger('version')->default(1);
            $table->timestampsTz();
            $table->softDeletesTz();
            $table->index('date_planifiee');
        });

        MigrationChecks::applique([
        "ALTER TABLE echanges ADD CONSTRAINT chk_echanges_canal CHECK (canal IN ('messenger','facebook','whatsapp','email','telephone','presentiel','autre'))",
        "ALTER TABLE echanges ADD CONSTRAINT chk_echanges_direction CHECK (direction IN ('entrant','sortant','interne'))",
        "ALTER TABLE echanges ADD CONSTRAINT chk_echanges_statut CHECK (statut_envoi IN ('brouillon','prete','copiee','envoi_manuel_confirme','envoi_integration_confirme','echec'))",
        "ALTER TABLE publications_facebook ADD CONSTRAINT chk_pfb_statut CHECK (statut IN ('planifie','prete','publie_manuellement','annule'))",
        ]);
    }

    public function down(): void
    {
        Schema::dropIfExists('publications_facebook');
        Schema::dropIfExists('echanges');
    }
};
