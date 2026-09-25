/// DAO demandes — liste enrichie (jointure client), filtres, qualification.
library;

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

/// Résultat enrichi : une demande + son client.
class RequestWithClient {
  const RequestWithClient(this.request, this.client);

  final Request request;
  final Client client;

  String get clientNom => client.nom;
}

class RequestsDao extends DatabaseAccessor<AppDatabase> {
  RequestsDao(super.db);

  JoinedSelectStatement _baseQuery({String? statut, String query = ''}) {
    final q = query.trim().toLowerCase();
    return select(requests).join([
      innerJoin(clients, clients.id.equalsExp(requests.clientId)),
    ])
      ..where(requests.deletedAt.isNull())
      ..where(statut == null || statut.isEmpty
          ? const CustomExpression<bool>('1 = 1')
          : requests.statut.equals(statut))
      ..where(q.isEmpty
          ? const CustomExpression<bool>('1 = 1')
          : requests.reference.lower().like('%$q%') |
              clients.nom.lower().like('%$q%'))
      ..orderBy([OrderingTerm.desc(requests.createdAt)]);
  }

  Stream<List<RequestWithClient>> watchAll({String? statut, String query = ''}) {
    return _baseQuery(statut: statut, query: query).watch().map((rows) => rows
        .map((row) => RequestWithClient(
              row.readTable(requests),
              row.readTable(clients),
            ))
        .toList());
  }

  Future<RequestWithClient?> byId(String id) async {
    final rows = await (select(requests).join([
      innerJoin(clients, clients.id.equalsExp(requests.clientId)),
    ])
          ..where(requests.id.equals(id)))
        .get();
    if (rows.isEmpty) return null;
    return RequestWithClient(
      rows.first.readTable(requests),
      rows.first.readTable(clients),
    );
  }

  Stream<Request?> watchById(String id) =>
      (select(requests)..where((r) => r.id.equals(id))).watchSingleOrNull();

  Future<void> upsert(Request row) => into(requests).insertOnConflictUpdate(row);

  Future<void> updateStatut(String id, RequestStatut statut) =>
      (update(requests)..where((r) => r.id.equals(id))).write(
        RequestsCompanion(
          statut: Value(statut),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> saveQualification(String id, String qualificationJson) =>
      (update(requests)..where((r) => r.id.equals(id))).write(
        RequestsCompanion(
          qualificationJson: Value(qualificationJson),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> softDelete(String id) =>
      (update(requests)..where((r) => r.id.equals(id))).write(
        RequestsCompanion(
          deletedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> restore(String id) =>
      (update(requests)..where((r) => r.id.equals(id))).write(
        const RequestsCompanion(deletedAt: Value(null)),
      );

  Stream<List<Request>> watchDeleted() =>
      (select(requests)..where((r) => r.deletedAt.isNotNull())).watch();
}
