<?php

use App\Support\MigrationChecks;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Audit, appareils, séquences de numérotation et suivi de synchronisation serveur.
 * Ajouts justifiés :
 *  - sync_journal (C8) : séquence monotone globale pour le pull paginé (spec §8.4) ;
 *  - sync_push_log : journal d'idempotence du push (spec §8.3 point 3) ;
 *  - sequences : numérotation atomique DEV/CMD/FAC/DEVIS (spec §12).
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('journal_actions', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('entite_type', 60);
            $table->uuid('entite_id');
            $table->string('action', 60);
            $table->json('avant_json')->nullable();
            $table->json('apres_json')->nullable();
            $table->text('motif')->nullable();
            $table->uuid('appareil_id')->nullable();
            $table->string('acteur_id', 64)->nullable(); // extensible : id utilisateur ou UUID appareil (spec §5.1)
            $table->timestampTz('date_action');
            $table->timestampsTz();
            $table->index(['entite_type', 'entite_id', 'date_action'], 'idx_journal_entite');
        });

        Schema::create('appareils', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignId('user_id')->constrained('users')->restrictOnDelete();
            $table->string('nom');
            $table->string('plateforme', 20);
            $table->timestampTz('dernier_sync_at')->nullable();
            $table->boolean('actif')->default(true);
            $table->timestampsTz();
        });

        Schema::create('sequences', function (Blueprint $table) {
            $table->id();
            $table->string('code', 20); // DEVIS / CMD / FAC
            $table->unsignedInteger('annee');
            $table->unsignedBigInteger('dernier_numero')->default(0);
            $table->timestamps();
            $table->unique(['code', 'annee']);
        });

        Schema::create('sync_journal', function (Blueprint $table) {
            $table->bigIncrements('seq');
            $table->uuid('entite_id');
            $table->string('entite_type', 60);
            $table->unsignedInteger('version');
            $table->boolean('tombstone')->default(false);
            $table->json('payload_json');
            $table->timestampTz('created_at');
            $table->index(['seq', 'entite_type']);
        });

        Schema::create('sync_push_log', function (Blueprint $table) {
            $table->string('idempotency_key', 64)->primary();
            $table->uuid('device_id');
            $table->uuid('operation_id');
            $table->string('resultat', 20);
            $table->json('resultat_json')->nullable();
            $table->timestampTz('created_at');
        });

        MigrationChecks::applique([
        "ALTER TABLE appareils ADD CONSTRAINT chk_appareils_plateforme CHECK (plateforme IN ('android','windows'))",
        ]);
    }

    public function down(): void
    {
        foreach (['sync_push_log', 'sync_journal', 'sequences', 'appareils', 'journal_actions'] as $t) {
            Schema::dropIfExists($t);
        }
    }
};
