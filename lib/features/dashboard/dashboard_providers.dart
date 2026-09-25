/// Providers du dashboard — compteurs temps réel (section 21).
///
/// Les compteurs sont calculés en SQL observé : toute modification
/// (ajout d'une demande, paiement reçu…) met à jour le dashboard
/// instantanément, hors connexion comme en ligne.
library;

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/domain/enums.dart';
import '../../core/providers/database_provider.dart';

class DashboardCounters {
  const DashboardCounters({
    required this.nouvellesDemandes,
    required this.aRepondre,
    required this.aTransfererPc,
    required this.enProduction,
    required this.enAttenteClient,
    required this.paiementsAttente,
    required this.deadlinesAujourdHui,
  });

  final int nouvellesDemandes;
  final int aRepondre;
  final int aTransfererPc;
  final int enProduction;
  final int enAttenteClient;
  final int paiementsAttente;
  final int deadlinesAujourdHui;

  static const empty = DashboardCounters(
    nouvellesDemandes: 0,
    aRepondre: 0,
    aTransfererPc: 0,
    enProduction: 0,
    enAttenteClient: 0,
    paiementsAttente: 0,
    deadlinesAujourdHui: 0,
  );
}

final dashboardCountersProvider =
    StreamProvider<DashboardCounters>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.customSelect('''
    SELECT
      (SELECT COUNT(*) FROM requests
        WHERE statut = 'nouvelle' AND deleted_at IS NULL) AS nouvelles,
      (SELECT COUNT(*) FROM requests
        WHERE statut IN ('nouvelle', 'enCours') AND deleted_at IS NULL)
        AS a_repondre,
      (SELECT COUNT(*) FROM orders
        WHERE pret_pour_production = 1 AND transfere_pc = 0
          AND deleted_at IS NULL) AS a_transferer,
      (SELECT COUNT(*) FROM orders
        WHERE statut = 'enProduction' AND deleted_at IS NULL)
        AS en_production,
      (SELECT COUNT(*) FROM requests
        WHERE statut = 'enAttente' AND deleted_at IS NULL)
        + (SELECT COUNT(*) FROM orders
           WHERE statut = 'enValidation' AND deleted_at IS NULL)
        AS en_attente,
      (SELECT COUNT(*) FROM invoices
        WHERE statut IN ('envoyee', 'partiellementPayee')
          AND deleted_at IS NULL) AS paiements,
      (SELECT COUNT(*) FROM orders
        WHERE deadline IS NOT NULL AND deleted_at IS NULL
          AND date(deadline, 'unixepoch') = date('now', 'localtime'))
        AS deadlines
  ''').watch().map((rows) {
    final r = rows.isEmpty ? <String, Object?>{} : rows.first.data;
    return DashboardCounters(
      nouvellesDemandes: (r['nouvelles'] as int?) ?? 0,
      aRepondre: (r['a_repondre'] as int?) ?? 0,
      aTransfererPc: (r['a_transferer'] as int?) ?? 0,
      enProduction: (r['en_production'] as int?) ?? 0,
      enAttenteClient: (r['en_attente'] as int?) ?? 0,
      paiementsAttente: (r['paiements'] as int?) ?? 0,
      deadlinesAujourdHui: (r['deadlines'] as int?) ?? 0,
    );
  });
});

/// Commandes dont la deadline est aujourd'hui (détail pour la liste).
final todayDeadlinesProvider = StreamProvider<List<DashboardDeadline>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.customSelect('''
    SELECT o.id AS oid, o.reference AS ref, o.titre AS titre,
           o.deadline AS deadline, c.nom AS client_nom
    FROM orders o
    INNER JOIN clients c ON c.id = o.client_id
    WHERE o.deadline IS NOT NULL AND o.deleted_at IS NULL
      AND o.statut NOT IN ('livree', 'terminee', 'annulee')
      AND date(o.deadline, 'unixepoch') <= date('now', '+3 day', 'localtime')
    ORDER BY o.deadline ASC
    LIMIT 5
  ''').watch().map((rows) => rows
      .map((row) => DashboardDeadline(
            orderId: row.data['oid'] as String,
            reference: row.data['ref'] as String,
            titre: row.data['titre'] as String,
            clientNom: row.data['client_nom'] as String,
            deadline: DateTime.fromMillisecondsSinceEpoch(
                (row.data['deadline'] as int) * 1000),
          ))
      .toList());
});

class DashboardDeadline {
  const DashboardDeadline({
    required this.orderId,
    required this.reference,
    required this.titre,
    required this.clientNom,
    required this.deadline,
  });

  final String orderId;
  final String reference;
  final String titre;
  final String clientNom;
  final DateTime deadline;
}

/// Journal récent (5 dernières entrées, copie allégée pour l'UI).
final dashboardActivityProvider = StreamProvider<List<DashboardActivity>>((ref) {
  final dao = ref.watch(systemDaoProvider);
  return dao.watchRecentActivity(limit: 5).map((rows) =>
      rows.map((r) => DashboardActivity(
            action: r.action,
            details: r.details,
            userName: r.userName,
            timestamp: r.timestamp,
          )).toList());
});

class DashboardActivity {
  const DashboardActivity({
    required this.action,
    required this.details,
    required this.userName,
    required this.timestamp,
  });

  final ActivityAction action;
  final String details;
  final String userName;
  final DateTime timestamp;
}
