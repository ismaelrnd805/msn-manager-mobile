<?php

use App\Support\MigrationChecks;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Tables de référence : clients, contacts, services, tarifs, modeles_messages.
 * Source : spec MSN Manager V1 §5 — conversions PostgreSQL appliquées :
 *  - UUID natifs, TIMESTAMPTZ, montants entiers (MGA), version d'objet par ligne.
 * Corrections documentées (docs/01-jalon0-inspection.md) : aucune sur ce lot.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('clients', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('type_client', 20);
            $table->string('nom_affiche');
            $table->string('nom_legal')->nullable();
            $table->string('telephone_principal', 40)->nullable();
            $table->string('email_principal', 190)->nullable();
            $table->text('adresse')->nullable();
            $table->text('notes')->nullable();
            $table->boolean('actif')->default(true);
            $table->unsignedInteger('version')->default(1);
            $table->timestampsTz();
            $table->softDeletesTz();
            $table->index('nom_affiche');
            $table->index('telephone_principal');
            $table->index('email_principal');
        });

        Schema::create('contacts', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('client_id')->constrained('clients')->restrictOnDelete();
            $table->string('nom');
            $table->string('role')->nullable();
            $table->string('telephone', 40)->nullable();
            $table->string('email', 190)->nullable();
            $table->string('canal_prefere', 20)->nullable();
            $table->boolean('principal')->default(false);
            $table->unsignedInteger('version')->default(1);
            $table->timestampsTz();
            $table->softDeletesTz();
            $table->index('client_id');
        });

        Schema::create('services', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('code', 40)->unique();
            $table->string('nom');
            $table->text('description')->nullable();
            $table->string('categorie', 60);
            $table->string('unite_tarifaire', 30);
            $table->boolean('actif')->default(true);
            $table->boolean('necessite_cahier_charges')->default(false);
            $table->json('questions_qualification_json')->default('[]');
            $table->unsignedInteger('version')->default(1);
            $table->timestampsTz();
            $table->softDeletesTz();
        });

        Schema::create('tarifs', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('service_id')->constrained('services')->restrictOnDelete();
            $table->unsignedBigInteger('prix_unitaire'); // entiers MGA
            $table->string('devise', 3)->default('MGA');
            $table->date('date_debut_validite');
            $table->date('date_fin_validite')->nullable();
            $table->boolean('actif')->default(true);
            $table->unsignedInteger('version')->default(1);
            $table->timestampsTz();
            $table->softDeletesTz();
            $table->index(['service_id', 'date_debut_validite', 'date_fin_validite'], 'idx_tarifs_service_dates');
        });

        Schema::create('modeles_messages', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('code', 60)->unique();
            $table->string('nom');
            $table->string('objectif', 120);
            $table->string('canal', 20);
            $table->text('corps_template');
            $table->json('variables_json')->default('[]');
            $table->boolean('actif')->default(true);
            $table->unsignedInteger('version')->default(1);
            $table->timestampsTz();
            $table->softDeletesTz();
        });

        // Contraintes CHECK (syntaxe partagée SQLite/PostgreSQL)
        MigrationChecks::applique([
        "ALTER TABLE clients ADD CONSTRAINT chk_clients_type CHECK (type_client IN ('particulier','entreprise'))",
        "ALTER TABLE clients ADD CONSTRAINT chk_clients_actif CHECK (actif IN (TRUE,FALSE))",
        "ALTER TABLE clients ADD CONSTRAINT chk_clients_version CHECK (version >= 1)",
        "ALTER TABLE contacts ADD CONSTRAINT chk_contacts_canal CHECK (canal_prefere IS NULL OR canal_prefere IN ('messenger','whatsapp','email','telephone','autre'))",
        "ALTER TABLE contacts ADD CONSTRAINT chk_contacts_principal CHECK (principal IN (TRUE,FALSE))",
        "ALTER TABLE tarifs ADD CONSTRAINT chk_tarifs_prix CHECK (prix_unitaire >= 0)",
        "ALTER TABLE tarifs ADD CONSTRAINT chk_tarifs_devise CHECK (devise = 'MGA')",
        "ALTER TABLE tarifs ADD CONSTRAINT chk_tarifs_dates CHECK (date_fin_validite IS NULL OR date_fin_validite >= date_debut_validite)",
        "ALTER TABLE modeles_messages ADD CONSTRAINT chk_modeles_canal CHECK (canal IN ('messenger','whatsapp','email','telephone','autre'))",
        ]);
    }

    public function down(): void
    {
        Schema::dropIfExists('modeles_messages');
        Schema::dropIfExists('tarifs');
        Schema::dropIfExists('services');
        Schema::dropIfExists('contacts');
        Schema::dropIfExists('clients');
    }
};
