/// Providers paiements — liste globale, paiements d'une facture,
/// encaissement avec mise à jour automatique du statut de la facture.
library;

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/domain/enums.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../core/sync/sync_engine.dart';
import '../../core/utils/formatters.dart';
import '../invoices/invoices_providers.dart';

/// Liste globale (paiement + client + facture).
final paymentsListProvider =
    StreamProvider<List<PaymentWithInfo>>((ref) {
  return ref.watch(paymentsDaoProvider).watchAll();
});

/// Paiements d'une facture précise.
final invoicePaymentsProvider =
    StreamProvider.family<List<Payment>, String>((ref, invoiceId) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.payments)
        ..where((p) => p.invoiceId.equals(invoiceId))
        ..orderBy([(p) => OrderingTerm.desc(p.datePaiement)]))
      .watch();
});

/// Enregistre un paiement et met à jour le statut de la facture :
/// partiellement payée, puis payée quand le solde atteint zéro.
Future<String> registerPayment(
  WidgetRef ref, {
  required int montant,
  required PaymentMethode methode,
  required DateTime date,
  String? invoiceId,
  String? orderId,
  String? clientId,
  String? referenceExterne,
  String? note,
}) async {
  final numbering = ref.read(numberingServiceProvider);
  final reference = await numbering.next('PMT');
  final now = DateTime.now();
  final id = 'pmt_${now.microsecondsSinceEpoch}';

  final payment = Payment(
    id: id,
    reference: reference,
    clientId: clientId,
    invoiceId: invoiceId,
    orderId: orderId,
    montant: montant,
    methode: methode,
    referenceExterne: referenceExterne,
    note: note,
    datePaiement: date,
    createdAt: now,
  );
  await ref.read(paymentsDaoProvider).upsert(payment);
  await ref.read(syncEngineProvider).enqueue(
        entite: 'payments',
        entityId: id,
        operation: SyncOperation.create,
        payload: {
          'reference': reference,
          'montant': montant,
          'methode': methode.name,
        },
      );

  if (invoiceId != null) {
    final invoice = await ref.read(documentsDaoProvider).invoiceById(invoiceId);
    if (invoice != null) {
      final total = await ref.read(paymentsDaoProvider).totalForInvoice(invoiceId);
      final statut = total >= invoice.montantTotal
          ? InvoiceStatut.payee
          : InvoiceStatut.partiellementPayee;
      await ref
          .read(documentsDaoProvider)
          .setInvoiceStatut(invoiceId, statut);

      // Solde réglé : le rappel « solde » associé est terminé.
      if (statut == InvoiceStatut.payee) {
        await _closeSoldeReminders(ref, orderId ?? invoice.orderId);
      }
    }
  }

  await ref.read(activityLoggerProvider).log(
        action: ActivityAction.paiement,
        entite: 'paiement',
        entityId: id,
        details: 'Paiement $reference de ${Formatters.ar(montant)} '
            '(${methode.label}) enregistré.',
      );
  return id;
}

Future<void> _closeSoldeReminders(WidgetRef ref, String? orderId) async {
  if (orderId == null) return;
  final system = ref.read(systemDaoProvider);
  final reminders = await system.watchReminders(onlyActive: true).first;
  for (final r in reminders) {
    if (r.cibleId == orderId &&
        (r.type == ReminderType.solde || r.type == ReminderType.acompte)) {
      await system.markReminderDone(r.id);
    }
  }
}
