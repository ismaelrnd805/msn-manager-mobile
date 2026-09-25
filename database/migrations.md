# Migrations — historique et politique

## 1. Politique

La base locale SQLite (Drift) est versionnée par `AppDatabase.schemaVersion` (`lib/core/database/app_database.dart`). Règles non négociables :

1. **Ne jamais modifier le schéma sans migration.** Toute évolution de `tables.dart` (nouvelle table, nouvelle colonne, index) passe par : incrément de `schemaVersion` + bloc `onUpgrade` dédié.
2. **Les migrations sont cumulatives et immuables** : chaque bloc `if (from < N)` reste en place pour toujours. Un appareil en v1 qui ouvre une base v4 exécute successivement les blocs 2, 3 et 4. On ne réécrit jamais un ancien bloc (les appareils déjà migrés s'appuieraient sur un historique faux).
3. **`onCreate` crée tout à la version courante** (`m.createAll()`) : une installation fraîche ne rejoue pas les migrations.
4. **Sauvegarde avant migration** : exporter un JSON (`BackupService.exportToJson`) avant de déployer une mise à jour de schéma sur un appareil réel.
5. **Défauts obligatoires** sur les colonnes ajoutées (`ALTER TABLE ADD COLUMN` s'applique aux lignes existantes).
6. `AppConstants.databaseSchemaVersion` suit `schemaVersion` (en-tête des exports de sauvegarde).
7. Après chaque migration : `dart run build_runner build --delete-conflicting-outputs`, test sur base existante et sur installation neuve.

## 2. Historique

### v1 -> v2 — table des tâches + index commandes

```dart
// Migration v1 -> v2 : index de performance + table des tâches.
if (from < 2) {
  await m.createTable(tasks);
  await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_orders_statut ON orders (statut);');
}
```

- Création de la table `tasks` (tâches avec priorité, échéance, statut).
- Index `idx_orders_statut` sur `orders(statut)` (listes filtrées par statut).

### v2 -> v3 — index synchronisation + paiements

```dart
// Migration v2 -> v3 : index synchronisation + paiement.
if (from < 3) {
  await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_queue_statut ON sync_queue (statut);');
  await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_payments_invoice ON payments (invoice_id);');
}
```

- Index `idx_sync_queue_statut` sur `sync_queue(statut)` (recherche des lignes en attente à chaque cycle de sync).
- Index `idx_payments_invoice` sur `payments(invoice_id)` (totaux payés par facture).

En complément, `beforeOpen` active les clés étrangères à chaque ouverture :

```dart
beforeOpen: (details) async {
  await customStatement('PRAGMA foreign_keys = ON');
},
```

## 3. Exemple complet — migration v3 -> v4 (colonne `clients.statut`)

### 3.1 Modifier `tables.dart`

```dart
class Clients extends Table {
  TextColumn get id => text()();
  TextColumn get nom => text()();
  // … colonnes existantes …
  TextColumn get statut => text().withDefault(const Constant('actif'))();
  // …
}
```

Le défaut `'actif'` garantit que les clients existants (Jean Rakoto, Sarah Andriam, ABC Entreprise) valent `actif` après migration.

### 3.2 Incrémenter les versions

```dart
// app_database.dart
@override
int get schemaVersion => 4;

// app_constants.dart
static const int databaseSchemaVersion = 4;
```

### 3.3 Ajouter le bloc de migration

```dart
onUpgrade: (m, from, to) async {
  if (from < 2) {
    await m.createTable(tasks);
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_orders_statut ON orders (statut);');
  }
  if (from < 3) {
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_sync_queue_statut ON sync_queue (statut);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_payments_invoice ON payments (invoice_id);');
  }
  // Migration v3 -> v4 : statut client.
  if (from < 4) {
    await m.addColumn(clients, clients.statut);
  }
},
```

`m.addColumn` génère `ALTER TABLE clients ADD COLUMN statut TEXT NOT NULL DEFAULT 'actif'`. Les variantes utiles :

| Besoin | API Drift |
|---|---|
| Ajouter une colonne | `await m.addColumn(table, table.colonne);` |
| Créer une table | `await m.createTable(nouvelleTable);` |
| Créer/détruire un index | `customStatement('CREATE INDEX IF NOT EXISTS …')` / `DROP INDEX` |
| Renommer une colonne (SQLite >= 3.25) | `customStatement('ALTER TABLE t RENAME COLUMN a TO b')` |

Cas à éviter en une seule passe : rendre une colonne NOT NULL sans défaut (deux passes : colonne nullable -> remplissage -> recopie), changer un type (recopier via table temporaire). Dans ces cas, écrire la migration pas à pas et la tester sur une copie de base réelle.

### 3.4 Régénérer le code Drift

```bash
dart run build_runner build --delete-conflicting-outputs
```

Vérifier que `app_database.g.dart` contient désormais `statut` dans la classe `Client` et `ClientsCompanion`.

### 3.5 Adapter le code appelant (si nécessaire)

Ici, le défaut rend la colonne transparente : aucun écran ne casse. Si la colonne a un comportement (ex. filtrer les clients « suspendus »), adapter le DAO (`ClientsDao.watchAll`) **après** la migration, jamais avant.

### 3.6 Tester

1. **Appareil existant** (base v3 avec données) : lancer la nouvelle version -> les clients démo affichent « actif », aucune perte, `PRAGMA user_version` vaut 4.
2. **Installation fraîche** : désinstaller/réinstaller -> `onCreate` crée la table complète à v4, seed démo inchangé.
3. **Ancienneté double** (base v1 hypothétique de test) : les blocs 2, 3 puis 4 s'enchaînent.
4. **Sauvegarde** : export JSON avec `schemaVersion: 4` ; restauration sur une base v4 opérationnelle.
5. `flutter test` : les tests métier de `test/` restent verts.

### Checklist finale

- [ ] Colonne déclarée avec défaut dans `tables.dart`
- [ ] `schemaVersion` 4 + `AppConstants.databaseSchemaVersion` 4
- [ ] Bloc `if (from < 4)` ajouté, blocs 2 et 3 inchangés
- [ ] `build_runner` relancé, `.g.dart` généré
- [ ] Test sur base existante ET installation neuve
- [ ] Sauvegarde exportée avant déploiement terrain
