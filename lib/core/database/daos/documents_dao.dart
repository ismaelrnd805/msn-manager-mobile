/// DAO documents commerciaux — devis et factures avec leurs lignes.
///
/// Les lignes sont remplacées atomiquement à chaque enregistrement
/// (transaction), et le total dénormalisé est recalculé côté appelant
/// via [QuoteCalculator].
library;

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

class QuoteWithClient {
  const QuoteWithClient(this.quote, this.client);

  final Quote quote;
  final Client client;

  String get clientNom => client.nom;
}

class InvoiceWithClient {
  const InvoiceWithClient(this.invoice, this.client);

  final Invoice invoice;
  final Client client;

  String get clientNom => client.nom;
}

class DocumentsDao extends DatabaseAccessor<AppDatabase> {
  DocumentsDao(super.db);

  // ── Devis ─────────────────────────────────────────────────────────────────

  Stream<List<QuoteWithClient>> watchQuotes({String? statut, String query = ''}) {
    final q = query.trim().toLowerCase();
    return (select(quotes).join([
      innerJoin(clients, clients.id.equalsExp(quotes.clientId)),
    ])
          ..where(quotes.deletedAt.isNull())
          ..where(statut == null || statut.isEmpty
              ? const CustomExpression<bool>('1 = 1')
              : quotes.statut.equals(statut))
          ..where(q.isEmpty
              ? const CustomExpression<bool>('1 = 1')
              : quotes.reference.lower().like('%$q%') |
                  clients.nom.lower().like('%$q%'))
          ..orderBy([OrderingTerm.desc(quotes.dateEmission)]))
        .watch()
        .map((rows) => rows
            .map((row) => QuoteWithClient(
                  row.readTable(quotes),
                  row.readTable(clients),
                ))
            .toList());
  }

  Stream<Quote?> watchQuote(String id) =>
      (select(quotes)..where((q) => q.id.equals(id))).watchSingleOrNull();

  Future<Quote?> quoteById(String id) =>
      (select(quotes)..where((q) => q.id.equals(id))).getSingleOrNull();

  Future<List<QuoteItem>> quoteItems(String quoteId) =>
      (select(quoteItems)..where((i) => i.quoteId.equals(quoteId)))
          .get()
          .then((list) => [...list]..sort((a, b) => a.ordre.compareTo(b.ordre)));

  Stream<List<QuoteItem>> watchQuoteItems(String quoteId) =>
      (select(quoteItems)..where((i) => i.quoteId.equals(quoteId))
            ..orderBy([(i) => OrderingTerm.asc(i.ordre)]))
          .watch();

  Future<void> upsertQuoteWithItems(Quote quote, List<QuoteItem> items) {
    return transaction(() async {
      await into(quotes).insertOnConflictUpdate(quote);
      await (delete(quoteItems)..where((i) => i.quoteId.equals(quote.id))).go();
      for (final item in items) {
        await into(quoteItems).insert(item);
      }
    });
  }

  /// Mise à jour ciblée du statut (conserve les autres colonnes).
  Future<void> setQuoteStatut(String id, QuoteStatut statut) =>
      (update(quotes)..where((q) => q.id.equals(id))).write(
        QuotesCompanion(
          statut: Value(statut),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> softDeleteQuote(String id) =>
      (update(quotes)..where((q) => q.id.equals(id))).write(
        QuotesCompanion(
          deletedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

  // ── Factures ──────────────────────────────────────────────────────────────

  Stream<List<InvoiceWithClient>> watchInvoices({String? statut, String query = ''}) {
    final q = query.trim().toLowerCase();
    return (select(invoices).join([
      innerJoin(clients, clients.id.equalsExp(invoices.clientId)),
    ])
          ..where(invoices.deletedAt.isNull())
          ..where(statut == null || statut.isEmpty
              ? const CustomExpression<bool>('1 = 1')
              : invoices.statut.equals(statut))
          ..where(q.isEmpty
              ? const CustomExpression<bool>('1 = 1')
              : invoices.reference.lower().like('%$q%') |
                  clients.nom.lower().like('%$q%'))
          ..orderBy([OrderingTerm.desc(invoices.dateEmission)]))
        .watch()
        .map((rows) => rows
            .map((row) => InvoiceWithClient(
                  row.readTable(invoices),
                  row.readTable(clients),
                ))
            .toList());
  }

  Stream<Invoice?> watchInvoice(String id) =>
      (select(invoices)..where((i) => i.id.equals(id))).watchSingleOrNull();

  Future<Invoice?> invoiceById(String id) =>
      (select(invoices)..where((i) => i.id.equals(id))).getSingleOrNull();

  Future<List<InvoiceItem>> invoiceItems(String invoiceId) =>
      (select(invoiceItems)..where((i) => i.invoiceId.equals(invoiceId)))
          .get()
          .then((list) => [...list]..sort((a, b) => a.ordre.compareTo(b.ordre)));

  Future<void> upsertInvoiceWithItems(Invoice invoice, List<InvoiceItem> items) {
    return transaction(() async {
      await into(invoices).insertOnConflictUpdate(invoice);
      await (delete(invoiceItems)..where((i) => i.invoiceId.equals(invoice.id)))
          .go();
      for (final item in items) {
        await into(invoiceItems).insert(item);
      }
    });
  }

  Future<void> setInvoiceStatut(String id, InvoiceStatut statut) =>
      (update(invoices)..where((i) => i.id.equals(id))).write(
        InvoicesCompanion(
          statut: Value(statut),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> softDeleteInvoice(String id) =>
      (update(invoices)..where((i) => i.id.equals(id))).write(
        InvoicesCompanion(
          deletedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );
}
