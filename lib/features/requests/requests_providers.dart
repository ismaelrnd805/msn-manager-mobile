/// Providers demandes — liste filtrée, détail, fichiers joints.
library;

import 'package:drift/drift.dart' show OrderingTerm, OrderingMode, innerJoin;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/database_provider.dart';

final requestsFilterProvider = StateProvider<String?>((ref) => null);
final requestsSearchProvider = StateProvider<String>((ref) => '');

/// Résultat enrichi (demande + client) — version UI.
class RequestRow {
  const RequestRow({required this.request, required this.clientNom});

  final Request request;
  final String clientNom;
}

final requestsProvider = StreamProvider<List<RequestRow>>((ref) {
  final dao = ref.watch(requestsDaoProvider);
  final statut = ref.watch(requestsFilterProvider);
  final query = ref.watch(requestsSearchProvider);
  return dao.watchAll(statut: statut, query: query).map((rows) =>
      rows
          .map((r) => RequestRow(request: r.request, clientNom: r.clientNom))
          .toList());
});

/// Détail : demande + client (flux réactif).
final requestDetailProvider =
    StreamProvider.family<RequestWithClientRow?, String>((ref, id) {
  final db = ref.watch(appDatabaseProvider);
  final query = db.select(db.requests).join([
    innerJoin(db.clients, db.clients.id.equalsExp(db.requests.clientId)),
  ])
    ..where(db.requests.id.equals(id));
  return query.watchSingleOrNull().map((row) => row == null
      ? null
      : RequestWithClientRow(
          row.readTable(db.requests), row.readTable(db.clients)));
});

class RequestWithClientRow {
  const RequestWithClientRow(this.request, this.client);

  final Request request;
  final Client client;
}

/// Fichiers joints à la demande.
final requestFilesProvider =
    StreamProvider.family<List<OrderFile>, String>((ref, requestId) {
  return ref
      .watch(ordersDaoProvider)
      .watchFilesForRequest(requestId);
});

/// Toutes les demandes d'un statut donné (dashboard → actions ciblées).
final requestsCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.requests)
        ..where((r) => r.deletedAt.isNull()))
      .watch()
      .map((rows) => rows.length);
});

/// Liste simple ordonnée (utilitaires divers).
final recentRequestsProvider = StreamProvider<List<Request>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.requests)
        ..where((r) => r.deletedAt.isNull())
        ..orderBy([(r) => OrderingTerm(
            expression: r.createdAt, mode: OrderingMode.desc)]))
      .watch();
});
