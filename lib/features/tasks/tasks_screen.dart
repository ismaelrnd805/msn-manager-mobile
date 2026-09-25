/// Tâches & rappels — deadlines, relances, validations, acomptes, soldes
/// (section 22). Chaque rappel peut être terminé ; les tâches libres
/// aident à l'organisation quotidienne.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/domain/enums.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../core/theme/msn_theme.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/form_fields.dart';

final remindersProvider = StreamProvider<List<Reminder>>((ref) {
  return ref.watch(systemDaoProvider).watchReminders(onlyActive: true);
});

final tasksProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(systemDaoProvider).watchTasks(onlyOpen: true);
});

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(remindersProvider);
    final tasks = ref.watch(tasksProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tâches & rappels'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Rappels'),
              Tab(text: 'Tâches'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _addTask(context, ref),
          icon: const Icon(Icons.add_task),
          label: const Text('Tâche'),
        ),
        body: TabBarView(
          children: [
            // ── Rappels ─────────────────────────────────────────────────
            reminders.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (list) {
                final sorted = [...list]..sort((a, b) =>
                    a.dateRappel.compareTo(b.dateRappel));
                if (sorted.isEmpty) {
                  return const EmptyState(
                    icon: Icons.alarm_off,
                    title: 'Aucun rappel actif',
                    message:
                        'Les rappels sont créés automatiquement (deadlines, '
                        'acomptes, soldes) ou manuellement.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: sorted.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final r = sorted[index];
                    final overdue = Formatters.daysUntil(r.dateRappel) < 0;
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.alarm,
                          color: overdue ? MsnColors.danger : MsnColors.warning,
                        ),
                        title: Text(r.titre,
                            style: const TextStyle(fontSize: 13.5)),
                        subtitle: Text(
                          '${r.type.label} · ${Formatters.dateTime(r.dateRappel)}'
                          '${r.description != null ? '\n${r.description}' : ''}',
                          style: const TextStyle(fontSize: 11.5),
                        ),
                        isThreeLine: r.description != null,
                        trailing: IconButton(
                          icon: const Icon(Icons.check_circle_outline,
                              color: MsnColors.success),
                          onPressed: () async {
                            await ref
                                .read(systemDaoProvider)
                                .markReminderDone(r.id);
                            await ref
                                .read(activityLoggerProvider)
                                .log(
                                  action: ActivityAction.validation,
                                  entite: 'rappel',
                                  entityId: r.id,
                                  details: 'Rappel traité : ${r.titre}',
                                );
                          },
                        ),
                        onTap: r.cibleId != null && r.cibleType == 'order'
                            ? () => context.push('/orders/${r.cibleId}')
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
            // ── Tâches ──────────────────────────────────────────────────
            tasks.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (list) => list.isEmpty
                  ? const EmptyState(
                      icon: Icons.task_outlined,
                      title: 'Aucune tâche en cours',
                      message:
                          'Ajoutez vos tâches quotidiennes (production, '
                          'relances, contrôles…).',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final t = list[index];
                        return Card(
                          child: CheckboxListTile(
                            value: t.statut == TaskStatut.terminee,
                            onChanged: (_) async {
                              await ref.read(systemDaoProvider).upsertTask(
                                    Task(
                                      id: t.id,
                                      titre: t.titre,
                                      description: t.description,
                                      priorite: t.priorite,
                                      echeance: t.echeance,
                                      statut: t.statut == TaskStatut.terminee
                                          ? TaskStatut.aFaire
                                          : TaskStatut.terminee,
                                      cibleType: t.cibleType,
                                      cibleId: t.cibleId,
                                      createdAt: t.createdAt,
                                    ),
                                  );
                            },
                            title: Text(t.titre,
                                style: TextStyle(
                                    fontSize: 13.5,
                                    decoration:
                                        t.statut == TaskStatut.terminee
                                            ? TextDecoration.lineThrough
                                            : null)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (t.echeance != null)
                                  Text(
                                      'Échéance : '
                                      '${Formatters.dateShort(t.echeance)}',
                                      style: const TextStyle(fontSize: 11.5)),
                              ],
                            ),
                            secondary: PriorityBadge(priorite: t.priorite),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addTask(BuildContext context, WidgetRef ref) async {
    final titre = TextEditingController();
    DateTime? deadline;
    final picked = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nouvelle tâche'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MsnTextField(
                label: 'Titre *',
                controller: titre,
                autofocus: true,
              ),
              MsnDateField(
                label: 'Échéance (optionnel)',
                value: deadline,
                onChanged: (v) => setDialogState(() => deadline = v),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Ajouter')),
          ],
        ),
      ),
    );
    if (picked != true || titre.text.trim().isEmpty || !context.mounted) return;
    final now = DateTime.now();
    await ref.read(systemDaoProvider).upsertTask(
          Task(
            id: 'task_${now.microsecondsSinceEpoch}',
            titre: titre.text.trim(),
            priorite: Priorite.normale,
            echeance: deadline,
            statut: TaskStatut.aFaire,
            createdAt: now,
          ),
        );
  }
}
