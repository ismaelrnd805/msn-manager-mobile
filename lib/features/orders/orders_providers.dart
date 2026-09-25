/// Providers commandes — suivi workflow, paiements, fichiers, transfert PC.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/domain/business_rules.dart';
import '../../core/domain/enums.dart';
import '../../core/providers/database_provider.dart';
import '../../core/database/daos/orders_dao.dart';
import '../../core/providers/services_providers.dart';
import '../../core/utils/formatters.dart';

final ordersFilterProvider = StateProvider<String?>((ref) => null);
final ordersSearchProvider = StateProvider<String>((ref) => '');

class OrderRow {
  const OrderRow({required this.order, required this.clientNom});

  final Order order;
  final String clientNom;
}

final ordersProvider = StreamProvider<List<OrderRow>>((ref) {
  final statut = ref.watch(ordersFilterProvider);
  final query = ref.watch(ordersSearchProvider);
  return ref.watch(ordersDaoProvider).watchOrders(statut: statut, query: query).map(
      (rows) => rows
          .map((r) => OrderRow(order: r.order, clientNom: r.clientNom))
          .toList());
});

/// Détail commande + client.
final orderDetailProvider =
    StreamProvider.family<OrderWithClient?, String>((ref, id) {
  return ref.watch(ordersDaoProvider).watchById(id);
});

/// Instance de workflow de la commande.
final orderInstanceProvider =
    StreamProvider.family<WorkflowInstance?, String>((ref, orderId) {
  return ref.watch(workflowsDaoProvider).watchInstanceForOrder(orderId);
});

/// États des étapes de l'instance.
final instanceStatesProvider =
    StreamProvider.family<List<WorkflowStepState>, String>((ref, instanceId) {
  return ref.watch(workflowsDaoProvider).watchStepStates(instanceId);
});

/// Total encaissé pour la commande.
final orderPaidProvider = StreamProvider.family<int, String>((ref, orderId) {
  return ref.watch(paymentsDaoProvider).watchTotalForOrder(orderId);
});

/// Fichiers de la commande.
final orderFilesProvider =
    StreamProvider.family<List<OrderFile>, String>((ref, orderId) {
  return ref.watch(ordersDaoProvider).watchFilesForOrder(orderId);
});

/// Devis lié (pour la checklist transfert PC).
final orderLinkedQuoteProvider =
    FutureProvider.family<Quote?, String>((ref, quoteId) {
  return ref.watch(documentsDaoProvider).quoteById(quoteId);
});

/// Exceptions déjà accordées sur la commande.
final orderExceptionsProvider =
    StreamProvider.family<List<RuleException>, String>((ref, orderId) {
  return ref.watch(templatesDaoProvider).watchExceptionsForOrder(orderId);
});

/// Termine l'étape courante (après validation des règles par l'appelant)
/// et met à jour le statut de la commande en conséquence.
Future<void> completeStep(
  WidgetRef ref, {
  required Order order,
  required WorkflowInstance instance,
  required WorkflowStepState stepState,
  required int nextIndex,
  String? note,
}) async {
  await ref.read(workflowsDaoProvider).completeStep(
        instanceId: instance.id,
        stepStateId: stepState.id,
        newStepIndex: nextIndex,
        note: note,
      );

  // Statut de la commande synchronisé avec les étapes clés.
  final stepName = stepState.nom.toLowerCase();
  if (stepName.contains('livraison') || stepName.contains('livr')) {
    await ref.read(ordersDaoProvider).updateStatut(order.id, OrderStatut.livree);
  } else if (stepName.contains('production') || stepName.contains('brief')) {
    await ref.read(ordersDaoProvider).updateStatut(
        order.id, OrderStatut.enProduction);
  }
  if (stepName.contains('brief')) {
    await ref.read(ordersDaoProvider).setBriefComplet(order.id, briefComplet: true);
  }

  await ref.read(activityLoggerProvider).log(
        action: ActivityAction.changementStatut,
        entite: 'commande',
        entityId: order.id,
        details:
            '${order.reference} : étape « ${stepState.nom} » terminée.',
      );
}

/// Construit le contexte de règles pour la commande (moteur section 23).
Future<RuleContext> buildRuleContext(
  WidgetRef ref, {
  required Order order,
  required int paidTotal,
  required List<WorkflowStepState> states,
  required String stepName,
  required bool devisAccepte,
  required int nbFichiers,
}) async {
  final validationClient = states.any((s) =>
      s.nom.toLowerCase().contains('validation') &&
      s.statut == 'terminee');
  return RuleContext(
    nomEtape: stepName,
    totalPaye: paidTotal,
    totalCommande: order.montantTotal,
    devisAccepte: devisAccepte,
    validationClient: validationClient,
    nbFichiers: nbFichiers,
    conditionsAcceptees: order.conditionsAcceptees,
    briefComplet: order.briefComplet,
  );
}

/// Marque la commande prête pour production et déclenche le transfert PC
/// (section 20) : checklist verte obligatoire avant l'appel.
Future<void> transferToPc(WidgetRef ref, Order order) async {
  await ref.read(ordersDaoProvider).markPretPourProduction(order.id);
  await ref.read(ordersDaoProvider).markTransfere(order.id);
  await ref.read(syncEngineProvider).enqueue(
        entite: 'orders',
        entityId: order.id,
        operation: SyncOperation.update,
        payload: {
          'pretPourProduction': true,
          'transferePc': true,
          'transfereLe': DateTime.now().toIso8601String(),
        },
      );
  await ref.read(activityLoggerProvider).log(
        action: ActivityAction.transfertPc,
        entite: 'commande',
        entityId: order.id,
        details:
            'Commande ${order.reference} transférée au PC pour production '
            '(deadline : ${Formatters.date(order.deadline)}).',
      );
}

/// Enregistre une EXCEPTION AUTORISÉE (raison + utilisateur + horodatage).
Future<void> recordRuleException(
  WidgetRef ref, {
  required String orderId,
  required String ruleKey,
  required String raison,
  required String userName,
}) async {
  final now = DateTime.now();
  await ref.read(templatesDaoProvider).insertRuleException(RuleException(
        id: 'rex_${now.microsecondsSinceEpoch}',
        orderId: orderId,
        ruleKey: ruleKey,
        raison: raison,
        userName: userName,
        createdAt: now,
      ));
  await ref.read(activityLoggerProvider).log(
        action: ActivityAction.exceptionRegles,
        entite: 'commande',
        entityId: orderId,
        details:
            'Exception autorisée « $ruleKey » : $raison (par $userName).',
      );
}
