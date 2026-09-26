/// Administration — workflows et fiches d'instructions des étapes.
///
/// Pour chaque modèle de workflow, l'administrateur décrit précisément
/// chaque étape : quoi faire, pourquoi, qui, fichiers nécessaires,
/// résultat attendu et conditions de validation. La progression des
/// commandes affiche ces fiches aux opérateurs.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../core/domain/enums.dart';
import '../../shared/widgets/empty_state.dart';
import '../../core/theme/msn_theme.dart';
import '../../shared/widgets/feedback.dart';
import '../../shared/widgets/form_fields.dart';

final _workflowsProvider = StreamProvider<List<WorkflowTemplate>>((ref) {
  return ref.watch(workflowsDaoProvider).watchTemplates();
});

class AdminWorkflowsScreen extends ConsumerWidget {
  const AdminWorkflowsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workflows = ref.watch(_workflowsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Workflows & instructions')),
      body: workflows.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Erreur : $e',
                style: const TextStyle(color: MsnColors.danger))),
        data: (list) => list.isEmpty
            ? const EmptyState(
                icon: Icons.account_tree_outlined,
                title: 'Aucun workflow',
                message:
                    'Les workflows définissent les étapes de production des '
                    'commandes. Définissez-les puis détaillez chaque étape.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final w = list[i];
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: MsnColors.accentSoft,
                        child: Icon(Icons.account_tree,
                            size: 20, color: MsnColors.primary),
                      ),
                      title: Text(w.nom,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      subtitle: Text(
                          w.description ?? 'Aucune description',
                          style: const TextStyle(fontSize: 12.5)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showSteps(context, ref, w),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _showSteps(
      BuildContext context, WidgetRef ref, WorkflowTemplate w) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _WorkflowStepsScreen(workflow: w),
    ));
  }
}

/// Éditeur des étapes d'un workflow : fiche d'instructions par étape.
class _WorkflowStepsScreen extends ConsumerStatefulWidget {
  const _WorkflowStepsScreen({required this.workflow});

  final WorkflowTemplate workflow;

  @override
  ConsumerState<_WorkflowStepsScreen> createState() =>
      _WorkflowStepsScreenState();
}

class _WorkflowStepsScreenState extends ConsumerState<_WorkflowStepsScreen> {
  List<WorkflowStep>? _steps;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final steps = await ref
        .read(workflowsDaoProvider)
        .stepsForTemplate(widget.workflow.id);
    if (mounted) setState(() => _steps = steps);
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps;
    return Scaffold(
      appBar: AppBar(title: Text(widget.workflow.nom)),
      body: steps == null
          ? const Center(child: CircularProgressIndicator())
          : steps.isEmpty
              ? const EmptyState(
                  icon: Icons.format_list_numbered,
                  title: 'Aucune étape',
                  message: 'Ce workflow n\'a pas encore d\'étapes.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: steps.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final s = steps[i];
                    final complete = s.description != null &&
                        s.description!.trim().isNotEmpty;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: complete
                              ? MsnColors.accentSoft
                              : MsnColors.surface,
                          child: Text('${i + 1}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: complete
                                      ? MsnColors.primary
                                      : MsnColors.textSecondary)),
                        ),
                        title: Text(s.nom,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: Text(
                          complete
                              ? 'Instructions complétées'
                              : 'Instructions à compléter',
                          style: TextStyle(
                              fontSize: 12,
                              color: complete
                                  ? MsnColors.textSecondary
                                  : MsnColors.warning),
                        ),
                        trailing: const Icon(Icons.edit_note),
                        onTap: () => _editStep(context, s),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _editStep(BuildContext context, WorkflowStep step) async {
    final description = TextEditingController(text: step.description);
    final responsable = TextEditingController(text: step.responsable);
    final fichiers = TextEditingController(text: step.fichiersRequis);
    final resultat = TextEditingController(text: step.resultatAttendu);
    final conditions = TextEditingController(text: step.conditionsValidation);

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
            18, 18, 18, 18 + MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Étape : ${step.nom}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 4),
              const Text('Fiche d\'instructions visible par les opérateurs',
                  style: TextStyle(
                      fontSize: 12, color: MsnColors.textSecondary)),
              const SizedBox(height: 14),
              MsnTextField(
                  label: 'Quoi faire / pourquoi',
                  controller: description,
                  maxLines: 3),
              MsnTextField(
                  label: 'Qui doit le faire', controller: responsable),
              MsnTextField(
                  label: 'Fichiers nécessaires', controller: fichiers),
              MsnTextField(
                  label: 'Résultat attendu',
                  controller: resultat,
                  maxLines: 2),
              MsnTextField(
                  label: 'Conditions de validation',
                  controller: conditions,
                  maxLines: 2),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('ENREGISTRER LA FICHE'),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok != true || !mounted) return;

    String? clean(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();

    final updated = WorkflowStep(
      id: step.id,
      workflowId: step.workflowId,
      ordre: step.ordre,
      nom: step.nom,
      actionsJson: step.actionsJson,
      description: clean(description),
      responsable: clean(responsable),
      fichiersRequis: clean(fichiers),
      resultatAttendu: clean(resultat),
      conditionsValidation: clean(conditions),
    );
    await ref.read(workflowsDaoProvider).updateStepInstructions(updated);
    await ref.read(activityLoggerProvider).log(
          action: ActivityAction.modificationWorkflow,
          entite: 'workflow',
          entityId: step.id,
          details: 'Instructions de l\'étape « ${step.nom} » mises à jour.',
        );
    await _reload();
    if (mounted) {
      showMsnSnack(context, 'Fiche enregistrée.');
    }
  }
}
