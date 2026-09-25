/// Providers CRM clients — liste, recherche, historique par client.
library;

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/database_provider.dart';

/// Recherche courante (saisie de l'écran liste).
final clientsSearchProvider = StateProvider<String>((ref) => '');

/// Liste des clients actifs filtrée par la recherche.
final clientsProvider = StreamProvider<List<Client>>((ref) {
  final query = ref.watch(clientsSearchProvider);
  return ref.watch(clientsDaoProvider).watchAll(query: query);
});

/// Corbeille clients.
final clientsTrashProvider = StreamProvider<List<Client>>((ref) {
  return ref.watch(clientsDaoProvider).watchDeleted();
});

/// Historique d'un client : demandes, commandes, devis, factures, paiements.
final clientOrdersProvider =
    StreamProvider.family<List<Order>, String>((ref, clientId) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.orders)
        ..where((o) => o.clientId.equals(clientId) & o.deletedAt.isNull())
        ..orderBy([(o) => OrderingTerm.desc(o.createdAt)]))
      .watch();
});

final clientQuotesProvider =
    StreamProvider.family<List<Quote>, String>((ref, clientId) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.quotes)
        ..where((q) => q.clientId.equals(clientId) & q.deletedAt.isNull())
        ..orderBy([(q) => OrderingTerm.desc(q.dateEmission)]))
      .watch();
});

final clientInvoicesProvider =
    StreamProvider.family<List<Invoice>, String>((ref, clientId) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.invoices)
        ..where((i) => i.clientId.equals(clientId) & i.deletedAt.isNull())
        ..orderBy([(i) => OrderingTerm.desc(i.dateEmission)]))
      .watch();
});

final clientPaymentsProvider =
    StreamProvider.family<List<Payment>, String>((ref, clientId) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.payments)
        ..where((p) => p.clientId.equals(clientId))
        ..orderBy([(p) => OrderingTerm.desc(p.datePaiement)]))
      .watch();
});

final clientRequestsProvider =
    StreamProvider.family<List<Request>, String>((ref, clientId) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.requests)
        ..where((r) => r.clientId.equals(clientId) & r.deletedAt.isNull())
        ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]))
      .watch();
});
