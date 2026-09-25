/// Détail d'un devis — totaux, actions prêtes (message, PDF, image),
/// transitions de statut et conversion en commande.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/quote_calculator.dart';
import '../../core/domain/enums.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../core/services/backup_service.dart';
import '../../core/theme/msn_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/database/app_database.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/copy_message_card.dart';
import '../../shared/widgets/feedback.dart';
import 'quotes_providers.dart';

class QuoteDetailScreen extends ConsumerWidget {
  const QuoteDetailScreen({super.key, required this.quoteId});

  final String quoteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteAsync = ref.watch(quoteProvider(quoteId));
    final itemsAsync = ref.watch(quoteItemsProvider(quoteId));
    final quotesList = ref.watch(quotesProvider);
    final clientNom = quotesList.value
        ?.where((r) => r.quote.id == quoteId)
        .map((r) => r.clientNom)
        .firstWhere((_) => true, orElse: () => '…');

    return Scaffold(
      appBar: AppBar(title: const Text('Devis')),
      body: quoteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (quote) {
          if (quote == null) {
            return const Center(child: Text('Devis introuvable'));
          }
          final items = itemsAsync.value ?? const [];
          final totals = QuoteCalculator.devis(
            lignes: items
                .map((i) => DocumentLine(
                      designation: i.designation,
                      quantite: i.quantite,
                      prixUnitaire: i.prixUnitaire,
                    ))
                .toList(),
            reduction: quote.reduction,
            acompte: quote.acompte,
          );

          return ListView(
            padding: const EdgeInsets.all(14),
            children: [
              Row(
                children: [
                  Text(quote.reference,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: MsnColors.primaryDark)),
                  const Spacer(),
                  StatusChip.statut(
                      statut: quote.statut.name, label: quote.statut.label),
                ],
              ),
              const SizedBox(height: 4),
              Text('Client : $clientNom',
                  style: const TextStyle(fontSize: 13)),
              Text(
                  'Émis le ${Formatters.date(quote.dateEmission)} — '
                  'valide ${quote.validiteJours} jours',
                  style: const TextStyle(
                      fontSize: 12, color: MsnColors.textSecondary)),
              const SizedBox(height: 12),

              // ── Lignes ────────────────────────────────────────────────
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
                                fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    if (items.isEmpty)
                      const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text('Aucune ligne')),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // ── Totaux ────────────────────────────────────────────────
              Card(
                color: MsnColors.accentSoft,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      _row('Sous-total', Formatters.ar(totals.sousTotal)),
                      _row('Réduction', '- ${Formatters.ar(totals.reduction)}'),
                      _row('TOTAL', Formatters.ar(totals.total), bold: true),
                      _row('Acompte demandé', Formatters.ar(totals.acompte)),
                      _row('Solde après acompte', Formatters.ar(totals.solde)),
                      if (quote.delaiJours != null)
                        _row('Délai', '${quote.delaiJours} jours'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── Actions prêtes ────────────────────────────────────────
              CopyMessageCard(
                title: 'Message devis prêt',
                body: _devisMessage(quote, totals),
                onShare: () async {
                  await ref.read(shareServiceProvider).shareText(
                        _devisMessage(quote, totals),
                        subject: 'Devis ${quote.reference}',
                      );
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _sharePdf(context, ref, quote, items),
                      icon: const Icon(Icons.picture_as_pdf_outlined,
                          size: 18),
                      label: const Text('PDF', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareImage(context, ref, quote, items),
                      icon: const Icon(Icons.image_outlined, size: 18),
                      label: const Text('Image',
                          style: TextStyle(fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/quotes/$quoteId/edit'),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Modifier',
                          style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Transitions ───────────────────────────────────────────
              Text('SUIVI DU DEVIS'.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: MsnColors.textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (quote.statut == QuoteStatut.brouillon)
                    _transition(context, ref, quote, QuoteStatut.envoye,
                        'Marquer envoyé', Icons.send),
                  if (quote.statut == QuoteStatut.envoye) ...[
                    _transition(context, ref, quote, QuoteStatut.accepte,
                        'Accepté par le client', Icons.check_circle),
                    _transition(context, ref, quote, QuoteStatut.refuse,
                        'Refusé', Icons.cancel),
                    _transition(context, ref, quote, QuoteStatut.expire,
                        'Expiré', Icons.timer_off),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              if (quote.statut == QuoteStatut.accepte)
                FilledButton.icon(
                  onPressed: () => _convert(context, ref, quote),
                  icon: const Icon(Icons.work, size: 18),
                  label: const Text('CONVERTIR EN COMMANDE'),
                ),
              const SizedBox(height: 24),
            ],
          );
      },
    ),
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

  Widget _transition(BuildContext context, WidgetRef ref, Quote quote,
      QuoteStatut to, String label, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () async {
        final dao = ref.read(documentsDaoProvider);
        await dao.setQuoteStatut(quote.id, to);
        await ref.read(activityLoggerProvider).log(
              action: ActivityAction.changementStatut,
              entite: 'devis',
              entityId: quote.id,
              details:
                  'Devis ${quote.reference} : ${quote.statut.label} → ${to.label}.',
            );
      },
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12.5)),
    );
  }

  String _devisMessage(Quote quote, DocumentTotals totals) {
    return 'Bonjour, voici votre devis ${quote.reference}.\n\n'
        'Montant total : ${Formatters.ar(totals.total)}\n'
        'Acompte à la commande : ${Formatters.ar(totals.acompte)}\n'
        'Solde après acompte : ${Formatters.ar(totals.solde)}\n'
        'Délai : ${quote.delaiJours == null ? 'à convenir' : '${quote.delaiJours} jours'}\n\n'
        'Le devis est valable ${quote.validiteJours} jours. Dès votre accord '
        'et l’acompte reçu, nous démarrons le travail.';
  }

  Future<void> _sharePdf(BuildContext context, WidgetRef ref, Quote quote,
      List items) async {
    final client = await ref.read(clientsDaoProvider).byId(quote.clientId);
    if (client == null || !context.mounted) return;
    try {
      final file = await runWithLoading(
        context,
        'Génération du PDF…',
        () => ref.read(pdfServiceProvider).quote(
              quote: quote,
              client: client,
              items: items.cast(),
            ),
      );
      if (context.mounted) {
        await ref
            .read(shareServiceProvider)
            .shareFile(file.path, subject: 'Devis ${quote.reference}');
      }
    } catch (e) {
      if (context.mounted) showMsnSnack(context, e.toString(), error: true);
    }
  }

  /// Format 2 — IMAGE : le PDF est rastérisé en PNG puis partagé.
  Future<void> _shareImage(BuildContext context, WidgetRef ref, Quote quote,
      List items) async {
    final client = await ref.read(clientsDaoProvider).byId(quote.clientId);
    if (client == null || !context.mounted) return;
    try {
      final pdfFile = await runWithLoading(
        context,
        'Génération du visuel…',
        () => ref.read(pdfServiceProvider).quote(
              quote: quote,
              client: client,
              items: items.cast(),
            ),
      );
      final png =
          await ref.read(pdfServiceProvider).rasterizeFirstPage(
                await pdfFile.readAsBytes(),
              );
      if (png == null) {
        throw StateError('Rasterisation impossible sur cet appareil.');
      }
      final dir = await BackupService.generatedDirectory(quote.reference);
      final imageFile = File(
          '${dir.path}/devis_${quote.reference}.png');
      await imageFile.writeAsBytes(png);
      if (context.mounted) {
        await ref.read(shareServiceProvider).shareFile(
              imageFile.path,
              subject: 'Devis ${quote.reference}',
            );
      }
    } catch (e) {
      if (context.mounted) showMsnSnack(context, e.toString(), error: true);
    }
  }

  Future<void> _convert(BuildContext context, WidgetRef ref, Quote quote) async {
    final ok = await confirmAction(
      context,
      title: 'Convertir en commande',
      message:
          'Une commande sera créée avec son workflow et ses rappels. '
          'Le devis passera en « converti ».',
      confirmLabel: 'Convertir',
    );
    if (!ok) return;
    try {
      final orderId = await runWithLoading(
        context,
        'Conversion en commande…',
        () => convertQuoteToOrder(ref, quote.id),
      );
      if (context.mounted) {
        showMsnSnack(context, 'Commande créée ! Ouverture…');
        context.push('/orders/$orderId');
      }
    } catch (e) {
      if (context.mounted) showMsnSnack(context, e.toString(), error: true);
    }
  }
}
