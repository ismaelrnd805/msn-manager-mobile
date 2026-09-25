/// Détail facture — totaux, solde temps réel, paiements enregistrés,
/// PDF/image et création de facture depuis une commande.
library;

import 'dart:io';
import '../../core/database/app_database.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/enums.dart';
import '../../core/domain/quote_calculator.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../core/services/backup_service.dart';
import '../../core/theme/msn_theme.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/feedback.dart';
import '../payments/payments_providers.dart';
import 'invoices_providers.dart';

/// Écran de création : choisit la commande puis délègue.
class InvoiceNewScreen extends ConsumerStatefulWidget {
  const InvoiceNewScreen({
    super.key,
    this.orderId,
    this.quoteId,
    this.clientId,
  });

  final String? orderId;
  final String? quoteId;
  final String? clientId;

  @override
  ConsumerState<InvoiceNewScreen> createState() => _InvoiceNewScreenState();
}

class _InvoiceNewScreenState extends ConsumerState<InvoiceNewScreen> {
  @override
  void initState() {
    super.initState();
    // Création immédiate depuis la commande (aucune ressaisie).
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.orderId == null) return;
      try {
        final id = await createInvoiceFromOrder(
          ref,
          orderId: widget.orderId!,
        );
        if (mounted) context.pushReplacement('/invoices/$id');
      } catch (e) {
        if (mounted) {
          showMsnSnack(context, e.toString(), error: true);
          context.pop();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle facture')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class InvoiceDetailScreen extends ConsumerWidget {
  const InvoiceDetailScreen({super.key, required this.invoiceId});

  final String invoiceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceAsync = ref.watch(invoiceProvider(invoiceId));
    final itemsAsync = ref.watch(invoiceItemsProvider(invoiceId));
    final paidAsync = ref.watch(invoicePaidProvider(invoiceId));
    final invoicesList = ref.watch(invoicesProvider);
    final clientNom = invoicesList.value
        ?.where((r) => r.invoice.id == invoiceId)
        .map((r) => r.clientNom)
        .firstWhere((_) => true, orElse: () => '…');
    final paymentsAsync = ref.watch(invoicePaymentsProvider(invoiceId));

    return invoiceAsync.when(
      loading: () => Scaffold(
          appBar: AppBar(),
          body: const Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
          appBar: AppBar(),
          body: Center(child: Text('$e'))),
      data: (invoice) {
        if (invoice == null) {
          return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('Facture introuvable')));
        }
        final items = itemsAsync.value ?? const [];
        final paid = paidAsync.value ?? 0;
        final totals = QuoteCalculator.facture(
          lignes: items
              .map((i) => DocumentLine(
                    designation: i.designation,
                    quantite: i.quantite,
                    prixUnitaire: i.prixUnitaire,
                  ))
              .toList(),
          reduction: invoice.reduction,
          paiementsRecus: [paid],
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(invoice.reference),
          ),
          floatingActionButton: invoice.statut != InvoiceStatut.payee &&
                  invoice.statut != InvoiceStatut.annulee
              ? FloatingActionButton.extended(
                  onPressed: () => context.push(
                      '/payments/new?invoiceId=$invoiceId'),
                  icon: const Icon(Icons.payments),
                  label: const Text('Encaisser'),
                )
              : null,
          body: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              Row(
                children: [
                  StatusChip.statut(
                      statut: invoice.statut.name, label: invoice.statut.label),
                  const Spacer(),
                  Text(clientNom ?? '',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 10),
              Card(
                color: MsnColors.accentSoft,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      _row('Total', Formatters.ar(totals.total)),
                      _row('Payé', Formatters.ar(totals.paye)),
                      _row('SOLDE', Formatters.ar(totals.solde), bold: true),
                      _row('Émission', Formatters.date(invoice.dateEmission)),
                      _row('Échéance', Formatters.date(invoice.dateEcheance)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Text('LIGNES'.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: MsnColors.textSecondary)),
              const SizedBox(height: 4),
              Card(
                child: Column(
                  children: [
                    for (final i in items)
                      ListTile(
                        dense: true,
                        title: Text(i.designation,
                            style: const TextStyle(fontSize: 13)),
                        subtitle: Text(
                            '${Formatters.qty(i.quantite)} × '
                            '${Formatters.ar(i.prixUnitaire)}',
                            style: const TextStyle(fontSize: 11.5)),
                        trailing: Text(
                            Formatters.ar(
                                (i.quantite * i.prixUnitaire).round()),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Text('PAIEMENTS (${paymentsAsync.value?.length ?? 0})'
                  .toUpperCase(),
                  style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: MsnColors.textSecondary)),
              const SizedBox(height: 4),
              Card(
                child: (paymentsAsync.value ?? []).isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Aucun paiement enregistré.',
                            style: TextStyle(
                                fontSize: 12,
                                color: MsnColors.textSecondary)))
                    : Column(
                        children: paymentsAsync.value!
                            .map((p) => ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.payments,
                                      size: 18),
                                  title: Text(Formatters.ar(p.montant),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700)),
                                  subtitle: Text(
                                      '${p.methode.label}'
                                      '${p.referenceExterne != null ? ' · ${p.referenceExterne}' : ''}',
                                      style: const TextStyle(fontSize: 11.5)),
                                  trailing: Text(
                                      Formatters.date(p.datePaiement),
                                      style: const TextStyle(fontSize: 11)),
                                ))
                            .toList(),
                      ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _sharePdf(context, ref, invoice),
                      icon: const Icon(Icons.picture_as_pdf_outlined,
                          size: 18),
                      label: const Text('PDF', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareImage(context, ref, invoice),
                      icon: const Icon(Icons.image_outlined, size: 18),
                      label: const Text('Image',
                          style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _row(String label, String value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 12.5,
                    color:
                        bold ? MsnColors.primaryDark : MsnColors.textSecondary,
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w500)),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
          ],
        ),
      );

  Future<void> _doShare(BuildContext context, WidgetRef ref, Invoice invoice,
      {required bool asImage}) async {
    final dao = ref.read(documentsDaoProvider);
    final invoiceFull = await dao.invoiceById(invoice.id);
    final items = await dao.invoiceItems(invoice.id);
    final client = invoiceFull == null
        ? null
        : await ref.read(clientsDaoProvider).byId(invoiceFull.clientId);
    final paiements = await ref.read(paymentsDaoProvider).paymentsForInvoice(invoice.id);
    if (client == null || !context.mounted) return;
    try {
      final pdfFile = await runWithLoading(
        context,
        'Génération du document…',
        () => ref.read(pdfServiceProvider).invoice(
              invoice: invoice,
              client: client,
              items: items,
              paiements: paiements,
            ),
      );
      if (!asImage) {
        if (context.mounted) {
          await ref.read(shareServiceProvider).shareFile(pdfFile.path,
              subject: 'Facture ${invoice.reference}');
        }
        return;
      }
      final png = await ref
          .read(pdfServiceProvider)
          .rasterizeFirstPage(await pdfFile.readAsBytes());
      if (png == null) {
        throw StateError('Rasterisation impossible.');
      }
      final dir = await BackupService.generatedDirectory(invoice.reference);
      final imageFile = File('${dir.path}/facture_${invoice.reference}.png');
      await imageFile.writeAsBytes(png);
      if (context.mounted) {
        await ref.read(shareServiceProvider).shareFile(imageFile.path,
            subject: 'Facture ${invoice.reference}');
      }
    } catch (e) {
      if (context.mounted) showMsnSnack(context, e.toString(), error: true);
    }
  }

  Future<void> _sharePdf(BuildContext context, WidgetRef ref, Invoice invoice) =>
      _doShare(context, ref, invoice, asImage: false);

  Future<void> _shareImage(BuildContext context, WidgetRef ref, Invoice invoice) =>
      _doShare(context, ref, invoice, asImage: true);
}
