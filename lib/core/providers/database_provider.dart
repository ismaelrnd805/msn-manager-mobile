/// Providers Riverpod — base de données et DAOs.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/daos/catalog_dao.dart';
import '../database/daos/clients_dao.dart';
import '../database/daos/documents_dao.dart';
import '../database/daos/orders_dao.dart';
import '../database/daos/payments_dao.dart';
import '../database/daos/requests_dao.dart';
import '../database/daos/system_dao.dart';
import '../database/daos/templates_dao.dart';
import '../database/daos/workflows_dao.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final clientsDaoProvider =
    Provider<ClientsDao>((ref) => ClientsDao(ref.watch(appDatabaseProvider)));

final requestsDaoProvider =
    Provider<RequestsDao>((ref) => RequestsDao(ref.watch(appDatabaseProvider)));

final catalogDaoProvider =
    Provider<CatalogDao>((ref) => CatalogDao(ref.watch(appDatabaseProvider)));

final documentsDaoProvider = Provider<DocumentsDao>(
    (ref) => DocumentsDao(ref.watch(appDatabaseProvider)));

final paymentsDaoProvider =
    Provider<PaymentsDao>((ref) => PaymentsDao(ref.watch(appDatabaseProvider)));

final ordersDaoProvider =
    Provider<OrdersDao>((ref) => OrdersDao(ref.watch(appDatabaseProvider)));

final workflowsDaoProvider = Provider<WorkflowsDao>(
    (ref) => WorkflowsDao(ref.watch(appDatabaseProvider)));

final templatesDaoProvider = Provider<TemplatesDao>(
    (ref) => TemplatesDao(ref.watch(appDatabaseProvider)));

final systemDaoProvider =
    Provider<SystemDao>((ref) => SystemDao(ref.watch(appDatabaseProvider)));
