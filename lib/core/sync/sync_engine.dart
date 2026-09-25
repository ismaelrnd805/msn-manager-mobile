/// Moteur de synchronisation offline-first.
///
/// Stratégie (sections 5 et 13 du cahier des charges) :
/// 1. Toute écriture locale est mise en file d'attente (table sync_queue)
///    — l'application reste 100% fonctionnelle hors connexion.
/// 2. Quand Internet revient et qu'un serveur est configuré :
///    - PUSH : les changements locaux sont envoyés par lots ;
///    - PULL : les changements serveur sont récupérés et appliqués.
/// 3. Conflits : une donnée modifiée des DEUX côtés n'est jamais écrasée
///    silencieusement — un conflit est enregistré et affiché pour
///    décision humaine (garder local / garder distant).
///
/// Aucune donnée sensible n'est envoyée tant que le serveur n'est pas
/// explicitement configuré par l'administrateur.
library;

import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../constants/app_constants.dart';
import '../database/app_database.dart';
import '../database/daos/system_dao.dart';
import '../domain/enums.dart';
import '../errors/app_exception.dart';
import '../services/connectivity_service.dart';
import 'api_client.dart';
import 'api_contracts.dart';

/// Résultat d'un cycle de synchronisation.
class SyncRunReport {
  const SyncRunReport({
    required this.status,
    this.pushed = 0,
    this.pulled = 0,
    this.conflicts = 0,
    this.error,
  });

  final SyncStatus status;
  final int pushed;
  final int pulled;
  final int conflicts;
  final String? error;
}

/// Convertisseur entité ↔ payload JSON pour le pull.
/// Référence d'implémentation : ajouter un mapper par entité lorsque le
/// serveur NestJS sera déployé (voir docs/04-synchronisation.md).
typedef RemoteEntityApplier = Future<bool> Function(
    String entityId, Map<String, dynamic> payload);

class SyncEngine {
  SyncEngine(this._db, this._system, this._connectivity, {String? deviceId})
      : deviceId = deviceId ?? 'mobile-${DateTime.now().millisecondsSinceEpoch}';

  final AppDatabase _db;
  final SystemDao _system;
  final ConnectivityService _connectivity;
  final String deviceId;

  /// Appliers distants (entité → insertion/mise à jour locale).
  final Map<String, RemoteEntityApplier> remoteAppliers = {};

