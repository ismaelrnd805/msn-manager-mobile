/// DAO paiements — enregistrement et totaux par facture/commande.
library;

import 'package:drift/drift.dart';

import '../app_database.dart';

class PaymentWithInfo {
  const PaymentWithInfo(this.payment, this.client, this.invoice);

  final Payment payment;
  final Client? client;
  final Invoice? invoice;

  String get clientNom => client?.nom ?? '—';
  String get invoiceReference => invoice?.reference ?? '—';
}

class PaymentsDao extends DatabaseAccessor<AppDatabase> {
  PaymentsDao(super.db);

  // Tables exposées via la base attachée (voir docs/01-architecture.md)
  $ClientsTable get clients => attachedDatabase.clients;
  $InvoicesTable get invoices => attachedDatabase.invoices;
  $PaymentsTable get payments => attachedDatabase.payments;


  Stream<List<PaymentWithInfo>> watchAll({String? invoiceId}) {
    return (select(payments).join([
      leftOuterJoin(clients, clients.id.equalsExp(payments.clientId)),
      leftOuterJoin(invoices, invoices.id.equalsExp(payments.invoiceId)),
    ])
          ..where(invoiceId == null
              ? const CustomExpression<bool>('1 = 1')
              : payments.invoiceId.equals(invoiceId))
          ..orderBy([OrderingTerm.desc(payments.datePaiement)]))
        .watch()
        .map((rows) => rows
            .map((row) => PaymentWithInfo(
                  row.readTable(payments),
                  row.readTableOrNull(clients),
                  row.readTableOrNull(invoices),
                ))
            .toList());
  }

  Future<List<Payment>> paymentsForInvoice(String invoiceId) =>
      (select(payments)..where((p) => p.invoiceId.equals(invoiceId))
            ..orderBy([(p) => OrderingTerm.desc(p.datePaiement)]))
          .get();

  Stream<int> watchTotalForInvoice(String invoiceId) {
    return (select(payments)
          ..where((p) => p.invoiceId.equals(invoiceId)))
        .watch()
        .map((rows) => rows.fold<int>(0, (s, p) => s + p.montant));
  }

  Stream<int> watchTotalForOrder(String orderId) {
    return (select(payments)..where((p) => p.orderId.equals(orderId)))
        .watch()
        .map((rows) => rows.fold<int>(0, (s, p) => s + p.montant));
  }

  Future<void> upsert(Payment row) =>
      into(payments).insertOnConflictUpdate(row);

  /// Total encaissé pour une commande (tous paiements confondus).
  Future<int> totalForOrder(String orderId) async {
    final rows = await (select(payments)
          ..where((p) => p.orderId.equals(orderId)))
        .get();
    return rows.fold<int>(0, (s, p) => s + p.montant);
  }

  /// Total encaissé pour une facture.
  Future<int> totalForInvoice(String invoiceId) async {
    final rows = await (select(payments)
          ..where((p) => p.invoiceId.equals(invoiceId)))
        .get();
    return rows.fold<int>(0, (s, p) => s + p.montant);
  }
}
