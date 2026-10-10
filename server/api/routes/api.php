<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\DevicesController;
use App\Http\Controllers\Api\V1\ClientsController;
use App\Http\Controllers\Api\V1\CatalogueController;
use App\Http\Controllers\Api\V1\DemandesController;
use App\Http\Controllers\Api\V1\DevisController;
use App\Http\Controllers\Api\V1\CommandesController;
use App\Http\Controllers\Api\V1\FinanceController;
use App\Http\Controllers\Api\V1\CommunicationsController;
use App\Http\Controllers\Api\V1\PublicationsFacebookController;
use App\Http\Controllers\Api\V1\SyncController;
use App\Http\Controllers\Api\V1\AttachmentsController;
use App\Http\Controllers\Api\V1\AuditController;

/*
|--------------------------------------------------------------------------
| API v1 — MSN Manager (spec §7)
|--------------------------------------------------------------------------
| Toutes les routes sont authentifiées sauf login. Les transitions sensibles
| passent par des actions explicites avec expected_version — aucun PATCH
| générique ne permet d'écrire un statut arbitraire (spec §8).
*/

// Auth publique (limitation de débit : 5/min par IP)
Route::prefix('auth')->middleware('throttle:auth')->group(function () {
    Route::post('/login', [AuthController::class, 'login']);
});

Route::prefix('auth')->middleware(['auth:sanctum', 'throttle:auth'])->group(function () {
    Route::post('/refresh', [AuthController::class, 'refresh']);
    Route::post('/logout', [AuthController::class, 'logout']);
});

// Appareils
Route::middleware(['auth:sanctum', 'throttle:metier'])->group(function () {
    Route::post('/devices/register', [DevicesController::class, 'register']);
    Route::delete('/devices/{deviceId}', [DevicesController::class, 'revoke']);
});

// Synchronisation (limitation spécifique : 30/min)
Route::prefix('sync')->middleware(['auth:sanctum', 'throttle:auth'])->group(function () {
    Route::post('/push', [SyncController::class, 'push']);
    Route::get('/pull', [SyncController::class, 'pull']);
    Route::get('/status', [SyncController::class, 'status']);
});

// Pièces jointes (transfert séparé du push/pull)
Route::middleware(['auth:sanctum', 'throttle:metier'])->group(function () {
    Route::get('/attachments', [AttachmentsController::class, 'index']);
    Route::post('/attachments', [AttachmentsController::class, 'declare']);
    Route::put('/attachments/{id}/content', [AttachmentsController::class, 'contenu']);
    Route::post('/attachments/{id}/complete', [AttachmentsController::class, 'complete']);
    Route::get('/attachments/{id}/download', [AttachmentsController::class, 'telecharge']);
});

