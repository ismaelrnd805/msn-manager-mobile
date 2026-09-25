# 01 — Architecture

Application Flutter « MSN Manager Mobile » (paquet `msn_manager_mobile`), métier offline-first pour MSN — Multi-Services Numériques (Madagascar, montants en Ariary entiers). State management Riverpod 2, persistance Drift/SQLite, navigation go_router, génération de documents pdf+printing.

## 1. Vue d'ensemble des couches

```
+--------------------------------------------------------------------------+
|  UI — lib/features/*  (écrans ConsumerWidget, 100% français)             |
|  dashboard, clients, requests, catalog, quotes, invoices, payments,      |
|  orders, communication, documents, tasks, sync, settings, more, shell,   |
|  splash, auth                                                            |
+------------------------------------+-------------------------------------+
                                     | ref.watch / ref.read
+------------------------------------v-------------------------------------+
|  PROVIDERS RIVERPOD                                                      |
|  - core/providers/database_provider.dart  (appDatabaseProvider + DAOs)   |
|  - core/providers/services_providers.dart (services, session, sync)      |
|  - features/*/*_providers.dart            (StreamProvider par écran)     |
+------------------+--------------------------+----------------------------+
                   |                          |
+------------------v-----------+  +-----------v---------------------------+
|  DAOs DRIFT (core/database/  |  |  SERVICES (core/services/)           |
|  daos/ : ClientsDao,         |  |  numbering_service, pdf_service,     |
|  RequestsDao, CatalogDao,    |  |  backup_service, share_service,      |
|  DocumentsDao, PaymentsDao,  |  |  notification_service, reminder_     |
|  OrdersDao, WorkflowsDao,    |  |  service, activity_logger,           |
|  TemplatesDao, SystemDao     |  |  file_ingest_service                 |
+------------------+-----------+  +--------------------------------------+
                   |                     +  core/domain (logique PURE,     |
+------------------v-----------+          |  testable sans Flutter)         |
|  SQLITE (Drift, 28 tables)   |  +-------v--------------------------------+
|  msn_manager/msn_manager.    |  | sync_engine -> sync_queue -> ApiClient |
|  sqlite via NativeDatabase   |  | (core/sync/) — push/pull, conflits    |
|  .createInBackground         |  +---------------------------------------+
+------------------------------+
```

## 2. Principes

1. **Offline-first** : toute écriture est locale d'abord (SQLite), puis mise en file d'attente `sync_queue`. L'application fonctionne à 100% sans Internet et sans serveur (voir 03-offline-first.md).
2. **Modularité** : chaque fonctionnalité est un module activable (table `module_flags`, registre `core/modules/module_registry.dart`). Désactiver un module met à jour l'UI instantanément via un `StreamProvider`.
3. **Un flux = une feature** : un dossier `lib/features/<flux>/` contient l'écran, les providers et les formulaires du flux (demande, devis, facture…). Aucune logique métier dispersée.
4. **Logique pure dans `core/domain`** : `quote_calculator`, `business_rules`, `workflow_engine`, `transfer_checklist`, `template_engine` ne dépendent ni Flutter ni Drift et sont couverts par les tests de `test/`.
5. **Montants en `int`** : l'Ariary n'a pas de sous-unité en pratique ; pas de flottants dans les totaux (`QuoteCalculator`).
6. **Aucun singleton implicite** : tout est résolu par Riverpod (`core/providers/services_providers.dart` : « chaque écran consomme des providers »).

## 3. Conventions de nommage

| Élément | Convention | Exemples réels |
|---|---|---|
| Fichiers | snake_case | `quote_edit_screen.dart`, `payments_providers.dart` |
| Classes | PascalCase | `ClientsDao`, `SyncEngine`, `PdfService` |
| Classes utilitaires | constructeur privé | `QuoteCalculator._()`, `RuleKeys._()` |
| Providers Riverpod | suffixe `Provider` | `clientsDaoProvider`, `sessionProvider`, `syncControllerProvider` |
| Écrans | `<flux>_screen.dart` | `invoice_detail_screen.dart` |
| Providers de feature | `<flux>_providers.dart` | `orders_providers.dart` |
| Énumérations | libellé français | `SyncStatus.offline('OFFLINE')` |
| Identifiants | préfixe métier | `cli_`, `req_`, `dev_`, `cmd_`, `fac_`, `pmt_`, `wf_`, `wfi_`, `sq_`, `cf_` |
| Doc-commentaires | `///` français + `library;` | en tête de chaque fichier |

## 4. Structure des dossiers

