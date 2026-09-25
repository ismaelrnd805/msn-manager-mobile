/// DAO clients — CRUD + corbeille (suppression douce) + recherche.
library;

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

class ClientsDao extends DatabaseAccessor<AppDatabase> {
  ClientsDao(super.db);

  Stream<List<Client>> watchAll({String query = ''}) {
    final q = query.trim().toLowerCase();
    return (select(clients)
          ..where((c) => c.deletedAt.isNull())
          ..where((c) => q.isEmpty
              ? const CustomExpression<bool>('1 = 1')
              : c.nom.lower().like('%$q%'))
          ..orderBy([(c) => OrderingTerm.asc(c.nom)]))
        .watch();
  }

  Future<Client?> byId(String id) =>
      (select(clients)..where((c) => c.id.equals(id))).getSingleOrNull();

  Stream<Client?> watchById(String id) =>
      (select(clients)..where((c) => c.id.equals(id))).watchSingleOrNull();

  Future<void> upsert(Client row) =>
      into(clients).insertOnConflictUpdate(row);

  Future<void> updateRow(Client row) =>
      (update(clients)..where((c) => c.id.equals(row.id))).write(row);

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

  /// Corbeille : tous les clients supprimés doucement.
  Stream<List<Client>> watchDeleted() {
    return (select(clients)..where((c) => c.deletedAt.isNotNull())).watch();
  }

  /// Purge définitive (admin uniquement, après double confirmation).
  Future<void> purge(String id) =>
      (delete(clients)..where((c) => c.id.equals(id))).go();
}
