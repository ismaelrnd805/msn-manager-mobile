/// Administration — processus de prise en charge client (CRUD).
///
/// Les 10 étapes présentées au client (de la demande à la finalisation)
/// vivent ici : ordre, titres, descriptions et icônes sont administrables.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../core/domain/enums.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/feedback.dart';
import '../../core/theme/msn_theme.dart';
import '../../shared/widgets/form_fields.dart';

/// Icônes Material proposées pour chaque étape (nom → icône).
const Map<String, IconData> processIcons = {
  'inbox': Icons.inbox,
  'search': Icons.search,
  'fact_check': Icons.fact_check,
  'request_quote': Icons.request_quote,
  'verified': Icons.verified,
  'attach_file': Icons.attach_file,
  'build': Icons.build,
  'rule': Icons.rule,
  'local_shipping': Icons.local_shipping,
  'task_alt': Icons.task_alt,
  'payments': Icons.payments,
  'support_agent': Icons.support_agent,
  'chat': Icons.chat,
  'description': Icons.description,
  'print': Icons.print,
  'edit': Icons.edit,
};

final _processProvider = StreamProvider<List<ProcessStep>>((ref) {
  return ref.watch(workflowsDaoProvider).watchAllProcessSteps();
});

class AdminProcessScreen extends ConsumerWidget {
  const AdminProcessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final steps = ref.watch(_processProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Processus client')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle étape'),
      ),
      body: steps.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Erreur : $e',
                style: const TextStyle(color: MsnColors.danger))),
        data: (list) => list.isEmpty
            ? const EmptyState(
                icon: Icons.route,
                title: 'Aucune étape',
                message:
                    'Décrivez ici le parcours client : de la demande à la '
                    'finalisation. Ce processus est présenté aux clients.',
              )
            : ReorderableListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
                itemCount: list.length,
                onReorder: (oldIndex, newIndex) async {
                  // Réordonnancement persistant.
                  final dao = ref.read(workflowsDaoProvider);
                  final updated = [...list];
                  if (newIndex > oldIndex) newIndex--;
                  final moved = updated.removeAt(oldIndex);
                  updated.insert(newIndex, moved);
                  for (var i = 0; i < updated.length; i++) {
                    await dao.upsertProcessStep(ProcessStep(
                      id: updated[i].id,
                      titre: updated[i].titre,
                      description: updated[i].description,
                      icone: updated[i].icone,
                      ordre: i,
                      actif: updated[i].actif,
                      updatedAt: DateTime.now(),
                    ));
                  }
                  await ref.read(activityLoggerProvider).log(
                        action: ActivityAction.modification,
                        entite: 'processus',
                        details: 'Ordre du processus client modifié.',
                      );
                },
                itemBuilder: (context, i) {
                  final s = list[i];
                  return Card(
                    key: ValueKey(s.id),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: MsnColors.accentSoft,
                        child: Icon(
                            processIcons[s.icone] ?? Icons.check_circle,
                            size: 20,
                            color: MsnColors.primary),
                      ),
                      title: Text('${i + 1}. ${s.titre}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13.5)),
                      subtitle: s.description == null
                          ? null
                          : Text(s.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.drag_handle,
                              size: 18,
                              color: MsnColors.textSecondary
                                  .withValues(alpha: 0.6)),
                          PopupMenuButton<String>(
                            onSelected: (v) async {
                              if (v == 'edit') {
                                await _edit(context, ref, s);
                              } else if (v == 'toggle') {
                                await ref.read(workflowsDaoProvider).upsertProcessStep(
                                    ProcessStep(
                                        id: s.id,
                                        titre: s.titre,
                                        description: s.description,
                                        icone: s.icone,
                                        ordre: s.ordre,
                                        actif: !s.actif,
                                        updatedAt: DateTime.now()));
                              } else if (v == 'delete') {
                                await _delete(context, ref, s);
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                  value: 'edit', child: Text('Modifier')),
                              PopupMenuItem(
                                  value: 'toggle',
                                  child: Text(s.actif
                                      ? 'Masquer'
                                      : 'Afficher')),
                              const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Supprimer',
                                      style: TextStyle(
                                          color: MsnColors.danger))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _edit(
      BuildContext context, WidgetRef ref, ProcessStep? existing) async {
    final titre = TextEditingController(text: existing?.titre);
    final description = TextEditingController(text: existing?.description);
    var icone = existing?.icone ?? 'task_alt';
    var actif = existing?.actif ?? true;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              18, 18, 18, 18 + MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(existing == null ? 'Nouvelle étape' : 'Modifier l\'étape',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 14),
              MsnTextField(label: 'Titre *', controller: titre, autofocus: true),
              MsnTextField(
                  label: 'Description',
                  controller: description,
                  maxLines: 3),
              const SizedBox(height: 6),
              const Text('Icône',
                  style: TextStyle(
                      fontSize: 12, color: MsnColors.textSecondary)),
              const SizedBox(height: 6),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: processIcons.entries
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Icon(e.value, size: 18),
                              selected: icone == e.key,
                              onSelected: (_) =>
                                  setSheetState(() => icone = e.key),
                            ),
                          ))
                      .toList(),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Visible', style: TextStyle(fontSize: 14)),
                value: actif,
                onChanged: (v) => setSheetState(() => actif = v),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('ENREGISTRER'),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    if (titre.text.trim().isEmpty) {
      showMsnSnack(context, 'Le titre est obligatoire.', error: true);
      return;
    }
    final all = ref.read(_processProvider).value ?? const <ProcessStep>[];
    await ref.read(workflowsDaoProvider).upsertProcessStep(ProcessStep(
          id: existing?.id ??
              'proc_${DateTime.now().microsecondsSinceEpoch}',
          titre: titre.text.trim(),
          description: description.text.trim().isEmpty
              ? null
              : description.text.trim(),
          icone: icone,
          ordre: existing?.ordre ?? all.length,
          actif: actif,
          updatedAt: DateTime.now(),
        ));
    await ref.read(activityLoggerProvider).log(
          action: existing == null
              ? ActivityAction.creation
              : ActivityAction.modification,
          entite: 'processus',
          entityId: existing?.id,
          details: existing == null
              ? 'Étape « ${titre.text.trim()} » ajoutée au processus.'
              : 'Étape « ${titre.text.trim()} » modifiée.',
        );
    if (context.mounted) showMsnSnack(context, 'Étape enregistrée.');
  }

  Future<void> _delete(
      BuildContext context, WidgetRef ref, ProcessStep s) async {
    final ok = await confirmAction(context,
        title: 'Supprimer l\'étape ?',
        message: '« ${s.titre} » sera retirée du processus présenté '
            'aux clients.',
        danger: true);
    if (!ok) return;
    await ref.read(workflowsDaoProvider).deleteProcessStep(s.id);
    await ref.read(activityLoggerProvider).log(
          action: ActivityAction.suppression,
          entite: 'processus',
          entityId: s.id,
          details: 'Étape « ${s.titre} » supprimée du processus.',
        );
    if (context.mounted) showMsnSnack(context, 'Étape supprimée.');
  }
}
