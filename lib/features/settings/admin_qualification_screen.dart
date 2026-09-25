/// Gestion des questions de qualification (admin) — créer/modifier les
/// formulaires SANS toucher au code (section 9).
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/domain/enums.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../shared/widgets/feedback.dart';

class AdminQualificationScreen extends ConsumerStatefulWidget {
  const AdminQualificationScreen({super.key});

  @override
  ConsumerState<AdminQualificationScreen> createState() =>
      _AdminQualificationScreenState();
}

class _AdminQualificationScreenState
    extends ConsumerState<AdminQualificationScreen> {
  String? _serviceId;

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(catalogServicesForPick);

    return Scaffold(
      appBar: AppBar(title: const Text('Questions de qualification')),
      body: servicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (services) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: DropdownButtonFormField<String>(
                value: _serviceId,
                isExpanded: true,
                decoration:
                    const InputDecoration(labelText: 'Service à configurer'),
                items: services
                    .map((s) => DropdownMenuItem(
                          value: s.id,
                          child: Text(s.nom),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _serviceId = v),
              ),
            ),
            Expanded(
              child: _serviceId == null
                  ? const Center(
                      child: Text(
                          'Choisissez un service pour éditer son formulaire.',
                          style: TextStyle(color: MsnColors.textSecondary)))
                  : _QuestionsEditor(serviceId: _serviceId!),
            ),
          ],
        ),
      ),
    );
  }
}

/// Alias local pour le provider du catalogue.
final catalogServicesForPick = StreamProvider<List<Service>>((ref) {
  return ref.watch(catalogDaoProvider).watchServices(onlyActive: true).map(
      (rows) => rows.map((r) => r.service).toList());
});

class _QuestionsEditor extends ConsumerWidget {
  const _QuestionsEditor({required this.serviceId});

  final String serviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formAsync =
        ref.watch(serviceFormProvider(serviceId));
    return formAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (form) {
        if (form == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Aucun formulaire pour ce service.'),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    await ref.read(templatesDaoProvider).upsertForm(
                          QualificationForm(
                            id: 'form_$serviceId',
                            serviceId: serviceId,
                            nom: 'Formulaire de qualification',
                            actif: true,
                            createdAt: now,
                          ),
                        );
                    if (context.mounted) {
                      showMsnSnack(context, 'Formulaire créé.');
                    }
                  },
                  child: const Text('Créer le formulaire'),
                ),
              ],
            ),
          );
        }
        final questions =
            ref.watch(questionsProvider(form.id));
        return questions.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (list) => ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => _editQuestion(context, ref, form.id, null),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter une question'),
                ),
              ),
              const SizedBox(height: 8),
              ...list.map((q) => Card(
                    child: ListTile(
                      leading: Text('${q.ordre + 1}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: MsnColors.primaryDark)),
                      title: Text(q.label,
                          style: const TextStyle(fontSize: 13)),
                      subtitle: Text(
                          '${q.type.label}${q.obligatoire ? ' · obligatoire' : ''}',
                          style: const TextStyle(fontSize: 11)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 16),
                            onPressed: () => _editQuestion(
                                context, ref, form.id, q),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 16),
                            onPressed: () async {
                              await ref
                                  .read(templatesDaoProvider)
                                  .deleteQuestion(q.id);
                              await ref
                                  .read(activityLoggerProvider)
                                  .log(
                                    action: ActivityAction.modification,
                                    entite: 'qualification',
                                    entityId: serviceId,
                                    details:
                                        'Question supprimée : « ${q.label} ».',
                                  );
                            },
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editQuestion(BuildContext context, WidgetRef ref,
      String formId, QualificationQuestion? existing) async {
    final label = TextEditingController(text: existing?.label ?? '');
    QuestionType type = existing?.type ?? QuestionType.texte;
    bool obligatoire = existing?.obligatoire ?? false;
    final options = TextEditingController(
        text: existing?.optionsJson == null
            ? ''
            : _prettyList(existing!.optionsJson!));

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing == null
              ? 'Nouvelle question'
              : 'Modifier la question'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: label,
                  autofocus: true,
                  decoration:
                      const InputDecoration(labelText: 'Question *'),
                ),
                DropdownButtonFormField<QuestionType>(
                  value: type,
                  decoration:
                      const InputDecoration(labelText: 'Type de réponse'),
                  items: QuestionType.values
                      .map((t) => DropdownMenuItem(
                          value: t, child: Text(t.label)))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => type = v ?? QuestionType.texte),
                ),
                if (type == QuestionType.liste)
                  TextField(
                    controller: options,
                    decoration: const InputDecoration(
                        labelText: 'Options (une par ligne)'),
                    maxLines: 3,
                  ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Réponse obligatoire',
                      style: TextStyle(fontSize: 13)),
                  value: obligatoire,
                  onChanged: (v) => setDialogState(() => obligatoire = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Enregistrer')),
          ],
        ),
      ),
    );
    if (ok != true || label.text.trim().isEmpty) return;

    String? optionsJson;
    if (type == QuestionType.liste && options.text.trim().isNotEmpty) {
      optionsJson = jsonEncode(options.text
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList());
    }
    final dao = ref.read(templatesDaoProvider);
    final count = (await dao.questions(formId)).length;
    await dao.upsertQuestion(QualificationQuestion(
      id: existing?.id ??
          'q_${DateTime.now().microsecondsSinceEpoch}',
      formId: formId,
      ordre: existing?.ordre ?? count,
      label: label.text.trim(),
      type: type,
      optionsJson: optionsJson,
      obligatoire: obligatoire,
    ));
    await ref.read(activityLoggerProvider).log(
          action: ActivityAction.modification,
          entite: 'qualification',
          entityId: formId,
          details: existing == null
              ? 'Question ajoutée : « ${label.text.trim()} ».'
              : 'Question modifiée : « ${label.text.trim()} ».',
        );
  }

  String _prettyList(String json) {
    try {
      final list = jsonDecode(json) as List;
      return list.join('\n');
    } catch (_) {
      return '';
    }
  }
}

final serviceFormProvider =
    FutureProvider.family<QualificationForm?, String>((ref, serviceId) {
  return ref.watch(templatesDaoProvider).formForService(serviceId);
});

final questionsProvider =
    StreamProvider.family<List<QualificationQuestion>, String>((ref, formId) {
  return ref.watch(templatesDaoProvider).watchQuestions(formId);
});