```
lib/
  main.dart                 # WidgetsFlutterBinding + ProviderScope(MsnApp)
  app.dart                  # appStartupProvider (seed, notif, sync) + MaterialApp.router
  core/
    constants/app_constants.dart   # AppConstants, RuleKeys
    theme/msn_theme.dart           # MsnColors (#0B4FA8, #00B8D4), MsnTheme.light()
    router/app_router.dart         # GoRouter : 5 onglets + routes de détail
    utils/                         # formatters, validators, id_generator
    errors/app_exception.dart      # AppException, PermissionException, NetworkException…
    database/
      app_database.dart            # AppDatabase (schemaVersion 3, migrations)
      tables.dart                  # 28 tables Drift
      converters.dart              # convertisseurs enum <-> texte
      daos/                        # 9 DAOs par domaine
      seed/demo_data.dart          # DemoData.seedIfNeeded + hashPin
    domain/                        # quote_calculator, business_rules, workflow_engine,
                                   # transfer_checklist, template_engine, enums
    auth/session.dart              # Session, AppPermissions, SessionNotifier
    modules/module_registry.dart   # ModuleCatalog, ModuleRegistry, moduleRegistryProvider
    services/                      # numbering, pdf/ (pdf_service, pdf_theme), backup,
                                   # share, notification, reminder, connectivity,
                                   # file_ingest, activity_logger
    sync/                          # sync_engine, api_client, api_contracts, sync_provider
    providers/                     # database_provider, services_providers
  features/                        # un dossier par flux (voir section 1)
  shared/widgets/                  # cards, badges, form_fields, feedback, empty_state,
                                   # copy_message_card
test/                              # quote_calculator, template_engine, id_generator,
                                   # business_rules, workflow_engine, transfer_checklist
```

## 5. Cycle de données (écriture)

Exemple réel : enregistrement d'un client (`features/clients/client_edit_screen.dart`).

```dart
await ref.read(clientsDaoProvider).upsert(client);          // 1. SQLite (immédiat)
await ref.read(syncEngineProvider).enqueue(                  // 2. File de sync
      entite: 'clients', entityId: id,
      operation: isNew ? SyncOperation.create : SyncOperation.update,
      payload: {'nom': client.nom, 'telephone': client.telephone, 'email': client.email},
    );
await ref.read(activityLoggerProvider).log(                  // 3. Journal d'activité
      action: ActivityAction.creation, entite: 'client', entityId: id, details: '…');
```

Cycle de lecture : `UI -> StreamProvider -> DAO.watch() -> SQLite`. Drift réémet automatiquement les listes à chaque écriture sur une table : aucun « refresh » manuel dans l'UI.

## 6. Gestion d'état Riverpod

| Provider | Type | Rôle |
|---|---|---|
| `appDatabaseProvider` | `Provider<AppDatabase>` | Instance unique de la base (fermée via `ref.onDispose`). |
| `<domaine>DaoProvider` (9) | `Provider<…Dao>` | DAOs clients, requests, catalog, documents, payments, orders, workflows, templates, system. |
| `numberingServiceProvider` | `Provider<NumberingService>` | Références REQ/DEV/CMD/FAC/PMT (compteurs annuels). |
| `pdfServiceProvider`, `shareServiceProvider`, `backupServiceProvider`, `notificationServiceProvider`, `reminderServiceProvider`, `fileIngestServiceProvider` | `Provider<…>` | Services de documents, partage, sauvegarde, notifications. |
| `connectivityServiceProvider` / `connectivityProvider` | `Provider` / `StreamProvider<bool>` | État online/offline (connectivity_plus). |
| `syncEngineProvider` | `Provider<SyncEngine>` | Moteur push/pull ; `enqueue()` appelé par les écritures métier. |
| `syncControllerProvider` | `NotifierProvider<SyncController, SyncState>` | Statut affiché (ONLINE/OFFLINE/…), cycle auto à la reconnexion + toutes les 5 min. |
| `sessionProvider` | `NotifierProvider<SessionNotifier, Session?>` | Session courante (nom + rôle) ; `null` = déconnecté. |
| `activityLoggerProvider` | `Provider<ActivityLogger>` | Journal, attribue l'utilisateur courant depuis la session. |
| `moduleRegistryProvider` | `StreamProvider<ModuleRegistry>` | Codes de modules actifs (source : table `module_flags`). |
| `appRouterProvider` | `Provider<GoRouter>` | Navigation + redirection par session/rôle. |
| `appStartupProvider` | `FutureProvider<void>` | Seed démo, init notifications, amorçage sync, rappels échus. |
| Providers de feature | `StreamProvider` / `StateProvider` / `StreamProvider.family` | Listes réactives par écran, ex. `clientsProvider`, `clientsSearchProvider`, `clientOrdersProvider`. |

## 7. Navigation

`appRouterProvider` (go_router 14) définit une `StatefulShellRoute.indexedStack` à 5 branches : `/dashboard`, `/requests`, `/orders`, `/clients`, `/more`. Le `redirect` impose une session (sauf `/`, `/login`) et réserve les sous-routes `/settings/*` au rôle admin. Les écrans de détail utilisent des paramètres de chemin (`/orders/:id`, `/clients/:id/edit`) ou de requête (`/quotes/new?requestId=…`).