// Ressources métier
Route::middleware(['auth:sanctum', 'throttle:metier'])->group(function () {
    // Clients et contacts
    Route::get('/clients', [ClientsController::class, 'index']);
    Route::post('/clients', [ClientsController::class, 'store']);
    Route::get('/clients/duplicates', [ClientsController::class, 'doublons']);
    Route::get('/clients/{id}', [ClientsController::class, 'show']);
    Route::patch('/clients/{id}', [ClientsController::class, 'update']);
    Route::delete('/clients/{id}', [ClientsController::class, 'destroy']);
    Route::get('/clients/{id}/history', [ClientsController::class, 'historique']);
    Route::get('/contacts', [ClientsController::class, 'index']); //ContactsController::class, 'index'
    Route::post('/contacts', [\App\Http\Controllers\Api\V1\ContactsController::class, 'store']);
    Route::get('/contacts/{id}', [\App\Http\Controllers\Api\V1\ContactsController::class, 'show']);
    Route::patch('/contacts/{id}', [\App\Http\Controllers\Api\V1\ContactsController::class, 'update']);
    Route::delete('/contacts/{id}', [\App\Http\Controllers\Api\V1\ContactsController::class, 'destroy']);

    // Catalogue
    Route::get('/services', [CatalogueController::class, 'servicesIndex']);
    Route::post('/services', [CatalogueController::class, 'servicesStore']);
    Route::get('/services/{id}', [CatalogueController::class, 'servicesShow']);
    Route::patch('/services/{id}', [CatalogueController::class, 'servicesUpdate']);
    Route::get('/tarifs', [CatalogueController::class, 'tarifsIndex']);
    Route::post('/tarifs', [CatalogueController::class, 'tarifsStore']);
    Route::get('/messages/templates', [CatalogueController::class, 'templatesIndex']);
    Route::post('/messages/templates', [CatalogueController::class, 'templatesStore']);

    // Demandes
    Route::get('/demandes', [DemandesController::class, 'index']);
    Route::post('/demandes', [DemandesController::class, 'store']);
    Route::get('/demandes/{id}', [DemandesController::class, 'show']);
    Route::patch('/demandes/{id}', [DemandesController::class, 'update']);
    Route::post('/demandes/{id}/present-offer', [DemandesController::class, 'presenteOffre']);
    Route::post('/demandes/{id}/prepare-quote', [DemandesController::class, 'prepareQuote']);
    Route::post('/demandes/{id}/transition', [DemandesController::class, 'transition']);
    Route::post('/demandes/{id}/qualifications', [DemandesController::class, 'qualifications']);

    // Devis
    Route::get('/devis', [DevisController::class, 'index']);
    Route::post('/devis', [DevisController::class, 'store']);
    Route::get('/devis/{id}', [DevisController::class, 'show']);
    Route::post('/devis/{id}/present', [DevisController::class, 'presente']);
    Route::post('/devis/{id}/accept', [DevisController::class, 'accepte']);
    Route::post('/devis/{id}/request-change', [DevisController::class, 'demandeModification']);
    Route::post('/devis/{id}/reject', [DevisController::class, 'refuse']);
    Route::post('/devis/{id}/revise', [DevisController::class, 'revise']);

    // Commandes
    Route::get('/commandes', [CommandesController::class, 'index']);
    Route::post('/commandes', [CommandesController::class, 'store']);
    Route::get('/commandes/{id}', [CommandesController::class, 'show']);
    Route::post('/commandes/{id}/transition', [CommandesController::class, 'transition']);
    Route::post('/commandes/{id}/projects', [CommandesController::class, 'ajouteProjet']);
    Route::post('/commandes/{id}/delivery', [CommandesController::class, 'livraison']);
    Route::post('/commandes/{id}/tasks', [CommandesController::class, 'ajouteTache']);
    Route::post('/commandes/{id}/lignes', [CommandesController::class, 'ajouteLigne']);
    Route::patch('/tasks/{taskId}', [CommandesController::class, 'transitionTache']);

    // Finances
    Route::post('/commandes/{commandeId}/invoice', [FinanceController::class, 'creeDepuisCommande']);
    Route::get('/factures', [FinanceController::class, 'indexFactures']);
    Route::get('/factures/{id}', [FinanceController::class, 'showFacture']);
    Route::patch('/factures/{id}', [FinanceController::class, 'updateFacture']);
    Route::post('/factures/{id}/rectify', [FinanceController::class, 'rectifie']);
    Route::post('/factures/{id}/payments', [FinanceController::class, 'ajoutePaiement']);
    Route::patch('/payments/{id}', [FinanceController::class, 'updatePaiement']);
    Route::get('/finance/summary', [FinanceController::class, 'synthese']);
    Route::get('/depenses', [FinanceController::class, 'indexDepenses']);
    Route::post('/depenses', [FinanceController::class, 'storeDepense']);

    // Communications et planning Facebook
    Route::get('/communications', [CommunicationsController::class, 'index']);
    Route::post('/communications/prepare', [CommunicationsController::class, 'prepare']);
    Route::post('/communications', [CommunicationsController::class, 'store']);
    Route::post('/communications/{id}/mark-copied', [CommunicationsController::class, 'markCopied']);
    Route::post('/communications/{id}/confirm-manual-send', [CommunicationsController::class, 'confirmManualSend']);
    Route::get('/facebook/publications', [PublicationsFacebookController::class, 'index']);
    Route::post('/facebook/publications', [PublicationsFacebookController::class, 'store']);
    Route::patch('/facebook/publications/{id}', [PublicationsFacebookController::class, 'update']);

    // Audit
    Route::get('/audit', [AuditController::class, 'index']);
});
