# 03 — Fonctionnement offline-first

L'application est **nativement locale** : elle ne dépend d'aucun serveur pour fonctionner. La synchronisation est une option activée par l'administrateur, jamais une condition de fonctionnement.

## 1. Sans Internet : tout est local

- La base SQLite vit dans le dossier applicatif : `<documents>/msn_manager/msn_manager.sqlite`, ouverte en tâche de fond par `NativeDatabase.createInBackground` (`app_database.dart`).
- Toutes les lectures passent par des `StreamProvider` alimentés par `DAO.watch()` (Drift) : l'UI se met à jour depuis SQLite, sans aucun réseau.
- Toutes les écritures (client, demande, devis, facture, paiement, statut de workflow…) écrivent d'abord en SQLite, puis enfilent un changement dans `sync_queue` via `SyncEngine.enqueue(...)`.
- Les documents générés (PDF, images) sont écrits sous `<documents>/msn_manager/documents/{REFERENCE}/DOCUMENTS/` (`BackupService.generatedDirectory`).
- Les messages clients sont copiés/partagés nativement (`share_plus`) : l'opérateur bascule vers Messenger/WhatsApp même hors ligne, tant que l'application cible a ses propres données.

Conséquence : une coupure réseau n'a **aucun effet fonctionnel**. Seul l'indicateur de statut passe à OFFLINE.

## 2. Quand la connexion revient

Le contrôleur de synchronisation (`core/sync/sync_provider.dart`, `SyncController`) écoute la connectivité et déclenche un cycle :

```dart
// Déclenchement automatique quand la connexion revient.
ref.listen(connectivityProvider, (prev, next) {
  next.whenData((online) {
    if (online) {
      runNow();                       // cycle push + pull immédiat
    } else {
      state = state.copyWith(status: SyncStatus.offline);
    }
  });
});
// Cycle périodique de sécurité (toutes les 5 minutes).
_timer = Timer.periodic(const Duration(minutes: 5), (_) => runNow());
```

La file d'attente est traitée par lots de 50 (`AppConstants.syncBatchSize`), dans l'ordre d'insertion (`ORDER BY createdAt ASC`). Un changement resté en file pendant la coupure part dès le premier cycle suivant. Un cycle réussi met à jour la clé `last_sync_at` (table `settings`).

## 3. Statuts affichés

Enum `SyncStatus` (`core/domain/enums.dart`), consommé via `SyncState.status` :

| Statut | Signification |
|---|---|
| `OFFLINE` | Aucune interface réseau (wifi/mobile/ethernet) détectée. |
| `ONLINE` | Réseau présent, serveur configuré, app en attente de cycle. |
| `SYNCHRONISATION EN COURS` | Un cycle push/pull est en cours (`runNow`). |
| `SYNCHRONISÉ` | Dernier cycle réussi, aucun conflit ouvert. |
| `ERREUR DE SYNCHRONISATION` | Échec réseau, ou conflits à résoudre (message dans `SyncState.error`). |
| `SERVEUR NON CONFIGURÉ` | Clé `server_url` vide : mode purement local, rien ne quitte le téléphone. |

Le compteur de changements en attente (`SyncState.pendingCount`) est affiché sur l'écran `/sync` et rafraîchi après chaque cycle.

## 4. Reprise après coupure

- Les lignes `sync_queue` en échec restent en base avec `tentatives + 1` et `derniereErreur` (`SystemDao.incrementTentative`). Le seuil `AppConstants.syncMaxAttempts` (5) borne les tentatives avant passage en `erreur`.
- La file `pending()` relit les statuts `enAttente` **et** `erreur` : un échec temporaire est automatiquement rejoué au cycle suivant.
- Les conflits détectés sont posés dans `sync_conflicts` (statut `ouvert`) et comptabilisés dans le rapport de cycle : la résolution est humaine (voir 04-synchronisation.md).
- Les rappels non notifiés pendant l'arrêt de l'app sont repris au démarrage (`ReminderService.flushDue` dans `appStartupProvider`).

## 5. Bonnes pratiques

1. **Jamais d'appel réseau bloquant dans un écran.** Un écran écrit en base et enfile la sync ; il n'attend jamais le serveur. Tout appel HTTP est confiné à `core/sync/api_client.dart` (timeout 15 s, `GET /health` 5 s) et au moteur de sync.
2. **Toute lecture = un `StreamProvider`** sur un `DAO.watch()`, pas un `Future` ponctuel : l'UI reste correcte après chaque écriture locale.
3. **Toute écriture = SQLite puis `enqueue`** (voir l'exemple client dans 01-architecture.md). Ne jamais écrire « seulement si en ligne ».
4. **Traiter `NetworkException`** comme un événement normal (file conservée), jamais comme une erreur bloquante pour l'utilisateur.
5. **Ne pas tester la connectivité soi-même** : utiliser `connectivityProvider` / `ConnectivityService.isOnline()`, qui centralise la détection (wifi, mobile, ethernet).
6. **Les données sensibles ne sortent pas du téléphone** tant que `server_url` n'est pas explicitement configurée (comportement garanti par `SyncEngine.run`).

## 6. Comportement par écran pendant une coupure

| Écran | Hors connexion |
|---|---|
| Dashboard | KPIs calculés en SQL local, toujours à jour. |
| Demandes / qualification | Création, qualification, changement de statut : normaux (écritures locales + file). |
| Devis / Factures | Création, totaux (`QuoteCalculator`), PDF : normaux. |
| Paiements | Enregistrement (MVola, espèces…) : normal ; statuts de facture recalculés localement. |
| Commandes / workflows | Progression d'étapes, règles métier, exceptions : normales (moteurs purs). |
| Communication | Rendu de modèles, copie, partage natif : normal (aucun envoi par l'app). |
| Documents | Génération PDF/PNG et partage : normal (fichiers locaux). |
| Synchronisation | Affiche OFFLINE + compteur en attente ; le bouton « synchroniser » ne fait rien de nocif (`SyncEngine.run` sort immédiatement avec `SyncStatus.offline`). |
| Administration | Paramètres, modules, journal, corbeille, sauvegarde : normaux (base locale). |

Le seul écran jamais bloqué par le réseau est donc `/sync` ; aucun flux de vente ne l'est.

