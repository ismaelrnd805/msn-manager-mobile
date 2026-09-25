/// Providers factures — liste, détail, création depuis commande/devis.
library;

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/domain/enums.dart';
import '../../core/domain/quote_calculator.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../core/sync/sync_engine.dart';

final invoicesFilterProvider = StateProvider<String?>((ref) => null);
final invoicesSearchProvider = StateProvider<String>((ref) => '');

class InvoiceRow {
  const InvoiceRow({required this.invoice, required this.clientNom});

  final Invoice invoice;
  final String clientNom;
}

final invoicesProvider = StreamProvider<List<InvoiceRow>>((ref) {
  final statut = ref.watch(invoicesFilterProvider);
  final query = ref.watch(invoicesSearchProvider);
  return ref
      .watch(documentsDaoProvider)
      .watchInvoices(statut: statut, query: query)
      .map((rows) => rows
          .map((r) => InvoiceRow(invoice: r.invoice, clientNom: r.clientNom))
          .toList());
});

final invoiceProvider = StreamProvider.family<Invoice?, String>((ref, id) {
  return ref.watch(documentsDaoProvider).watchInvoice(id);
});

final invoiceItemsProvider =
    FutureProvider.family<List<InvoiceItem>, String>((ref, id) {
  return ref.watch(documentsDaoProvider).invoiceItems(id);
});

/// Total payé d'une facture (flux temps réel).
final invoicePaidProvider = StreamProvider.family<int, String>((ref, id) {
  return ref.watch(paymentsDaoProvider).watchTotalForInvoice(id);
});

/// Crée une facture depuis une commande (ou un devis) — aucune ressaisie.
Future<String> createInvoiceFromOrder(
  WidgetRef ref, {
  required String orderId,
}) async {
  final ordersDao = ref.read(ordersDaoProvider);
  final full = await ordersDao.byId(orderId);
  if (full == null) throw StateError('Commande introuvable : $orderId');
  final order = full.order;

  final reference = await ref.read(numberingServiceProvider).next('FAC');
  final now = DateTime.now();
  final invoiceId = 'fac_${now.microsecondsSinceEpoch}';

  // Lignes : depuis le devis lié s'il existe, sinon une ligne unique.
  List<InvoiceItem> items;
  if (order.quoteId != null) {
    final quoteItems =
        await ref.read(documentsDaoProvider).quoteItems(order.quoteId!);
    items = quoteItems
        .map((i) => InvoiceItem(
              id: '${invoiceId}_i${i.ordre}',
              invoiceId: invoiceId,
              serviceId: i.serviceId,
              designation: i.designation,
              quantite: i.quantite,
              prixUnitaire: i.prixUnitaire,
              ordre: i.ordre,
            ))
        .toList();
  } else {
    items = [
      InvoiceItem(
        id: '${invoiceId}_i0',
        invoiceId: invoiceId,
        serviceId: order.serviceId,
        designation: order.titre,
        quantite: 1,
        prixUnitaire: order.montantTotal,
        ordre: 0,
      ),
    ];
  }

  final totals = QuoteCalculator.facture(
    lignes: items
        .map((i) => DocumentLine(
              designation: i.designation,
              quantite: i.quantite,
              prixUnitaire: i.prixUnitaire,
            ))
        .toList(),
  );

  final invoice = Invoice(
    id: invoiceId,
    reference: reference,
    clientId: order.clientId,
    orderId: order.id,
    quoteId: order.quoteId,
    statut: InvoiceStatut.brouillon,
    montantTotal: totals.total,
    dateEmission: now,
    dateEcheance: now.add(const Duration(days: 15)),
    createdAt: now,
    updatedAt: now,
  );
  await ref.read(documentsDaoProvider).upsertInvoiceWithItems(invoice, items);
  await ref.read(syncEngineProvider).enqueue(
        entite: 'invoices',
        entityId: invoiceId,
        operation: SyncOperation.create,
        payload: {'reference': reference, 'total': totals.total},
      );
  await ref.read(activityLoggerProvider).log(
        action: ActivityAction.creation,
        entite: 'facture',
        entityId: invoiceId,
        details: 'Facture $reference créée depuis la commande '
            '${order.reference} (${Formatters.ar(totals.total)}).',
      );
  return invoiceId;
}
