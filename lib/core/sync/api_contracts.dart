/// Contrats de données de la synchronisation (compatibles NestJS, /api/v1).
///
/// Format stable et versionné — voir docs/05-backend-nestjs.md pour la
/// spécification complète des endpoints attendus.
library;

import '../domain/enums.dart';

/// Changement local à pousser vers le serveur.
class SyncPayload {
  const SyncPayload({
    required this.entite,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.updatedAt,
    required this.deviceId,
  });

  final String entite; // ex. 'clients', 'requests', 'orders'…
  final String entityId;
  final SyncOperation operation;
  final Map<String, dynamic> payload;
  final DateTime updatedAt;
  final String deviceId;

  Map<String, dynamic> toJson() => {
        'entite': entite,
        'entityId': entityId,
        'operation': operation.name,
        'payload': payload,
        'updatedAt': updatedAt.toIso8601String(),
        'deviceId': deviceId,
      };

  static SyncPayload fromJson(Map<String, dynamic> json) => SyncPayload(
        entite: json['entite'] as String,
        entityId: json['entityId'] as String,
        operation:
            SyncOperation.values.byName(json['operation'] as String),
        payload: (json['payload'] as Map).cast<String, dynamic>(),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        deviceId: json['deviceId'] as String? ?? 'mobile',
      );
}

/// Changement distant renvoyé par le serveur (phase de pull).
class RemoteChange {
  const RemoteChange({
    required this.entite,
    required this.entityId,
    required this.payload,
    required this.serverUpdatedAt,
    required this.version,
  });

  final String entite;
  final String entityId;
  final Map<String, dynamic> payload;
  final DateTime serverUpdatedAt;
  final int version; // compteur de version serveur (ordre des changements)
}

/// Réponse d'un lot poussé : le serveur confirme chaque élément ou
/// signale un conflit (modification concurrente détectée).
class PushBatchResult {
  const PushBatchResult({
    required this.acceptedIds,
    required this.conflictIds,
  });

  final List<String> acceptedIds;
  final List<String> conflictIds;

  bool get hasConflicts => conflictIds.isNotEmpty;
}
