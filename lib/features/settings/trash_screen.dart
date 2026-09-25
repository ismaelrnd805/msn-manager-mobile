/// Corbeille — suppression douce avec restauration et purge définitive
/// réservée à l'administration (section 26 : jamais de suppression
/// définitive sans confirmation et permission).
library;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/session.dart';
import '../../core/domain/enums.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../core/sync/sync_engine.dart';
import '../../core/theme/msn_theme.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/feedback.dart';
import '../clients/clients_providers.dart';

final ordersTrashProvider = StreamProvider<List<Order>>((ref) {
  return ref.watch(ordersDaoProvider).watchDeleted();
});

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(clientsTrashProvider);
    final orders = ref.watch(ordersTrashProvider);
    final session = ref.watch(sessionProvider);
    final isAdmin = session?.isAdmin ?? false;

    final clientsList = clients.value ?? const [];
    final ordersList = orders.value ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Corbeille')),
      body: clientsList.isEmpty && ordersList.isEmpty
          ? const EmptyState(
              icon: Icons.delete_outline,
              title: 'La corbeille est vide',
              message:
                  'Les clients et commandes supprimés apparaîtront ici '
                  'et pourront être restaurés.',
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                for (final c in clientsList)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.person_off_outlined),
                      title: Text(c.nom, style: const TextStyle(fontSize: 13.5)),
                      subtitle: const Text('Client',
                          style: TextStyle(fontSize: 11)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Restaurer',
                            icon: const Icon(Icons.restore, size: 20),
                            onPressed: () async {
                              await ref.read(clientsDaoProvider).restore(c.id);
                              await ref.read(activityLoggerProvider).log(
                                    action: ActivityAction.modification,
                                    entite: 'client',
                                    entityId: c.id,
                                    details:
                                        'Client « ${c.nom} » restauré depuis la corbeille.',
                                  );
                            },
                          ),
                          if (isAdmin)
                            IconButton(
                              tooltip: 'Purge définitive',
                              icon: const Icon(Icons.delete_forever,
                                  size: 20, color: MsnColors.danger),
                              onPressed: () => _purge(
                                  context,
                                  ref,
                                  'client',
                                  c.nom,
                                  () => ref
                                      .read(clientsDaoProvider)
                                      .purge(c.id)),
                            ),
                        ],
                      ),
                    ),
                  ),
                for (final o in ordersList)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.work_off_outlined),
                      title: Text('${o.reference} — ${o.titre}',
                          style: const TextStyle(fontSize: 13.5)),
                      subtitle: const Text('Commande',
                          style: TextStyle(fontSize: 11)),
                      trailing: IconButton(
                        tooltip: 'Restaurer',
                        icon: const Icon(Icons.restore, size: 20),
                        onPressed: () async {
                          await ref.read(ordersDaoProvider).restore(o.id);
                          await ref.read(activityLoggerProvider).log(
                                action: ActivityAction.modification,
                                entite: 'commande',
                                entityId: o.id,
                                details:
                                    'Commande ${o.reference} restaurée.',
                              );
                        },
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Future<void> _purge(BuildContext context, WidgetRef ref, String entite,
      String nom, Future<void> Function() purge) async {
    final ok = await confirmAction(
      context,
      title: 'Purge définitive',
      message:
          '« $nom » ($entite) sera supprimé définitivement. '
          'Cette action est irréversible.',
      confirmLabel: 'Supprimer définitivement',
      danger: true,
    );
    if (!ok) return;
    await purge();
    await ref.read(activityLoggerProvider).log(
          action: ActivityAction.suppression,
          entite: entite,
          details: 'Purge définitive de « $nom ».',
        );
    if (context.mounted) showMsnSnack(context, 'Purge effectuée.');
  }
}
