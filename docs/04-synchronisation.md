# 04 — Synchronisation

Le moteur (`lib/core/sync/sync_engine.dart`) applique la stratégie offline-first : file locale, puis PUSH/PULL quand un serveur est configuré, conflits jamais résolus en silence.

## 1. La file d'attente `sync_queue`

| Colonne | Rôle |
|---|---|
| `entite`, `entityId` | Cible, ex. `'clients'` / `cli_173…` (nom de table côté serveur). |
| `operation` | `SyncOperation.create / update / delete` (persisté par `.name`). |
| `payload` | JSON sérialisé des champs métier. |
| `statut` | `enAttente` (défaut), `enCours`, `synchronise`, `erreur`, `conflit`. |
| `tentatives`, `derniereErreur` | Compteur d'échecs + dernier message (seuil `syncMaxAttempts = 5`). |
| `createdAt`, `updatedAt` | Ordre de traitement et horodatage poussé au serveur. |

Enfilement (appelé par toutes les écritures métier) :

```dart
await ref.read(syncEngineProvider).enqueue(
      entite: 'clients', entityId: id,
      operation: SyncOperation.create,
      payload: {'nom': client.nom, 'telephone': client.telephone},
    );
```

## 2. Cycle PUSH — `POST /api/v1/sync/batch`

1. `SystemDao.pending(limit: syncBatchSize)` : statuts `enAttente` + `erreur`, ordre `createdAt ASC`.
2. Chaque ligne devient un `SyncPayload` (`api_contracts.dart`) : `entite, entityId, operation, payload, updatedAt, deviceId`.
3. Corps HTTP : `{'deviceId': deviceId, 'changes': [ … ]}` vers `$serverUrl/api/v1/sync/batch`.
4. Réponse `PushBatchResult` : `acceptedIds` -> statut `synchronise` ; `conflictIds` -> statut `conflit` + ligne dans `sync_conflicts` (`_createConflict`, message « Le serveur a une version plus récente. »).
5. `NetworkException` -> `incrementTentative` sur chaque ligne ; **rien n'est perdu**, le cycle suivant rejoue.

## 3. Cycle PULL — `GET /api/v1/sync/changes?since=…`

1. `since` = clé `last_sync_at` (epoch si première sync).
2. Réponse : liste de `RemoteChange { entite, entityId, payload, serverUpdatedAt, version }`.
3. Chaque changement passe par `_applyRemote` :
   - **pas d'applier** pour l'entité -> le changement est ré-enfilé dans `sync_queue` (statut `enAttente`) : jamais perdu, traité dès qu'un applier existera ;
   - **écriture locale en attente pour la même entité** (`sync_queue` contient `enAttente`/`erreur` pour `entite+entityId`) -> conflit créé dans `sync_conflicts`, application refusée ;
   - sinon l'applier applique le payload localement (upsert).
4. `last_sync_at` est mis à jour même si le pull échoue après un push réussi (le push est déjà comptabilisé côté serveur).

## 4. Conflits : jamais d'écrasement silencieux

Deux détections complémentaires :
- **Côté push** : le serveur répond `conflicts` quand il détient une version plus récente (comparaison `updatedAt` + `version`, voir 05-backend-nestjs.md).
- **Côté pull** : le mobile refuse d'appliquer un changement distant si une écriture locale de la même entité dort encore dans la file.

Table `sync_conflicts` : `entite, entityId, localPayload, remotePayload, statut ('ouvert'/'resolu-…'), detecteLe, resoluLe`. Résolution humaine depuis l'écran `/sync` (réservée admin : `AppPermissions.canResolveConflicts`) :

```dart
await ref.read(systemDaoProvider).resolveConflict(id, 'garde-local'); // ou 'garde-distant'
```

Tant qu'un conflit est ouvert, le rapport de cycle renvoie `SyncStatus.erreur` avec « N conflit(s) à résoudre. » — l'état ne repasse jamais « SYNCHRONISÉ » silencieusement.

## 5. Ajouter un applier d'entité (exemple `clients`)

Un applier est un `RemoteEntityApplier` : `Future<bool> Function(String entityId, Map<String, dynamic> payload)` enregistré dans `SyncEngine.remoteAppliers`. Il traduit un payload serveur en upsert local. Exemple complet :

```dart
// core/sync/appliers.dart (nouveau fichier) ou wiring dans services_providers.dart
void registerAppliers(Ref ref) {
  final db = ref.read(appDatabaseProvider);
  final engine = ref.read(syncEngineProvider);

  engine.remoteAppliers['clients'] = (entityId, payload) async {
    final existing = await (db.select(db.clients)
          ..where((c) => c.id.equals(entityId)))
        .getSingleOrNull();
    final row = ClientsCompanion.insert(
      id: entityId,
      nom: payload['nom'] as String? ?? existing?.nom ?? '',
      telephone: Value(payload['telephone'] as String? ?? existing?.telephone),
      email: Value(payload['email'] as String? ?? existing?.email),
      updatedAt: Value(DateTime.now()),
      lastSyncedAt: Value(DateTime.now()),     // marqueur de sync
    );
    await db.into(db.clients).insertOnConflictUpdate(
          existing == null ? row : row.copyWith(id: Value(entityId)),
        );
    return true; // true = appliqué (comptabilisé dans SyncRunReport.pulled)
  };
}
```

Règles d'écriture d'un applier : jamais jeter de données (fusionner avec `existing`), poser `lastSyncedAt`, retourner `false` seulement si l'application doit être retentée, et n'appeler **aucun** `enqueue` (on applique du distant, on ne ré-enfile pas).

## 6. Configuration de l'URL serveur

- Clé `settings.server_url` (`AppConstants.keyServerUrl`), saisie par l'administrateur dans l'écran `/settings` (ex. `http://192.168.1.20:3000`, sans `/` final).
- `SyncEngine.run` : si la clé est absente/vide -> `SyncStatus.nonConfigure`, aucun appel HTTP, aucune donnée envoyée.
- `deviceId` : `mobile-<timestamp>` par défaut (ou injecté via le constructeur) ; il identifie l'appareil dans chaque lot poussé.
- Le client REST (`ApiClient`) préfixe toutes les routes par `/api/v1` et envoie `Authorization: Bearer <token>` dès qu'un `authToken` est fourni ; les erreurs réseau lèvent `NetworkException` (timeout 15 s).

## 7. Déclenchements

| Déclencheur | Code |
|---|---|
| Retour du réseau | `SyncController` écoute `connectivityProvider` -> `runNow()`. |
| Périodique | `Timer.periodic` 5 minutes. |
| Manuel | Bouton de l'écran `/sync` -> `syncControllerProvider.runNow()`. |
| Statut instantané (sans cycle) | `SyncEngine.currentStatus()` : OFFLINE / NON CONFIGURÉ / ONLINE. |
