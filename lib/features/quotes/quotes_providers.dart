/// Providers devis — liste, détail, lignes, conversion en commande.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/domain/enums.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../core/workflow_bootstrap.dart';

final quotesFilterProvider = StateProvider<String?>((ref) => null);
final quotesSearchProvider = StateProvider<String>((ref) => '');

/// Liste enrichie (devis + client).
class QuoteRow {
  const QuoteRow({required this.quote, required this.clientNom});

  final Quote quote;
  final String clientNom;
}

final quotesProvider = StreamProvider<List<QuoteRow>>((ref) {
  final statut = ref.watch(quotesFilterProvider);
  final query = ref.watch(quotesSearchProvider);
  return ref.watch(documentsDaoProvider).watchQuotes(statut: statut, query: query).map(
      (rows) => rows
          .map((r) => QuoteRow(quote: r.quote, clientNom: r.clientNom))
          .toList());
});

final quoteProvider = StreamProvider.family<Quote?, String>((ref, id) {
  return ref.watch(documentsDaoProvider).watchQuote(id);
});

final quoteItemsProvider =
    StreamProvider.family<List<QuoteItem>, String>((ref, id) {
  return ref.watch(documentsDaoProvider).watchQuoteItems(id);
});

/// Convertit un devis accepté en commande avec workflow instancié.
/// DEMANDE → DEVIS → COMMANDE : aucune ressaisie (section 15).
Future<String> convertQuoteToOrder(WidgetRef ref, String quoteId,
    {String? notes}) async {
  final dao = ref.read(documentsDaoProvider);
  final quote = await dao.quoteById(quoteId);
  if (quote == null) {
    throw StateError('Devis introuvable : $quoteId');
  }
  if (quote.statut != QuoteStatut.accepte) {
    throw StateError('Le devis doit être accepté avant la conversion.');
  }
  final items = await dao.quoteItems(quoteId);

  final numbering = ref.read(numberingServiceProvider);
  final reference = await numbering.next('CMD');
  final now = DateTime.now();
  final orderId = 'cmd_${now.microsecondsSinceEpoch}';

  final firstServiceId = items.isEmpty ? null : items.first.serviceId;
  final titre = items.isEmpty
      ? 'Commande ${quote.reference}'
      : items.map((i) => i.designation).join(' + ');

  final order = Order(
    id: orderId,
    reference: reference,
    clientId: quote.clientId,
    serviceId: firstServiceId,
    requestId: quote.requestId,
    quoteId: quote.id,
    titre: titre,
    statut: OrderStatut.enCours,
    deadline:
        quote.delaiJours == null ? null : now.add(Duration(days: quote.delaiJours!)),
    montantTotal: quote.montantTotal,
    acompteRequis: quote.acompte,
    conditionsAcceptees: true,
    briefComplet: false,
    pretPourProduction: false,
    transferePc: false,
    notes: notes,
    createdAt: now,
    updatedAt: now,
  );
  await ref.read(ordersDaoProvider).upsert(order);

  // Instanciation du workflow du service (ou générique).
  await bootstrapWorkflowForOrder(ref, order);

  // Copie des fichiers éventuellement joints à la demande.
  final requestId = quote.requestId;
  if (requestId != null) {
    final requestFiles =
        await ref.read(ordersDaoProvider).filesForRequest(requestId);
    for (final f in requestFiles) {
      await ref.read(ordersDaoProvider).insertFile(
            OrderFile(
              id: 'file_${now.microsecondsSinceEpoch}_${f.id}',
              orderId: orderId,
              requestId: null,
              dossier: f.dossier,
              nom: f.nom,
              cheminLocal: f.cheminLocal,
              taille: f.taille,
              mime: f.mime,
              origine: f.origine,
              note: f.note,
              createdAt: now,
            ),
          );
    }
  }

  await dao.setQuoteStatut(quoteId, QuoteStatut.converti);
  await ref.read(syncEngineProvider).enqueue(
        entite: 'orders',
        entityId: orderId,
        operation: SyncOperation.create,
        payload: {'reference': reference, 'quoteId': quoteId},
      );
  await ref.read(activityLoggerProvider).log(
        action: ActivityAction.creation,
        entite: 'commande',
        entityId: orderId,
        details: 'Commande $reference créée depuis le devis '
            '${quote.reference} ($titre).',
      );
  return orderId;
}

// petit helper de lecture d'un client (utilisé par l'UI du devis)
Future<Client?> loadClient(Ref ref, String clientId) =>
    ref.read(clientsDaoProvider).byId(clientId);
