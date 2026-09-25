/// DAO commandes — suivi, fichiers joints, transfert PC.
library;

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

class OrderWithClient {
  const OrderWithClient(this.order, this.client);

  final Order order;
  final Client client;

  String get clientNom => client.nom;
}

class OrdersDao extends DatabaseAccessor<AppDatabase> {
  OrdersDao(super.db);

  Stream<List<OrderWithClient>> watchOrders({String? statut, String query = ''}) {
    final q = query.trim().toLowerCase();
    return (select(orders).join([
      innerJoin(clients, clients.id.equalsExp(orders.clientId)),
    ])
          ..where(orders.deletedAt.isNull())
          ..where(statut == null || statut.isEmpty
              ? const CustomExpression<bool>('1 = 1')
              : orders.statut.equals(statut))
          ..where(q.isEmpty
              ? const CustomExpression<bool>('1 = 1')
              : orders.reference.lower().like('%$q%') |
                  clients.nom.lower().like('%$q%') |
                  orders.titre.lower().like('%$q%'))
          ..orderBy([OrderingTerm.desc(orders.createdAt)]))
        .watch()
        .map((rows) => rows
            .map((row) => OrderWithClient(
                  row.readTable(orders),
                  row.readTable(clients),
                ))
            .toList());
  }

  Future<OrderWithClient?> byId(String id) async {
    final rows = await (select(orders).join([
      innerJoin(clients, clients.id.equalsExp(orders.clientId)),
    ])
          ..where(orders.id.equals(id)))
        .get();
    if (rows.isEmpty) return null;
    return OrderWithClient(
      rows.first.readTable(orders),
      rows.first.readTable(clients),
    );
  }

  Stream<OrderWithClient?> watchById(String id) {
    return (select(orders).join([
      innerJoin(clients, clients.id.equalsExp(orders.clientId)),
    ])
          ..where(orders.id.equals(id)))
        .watchSingleOrNull()
        .map((row) => row == null
            ? null
            : OrderWithClient(row.readTable(orders), row.readTable(clients)));
  }

  Future<void> upsert(Order row) => into(orders).insertOnConflictUpdate(row);

  Future<void> updateStatut(String id, OrderStatut statut) =>
      (update(orders)..where((o) => o.id.equals(id))).write(
        OrdersCompanion(
          statut: Value(statut),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> setBriefComplet(String id, {required bool briefComplet}) =>
      (update(orders)..where((o) => o.id.equals(id))).write(
        OrdersCompanion(
          briefComplet: Value(briefComplet),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> markPretPourProduction(String id) =>
      (update(orders)..where((o) => o.id.equals(id))).write(
        OrdersCompanion(
          pretPourProduction: const Value(true),
          statut: const Value(OrderStatut.pretProduction),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> markTransfere(String id) =>
      (update(orders)..where((o) => o.id.equals(id))).write(
        OrdersCompanion(
          transferePc: const Value(true),
          transfereLe: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> softDelete(String id) =>
      (update(orders)..where((o) => o.id.equals(id))).write(
        OrdersCompanion(
          deletedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> restore(String id) =>
      (update(orders)..where((o) => o.id.equals(id))).write(
        const OrdersCompanion(deletedAt: Value(null)),
      );

  Stream<List<Order>> watchDeleted() =>
      (select(orders)..where((o) => o.deletedAt.isNotNull())).watch();

  // ── Fichiers ──────────────────────────────────────────────────────────────

  Stream<List<OrderFile>> watchFilesForOrder(String orderId) =>
      (select(orderFiles)..where((f) => f.orderId.equals(orderId))
            ..orderBy([(f) => OrderingTerm.desc(f.createdAt)]))
          .watch();

  Stream<List<OrderFile>> watchFilesForRequest(String requestId) =>
      (select(orderFiles)..where((f) => f.requestId.equals(requestId))
            ..orderBy([(f) => OrderingTerm.desc(f.createdAt)]))
          .watch();

  Future<List<OrderFile>> filesForRequest(String requestId) =>
      (select(orderFiles)..where((f) => f.requestId.equals(requestId))).get();

  Future<void> insertFile(OrderFile row) => into(orderFiles).insert(row);

  Future<void> deleteFile(String id) =>
      (delete(orderFiles)..where((f) => f.id.equals(id))).go();
}
