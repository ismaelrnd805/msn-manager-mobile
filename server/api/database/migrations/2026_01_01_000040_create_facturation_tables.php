<?php

use App\Support\MigrationChecks;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Facturation : factures, lignes_facture, paiements, depenses.
 * factures.commande_id UNIQUE → au plus une facture par commande (périmètre V1, spec §5.1).
 * Les statuts partiellement_payee / payee sont recalculés par PaiementService uniquement (C6).
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('factures', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('numero', 30)->unique();
            $table->foreignUuid('commande_id')->unique()->constrained('commandes')->restrictOnDelete();
            $table->string('statut', 30)->default('brouillon');
            $table->date('date_emission')->nullable();
            $table->date('date_echeance')->nullable();
            $table->unsignedBigInteger('total')->default(0);
            $table->string('devise', 3)->default('MGA');
            $table->text('conditions')->nullable();
            $table->unsignedInteger('version')->default(1);
            $table->timestampsTz();
            $table->softDeletesTz();
        });

        Schema::create('lignes_facture', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('facture_id')->constrained('factures')->restrictOnDelete();
            $table->string('description');
            $table->decimal('quantite', 12, 3);
            $table->string('unite_snapshot', 30);
            $table->unsignedBigInteger('prix_unitaire');
            $table->unsignedBigInteger('montant_ligne');
            $table->unsignedInteger('version')->default(1);
            $table->timestampsTz();
            $table->softDeletesTz();
            $table->index('facture_id');
        });

        Schema::create('paiements', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('facture_id')->constrained('factures')->restrictOnDelete();
            $table->unsignedBigInteger('montant');
            $table->string('devise', 3)->default('MGA');
            $table->date('date_paiement');
            $table->string('moyen', 20);
            $table->string('reference', 120)->nullable();
            $table->string('statut', 20)->default('confirme');
            $table->text('notes')->nullable();
            $table->string('idempotency_key', 64)->nullable()->unique();
            $table->unsignedInteger('version')->default(1);
            $table->timestampsTz();
            $table->softDeletesTz();
            $table->index(['facture_id', 'statut'], 'idx_paiements_facture');
        });

        Schema::create('depenses', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->date('date_depense');
            $table->string('categorie', 60);
            $table->string('description');
            $table->unsignedBigInteger('montant');
            $table->string('devise', 3)->default('MGA');
            $table->string('moyen', 20);
            $table->string('reference', 120)->nullable();
            $table->unsignedInteger('version')->default(1);
            $table->timestampsTz();
            $table->softDeletesTz();
            $table->index('date_depense');
        });

        MigrationChecks::applique([
        "ALTER TABLE factures ADD CONSTRAINT chk_factures_statut CHECK (statut IN ('brouillon','emise','partiellement_payee','payee','annulee'))",
        "ALTER TABLE factures ADD CONSTRAINT chk_factures_total CHECK (total >= 0)",
        "ALTER TABLE factures ADD CONSTRAINT chk_factures_devise CHECK (devise = 'MGA')",
        "ALTER TABLE lignes_facture ADD CONSTRAINT chk_lf_quantite CHECK (quantite > 0)",
        "ALTER TABLE lignes_facture ADD CONSTRAINT chk_lf_montant CHECK (montant_ligne >= 0)",
        "ALTER TABLE paiements ADD CONSTRAINT chk_paiements_montant CHECK (montant > 0)",
        "ALTER TABLE paiements ADD CONSTRAINT chk_paiements_moyen CHECK (moyen IN ('especes','mobile_money','virement','autre'))",
        "ALTER TABLE paiements ADD CONSTRAINT chk_paiements_statut CHECK (statut IN ('en_attente','confirme','annule'))",
        "ALTER TABLE depenses ADD CONSTRAINT chk_depenses_montant CHECK (montant > 0)",
        "ALTER TABLE depenses ADD CONSTRAINT chk_depenses_moyen CHECK (moyen IN ('especes','mobile_money','virement','autre'))",
        ]);
    }

    public function down(): void
    {
        foreach (['depenses', 'paiements', 'lignes_facture', 'factures'] as $t) {
            Schema::dropIfExists($t);
        }
    }
};
