# 02 — Données et migrations

La base locale est Drift/SQLite, définie dans `lib/core/database/app_database.dart` (classe `AppDatabase`, `schemaVersion = 3`) et `lib/core/database/tables.dart` (28 tables). Référence complète des colonnes : `database/schema.md`.

## 1. Les 28 tables par domaine

| Domaine | Tables |
|---|---|
| Utilisateurs & sécurité | `users` |
| CRM | `clients` |
| Catalogue | `categories`, `services` |
| Demandes | `requests` |
| Qualification dynamique | `qualification_forms`, `qualification_questions` |
| Workflows | `workflow_templates`, `workflow_steps`, `workflow_instances`, `workflow_step_states` |
| Règles métier | `business_rules`, `rule_exceptions` |
| Devis | `quotes`, `quote_items` |
| Factures | `invoices`, `invoice_items` |
| Paiements | `payments` |
| Commandes | `orders`, `order_files` |
| Communication | `message_templates` |
| Rappels & tâches | `reminders`, `tasks` |
| Journal & paramètres | `activity_log`, `settings`, `module_flags` |
| Synchronisation | `sync_queue`, `sync_conflicts` |

Colonnes transverses des tables métier : `createdAt` / `updatedAt` (traçabilité), `lastSyncedAt` (marqueur de sync, nullable), `deletedAt` (corbeille). Les clés primaires sont des `TEXT id` (UUID ou préfixe + horodatage, ex. `cli_173…`), les FK sont déclarées avec `.references(...)` et `PRAGMA foreign_keys = ON` est activé dans `beforeOpen`.

## 2. Suppression douce / corbeille

Aucune suppression métier n'est physique : `softDelete` écrit `deletedAt = now` et `updatedAt = now` (extrait réel de `ClientsDao`) :

```dart
Future<void> softDelete(String id) =>
    (update(clients)..where((c) => c.id.equals(id))).write(
      ClientsCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );

Future<void> restore(String id) =>
    (update(clients)..where((c) => c.id.equals(id))).write(
      const ClientsCompanion(deletedAt: Value(null)),
    );
```

- Les listes filtrent toujours `deletedAt.isNull()` (`watchAll`), la corbeille lit `deletedAt.isNotNull()` (`watchDeleted`).
- La restauration remet `deletedAt` à `NULL` (écran Administration > Corbeille, `/settings/trash`).
- La **purge définitive** (`purge` = `DELETE FROM`) est réservée à l'admin après double confirmation (`AppPermissions.canPurgeTrash`).

## 3. Chaîne de migrations implémentée (v1 -> v2 -> v3)

Extrait exact de `app_database.dart` :

```dart
@override
int get schemaVersion => 3;

@override
MigrationStrategy get migration => MigrationStrategy(
      onCreate: (m) => m.createAll(),
      onUpgrade: (m, from, to) async {
        // Migration v1 -> v2 : index de performance + table des tâches.
        if (from < 2) {
          await m.createTable(tasks);
          await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_orders_statut ON orders (statut);');
        }
        // Migration v2 -> v3 : index synchronisation + paiement.
        if (from < 3) {
          await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_sync_queue_statut ON sync_queue (statut);');
          await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_payments_invoice ON payments (invoice_id);');
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
```

Points clés :
- Les blocs `if (from < N)` sont **cumulatifs** : un appareil en v1 exécute v1->v2 puis v2->v3 dans le même passage.
- `onCreate` crée tout à la version courante (nouvelles installations ne rejouent pas les migrations).
- La version constante `AppConstants.databaseSchemaVersion` (vaut 3) doit suivre `schemaVersion` (utilisée par les exports de sauvegarde JSON).

## 4. TUTORIEL — migration v3 -> v4 : ajouter `clients.statut`

Objectif : ajouter une colonne `statut` (texte) aux clients, avec valeur `'actif'` pour les lignes existantes.

**Règle absolue : ne jamais modifier le schéma sans migration.** Modifier `tables.dart` sans incrémenter `schemaVersion` laisse les bases installées dans un état incohérent (colonnes manquantes, crash au premier `select`).

### Étape 1 — Déclarer la colonne dans `tables.dart`

```dart
class Clients extends Table {
  // … colonnes existantes …
  TextColumn get statut => text().withDefault(const Constant('actif'))();
  // …
}
```

Le `.withDefault` est indispensable : SQLite l'applique aussi aux lignes existantes lors du `ALTER TABLE ADD COLUMN`.

### Étape 2 — Incrémenter la version

Dans `app_database.dart` :

```dart
@override
int get schemaVersion => 4;
```

Et dans `lib/core/constants/app_constants.dart` :

```dart
static const int databaseSchemaVersion = 4;
```

### Étape 3 — Ajouter le bloc de migration

On ajoute un bloc `if (from < 4)` **après** les blocs existants (jamais à leur place, ils restent intacts pour les appareils plus anciens) :

```dart
onUpgrade: (m, from, to) async {
  if (from < 2) { /* … v1 -> v2 (inchangé) … */ }
  if (from < 3) { /* … v2 -> v3 (inchangé) … */ }
  // Migration v3 -> v4 : statut client.
  if (from < 4) {
    await m.addColumn(clients, clients.statut);
  }
},
```

`m.addColumn` génère `ALTER TABLE clients ADD COLUMN statut TEXT NOT NULL DEFAULT 'actif'`. Pour une colonne non nulle sans défaut, il faudrait au contraire créer la colonne nullable puis la remplir en deux passes — préférer toujours un défaut.

### Étape 4 — Régénérer le code Drift

```bash
dart run build_runner build --delete-conflicting-outputs
```

Cela met à jour `app_database.g.dart` (`Client` dataclass, `ClientsCompanion`).

### Étape 5 — Tester

- Lancer l'app sur un appareil ayant déjà des données (la base existante doit migrer sans perte : vérifier que les clients démo `Jean Rakoto`, `Sarah Andriam`, `ABC Entreprise` affichent « actif »).
- Désinstaller puis réinstaller (chemin `onCreate` : `createAll` crée la table complète à v4).
- Si un test est ajouté, il peut vérifier le défaut : `Client(...).statut == 'actif'`.
- Exporter une sauvegarde JSON (Administration) : l'en-tête `schemaVersion` doit valoir 4.

### Checklist de migration

1. Colonne déclarée avec défaut dans `tables.dart`.
2. `schemaVersion` +1 et `AppConstants.databaseSchemaVersion` aligné.
3. Bloc `if (from < N)` ajouté, les anciens blocs non modifiés.
4. `build_runner` relancé, `.g.dart` commité.
5. Test sur base existante ET installation fraîche.
6. Sauvegarde exportable/restorable après migration.
