/// Amorçage du workflow d'une commande : sélection du modèle de workflow
/// du service (ou générique), instanciation des étapes et création des
/// rappels associés (deadline).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/app_database.dart';
import 'domain/enums.dart';
import 'providers/database_provider.dart';
import 'providers/services_providers.dart';

/// Instancie le workflow et les rappels pour une commande donnée.
Future<void> bootstrapWorkflowForOrder(Ref ref, Order order) async {
  final workflows = ref.read(workflowsDaoProvider);
  final template = await workflows.templateForService(order.serviceId);
  if (template == null) {
    // Aucun workflow défini : la commande progresse sans machine à états.
    // L'administrateur peut créer un workflow générique à tout moment.
    return;
  }
  final steps = await workflows.stepsForTemplate(template.id);
  final instanceId = 'wfi_${order.id}';
  await workflows.instantiate(
    instanceId: instanceId,
    orderId: order.id,
    workflowId: template.id,
    steps: steps,
  );

  // Rappel de deadline (J-1 par rapport à la date convenue).
  if (order.deadline != null) {
    final reminderDate =
        order.deadline!.subtract(const Duration(days: 1));
    final system = ref.read(systemDaoProvider);
    final reminder = Reminder(
      id: 'rem_${order.id}_deadline',
      titre: 'Deadline : ${order.reference} — ${order.titre}',
      description: 'Livraison prévue le ${order.deadline}.',
      type: ReminderType.deadline,
      cibleType: 'order',
      cibleId: order.id,
      dateRappel: reminderDate.isBefore(DateTime.now())
          ? DateTime.now().add(const Duration(hours: 1))
          : reminderDate,
      createdAt: DateTime.now(),
    );
    await system.upsertReminder(reminder);
    await ref.read(notificationServiceProvider).schedule(
          id: reminder.id.hashCode & 0x7fffffff,
          title: reminder.titre,
          body: reminder.description ?? reminder.type.label,
          when: reminder.dateRappel,
        );
  }
}
