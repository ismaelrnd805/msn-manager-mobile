<?php

use App\Support\MigrationChecks;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Pièces jointes : métadonnées en base, contenu sur disque serveur / local client.
 * SHA-256 obligatoire pour le transfert (spec §8, §9 fichiers).
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pieces_jointes', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('client_id')->nullable()->constrained('clients')->restrictOnDelete();
            $table->foreignUuid('demande_id')->nullable()->constrained('demandes')->restrictOnDelete();
            $table->foreignUuid('commande_id')->nullable()->constrained('commandes')->restrictOnDelete();
            $table->foreignUuid('projet_id')->nullable()->constrained('projets')->restrictOnDelete();
            $table->string('nom_fichier');
            $table->string('mime_type', 120);
            $table->unsignedBigInteger('taille_octets');
            $table->string('sha256', 64);
            $table->string('chemin_local')->nullable();      // chemin côté client
            $table->string('cle_stockage_distant')->nullable(); // clé de stockage côté serveur
            $table->string('statut_transfert', 30)->default('local');
            $table->unsignedInteger('version')->default(1);
            $table->timestampsTz();
            $table->softDeletesTz();
            $table->index('sha256');
        });

        MigrationChecks::applique([
        'ALTER TABLE pieces_jointes ADD CONSTRAINT chk_pj_rattachement CHECK (client_id IS NOT NULL OR demande_id IS NOT NULL OR commande_id IS NOT NULL OR projet_id IS NOT NULL)',
        'ALTER TABLE pieces_jointes ADD CONSTRAINT chk_pj_taille CHECK (taille_octets >= 0)',
        ]);
        MigrationChecks::applique([
        "ALTER TABLE pieces_jointes ADD CONSTRAINT chk_pj_statut CHECK (statut_transfert IN ('local','a_transferer','transfert_en_cours','synchronise','echec'))",
        ]);
    }

    public function down(): void
    {
        Schema::dropIfExists('pieces_jointes');
    }
};