  /// Enfile un changement local (appelé par toutes les écritures métier).
  Future<void> enqueue({
    required String entite,
    required String entityId,
    required SyncOperation operation,
    required Map<String, dynamic> payload,
  }) {
    return _system.enqueue(
      SyncQueueData(
        id: 'sq_${DateTime.now().microsecondsSinceEpoch}_'
            '${entityId.hashCode.abs()}',
        entite: entite,
        entityId: entityId,
        operation: operation,
        payload: jsonEncode(payload),
        statut: SyncQueueStatut.enAttente,
        tentatives: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Exécute un cycle complet push + pull.
  Future<SyncRunReport> run() async {
    final online = await _connectivity.isOnline();
    if (!online) {
      return const SyncRunReport(status: SyncStatus.offline);
    }
    final serverUrl = await _system.getValue(AppConstants.keyServerUrl);
    if (serverUrl == null || serverUrl.trim().isEmpty) {
      return const SyncRunReport(status: SyncStatus.nonConfigure);
    }

    final api = ApiClient(baseUrl: serverUrl.trim(), deviceId: deviceId);
    try {
      var pushed = 0;
      var conflicts = 0;

      // ── PUSH ────────────────────────────────────────────────────────────
      final pending = await _system.pending(limit: AppConstants.syncBatchSize);
      if (pending.isNotEmpty) {
        final batch = pending
            .map((row) => SyncPayload(
                  entite: row.entite,
                  entityId: row.entityId,
                  operation: row.operation,
                  payload: jsonDecode(row.payload) as Map<String, dynamic>,
                  updatedAt: row.updatedAt,
                  deviceId: deviceId,
                ))
            .toList();
        try {
          final result = await api.pushBatch(batch);
          for (final id in result.acceptedIds) {
            await _system.markQueueStatut(
                id, SyncQueueStatut.synchronise);
          }
          for (final id in result.conflictIds) {
            final row = pending.firstWhere((r) => r.id == id,
                orElse: () => pending.first);
            await _createConflict(row, api);
            conflicts++;
          }
          pushed = result.acceptedIds.length;
        } on NetworkException {
          for (final row in pending) {
            await _system.incrementTentative(
                row.id, 'Serveur injoignable');
          }
          return const SyncRunReport(
            status: SyncStatus.erreur,
            error: 'PUSH impossible — les changements restent en file.',
          );
        }
      }

      // ── PULL ────────────────────────────────────────────────────────────
      final lastSyncStr = await _system.getValue(AppConstants.keyLastSyncAt);
      final since = lastSyncStr == null
          ? DateTime.fromMillisecondsSinceEpoch(0)
          : DateTime.parse(lastSyncStr);
      var pulled = 0;
      try {
        final changes = await api.fetchChanges(since);
        for (final change in changes) {
          final applied = await _applyRemote(change);
          if (applied) pulled++;
        }
      } on NetworkException {
        // Le push a peut-être réussi : on enregistre quand même la date.
      }

      await _system.setValue(
          AppConstants.keyLastSyncAt, DateTime.now().toIso8601String());
      final openConflicts =
          conflicts + await _countOpenConflicts();
      if (openConflicts > 0) {
        return SyncRunReport(
            status: SyncStatus.erreur,
            pushed: pushed,
            pulled: pulled,
            conflicts: openConflicts,
            error: '$openConflicts conflit(s) à résoudre.');
      }
      return SyncRunReport(
          status: SyncStatus.synchronise,
          pushed: pushed,
          pulled: pulled);
    } finally {
      api.close();
    }
  }

  /// Applique un changement distant — détection de conflit :
  /// si la même entité a été modifiée localement (file en attente pour
  /// cette entité) ET que le serveur est plus récent, on n'écrase pas :
  /// un conflit est créé pour décision humaine.
  Future<bool> _applyRemote(RemoteChange change) async {
    final mapper = remoteAppliers[change.entite];
    if (mapper == null) {
      // Entité encore sans mapper : conservée en file en conflit pour
      // traitement ultérieur — jamais perdue.
      await _system.enqueue(
        SyncQueueData(
          id: 'sq_pull_${DateTime.now().microsecondsSinceEpoch}_'
              '${change.entityId.hashCode.abs()}',
          entite: change.entite,
          entityId: change.entityId,
          operation: SyncOperation.update,
          payload: jsonEncode(change.payload),
          statut: SyncQueueStatut.enAttente,
          tentatives: 0,
          createdAt: DateTime.now(),
          updatedAt: change.serverUpdatedAt,
        ),
      );
      return false;
    }
    // Conflit : la même entité a une écriture locale en attente.
    final localPending = await _db.customSelect(
      'SELECT COUNT(*) AS c FROM sync_queue WHERE entite = ? AND '
      'entity_id = ? AND statut IN (?, ?)',
      variables: [
        Variable(change.entite),
        Variable(change.entityId),
        Variable(SyncQueueStatut.enAttente.name),
        Variable(SyncQueueStatut.erreur.name),
      ],
    ).getSingle();
    if ((localPending.data['c'] as int? ?? 0) > 0) {
      await _system.insertConflict(SyncConflict(
        id: 'cf_${DateTime.now().microsecondsSinceEpoch}',
        entite: change.entite,
        entityId: change.entityId,
        localPayload: jsonEncode({}),
        remotePayload: jsonEncode(change.payload),
        statut: 'ouvert',
        detecteLe: DateTime.now(),
      ));
      return false;
    }
    return mapper(change.entityId, change.payload);
  }

  Future<void> _createConflict(SyncQueueData row, ApiClient api) async {
    await _system.markQueueStatut(
      row.id,
      SyncQueueStatut.conflit,
      erreur: 'Le serveur a une version plus récente.',
    );
    await _system.insertConflict(SyncConflict(
      id: 'cf_${DateTime.now().microsecondsSinceEpoch}',
      entite: row.entite,
      entityId: row.entityId,
      localPayload: row.payload,
      remotePayload: jsonEncode({}),
      statut: 'ouvert',
      detecteLe: DateTime.now(),
    ));
  }

  Future<int> _countOpenConflicts() async {
    final row = await _db.customSelect(
      'SELECT COUNT(*) AS c FROM sync_conflicts WHERE statut = ?',
      variables: [const Variable('ouvert')],
    ).getSingle();
    return row.data['c'] as int? ?? 0;
  }

  /// Statut courant sans exécuter de cycle (pour l'affichage instantané).
  Future<SyncStatus> currentStatus() async {
    final online = await _connectivity.isOnline();
    if (!online) return SyncStatus.offline;
    final serverUrl = await _system.getValue(AppConstants.keyServerUrl);
    if (serverUrl == null || serverUrl.trim().isEmpty) {
      return SyncStatus.nonConfigure;
    }
    return SyncStatus.online;
  }
}
