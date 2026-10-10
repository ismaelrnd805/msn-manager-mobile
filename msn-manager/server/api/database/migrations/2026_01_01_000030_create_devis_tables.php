<?php

use App\Support\MigrationChecks;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Devis et lignes de devis — montants = instantanés (spec §1 règle 5).
 * Correction C1 (docs/01-jalon0-inspection.md) : commande_id est une FK indexée SANS UNIQUE ;
 * la règle « une seule version courante proposée à la fois » est vérifiée par le domaine.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('devis', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('numero', 30)->unique();
            $table->foreignUuid('demande_id')->constrained('demandes')->restrictOnDelete();
            $table->foreignUuid('commande_id')->nullable()->constrained('commandes')->restrictOnDelete();
            $table->unsignedInteger('revision')->default(1);
            $table->string('statut', 30)->default('brouillon');
            $table->date('date_emission')->nullable();
            $table->date('date_validite')->nullable();
            $table->text('conditions')->nullable();
            $table->unsignedBigInteger('total_ht')->default(0);
            $table->string('devise', 3)->default('MGA');
            $table->timestampTz('accepte_at')->nullable();
            $table->unsignedInteger('version')->default(1);
            $table->timestampsTz();
            $table->softDeletesTz();
            $table->unique(['demande_id', 'revision']);
            $table->index('commande_id', 'idx_devis_commande');
            $table->index('statut', 'idx_devis_statut');
        });

        Schema::create('lignes_devis', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('devis_id')->constrained('devis')->restrictOnDelete();
            $table->foreignUuid('service_id')->nullable()->constrained('services')->restrictOnDelete();
            $table->string('description');
            $table->decimal('quantite', 12, 3);
            $table->string('unite_snapshot', 30);
            $table->unsignedBigInteger('prix_unitaire');
            $table->unsignedBigInteger('montant_ligne');
            $table->unsignedInteger('version')->default(1);
            $table->timestampsTz();
            $table->softDeletesTz();
            $table->index('devis_id');
        });

        MigrationChecks::applique([
        "ALTER TABLE devis ADD CONSTRAINT chk_devis_statut CHECK (statut IN ('brouillon','presente','modification_demandee','accepte','refuse','expire','remplace'))",
        "ALTER TABLE devis ADD CONSTRAINT chk_devis_revision CHECK (revision >= 1)",
        "ALTER TABLE devis ADD CONSTRAINT chk_devis_total CHECK (total_ht >= 0)",
        "ALTER TABLE devis ADD CONSTRAINT chk_devis_devise CHECK (devise = 'MGA')",
        "ALTER TABLE lignes_devis ADD CONSTRAINT chk_ld_quantite CHECK (quantite > 0)",
        "ALTER TABLE lignes_devis ADD CONSTRAINT chk_ld_prix CHECK (prix_unitaire >= 0)",
        "ALTER TABLE lignes_devis ADD CONSTRAINT chk_ld_montant CHECK (montant_ligne >= 0)",
        ]);
    }

    public function down(): void
    {
        Schema::dropIfExists('lignes_devis');
        Schema::dropIfExists('devis');
    }
};
