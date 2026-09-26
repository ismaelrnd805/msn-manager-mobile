/// Qualification intelligente — formulaire dynamique défini par
/// l'administrateur pour chaque service (section 9).
///
/// Les questions viennent de la base : modifier un formulaire ne
/// nécessite AUCUNE mise à jour du code.
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/domain/enums.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/feedback.dart';
import '../../shared/widgets/form_fields.dart';
import '../catalog/catalog_providers.dart';
import 'requests_providers.dart';

/// Questions d'un formulaire (flux).
final qualificationQuestionsProvider =
    StreamProvider.family<List<QualificationQuestion>, String>((ref, formId) {
  return ref.watch(templatesDaoProvider).watchQuestions(formId);
});

class QualificationScreen extends ConsumerStatefulWidget {
  const QualificationScreen({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<QualificationScreen> createState() =>
      _QualificationScreenState();
}

class _QualificationScreenState extends ConsumerState<QualificationScreen> {
  final _answers = <String, TextEditingController>{};
  final _dates = <String, DateTime?>{};
  final _choices = <String, String>{};
  bool _savedExisting = false;

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(requestDetailProvider(widget.requestId));
    final serviceId = detail.value?.request.serviceId;

    return Scaffold(
      appBar: AppBar(title: const Text('Qualifier la demande')),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (row) {
          if (row == null) {
            return const Center(child: Text('Demande introuvable'));
          }
          if (serviceId == null) {
            return const EmptyState(
              icon: Icons.help_outline,
              title: 'Aucun service associé',
              message:
                  'Modifiez la demande et sélectionnez un service pour '
                  'afficher son formulaire de qualification.',
            );
          }
          final form =
              ref.watch(serviceQualificationFormProvider(serviceId));
          return form.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (form) {
              if (form == null) {
                return const EmptyState(
                  icon: Icons.fact_check_outlined,
                  title: 'Pas de formulaire pour ce service',
                  message:
                      'L’administrateur peut créer un formulaire de '
                      'qualification dans Administration > Questions.',
                );
              }
              final questions =
                  ref.watch(qualificationQuestionsProvider(form.id));
              return questions.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e')),
                data: (list) => _buildForm(context, row, form, list),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    RequestWithClientRow row,
    QualificationForm form,
    List<QualificationQuestion> questions,
  ) {
    // Pré-remplissage avec les réponses existantes (requalification).
    if (!_savedExisting && row.request.qualificationJson != null) {
      try {
        final existing =
            jsonDecode(row.request.qualificationJson!) as Map<String, dynamic>;
        for (final q in questions) {
          final v = existing[q.label];
          if (v != null) {
            if (q.type == QuestionType.date) {
              _dates[q.label] = DateTime.tryParse(v.toString());
            } else if (q.type == QuestionType.liste) {
              _choices[q.label] = v.toString();
            } else {
              _answers.putIfAbsent(q.label, () => TextEditingController(text: v.toString()));
            }
          }
        }
        _savedExisting = true;
      } catch (_) {}
    }
    // Contrôleurs pour les questions sans réponse pré-remplie.
    for (final q in questions) {
      if (q.type != QuestionType.date && q.type != QuestionType.liste) {
        _answers.putIfAbsent(q.label, () => TextEditingController());
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${row.request.reference} — ${row.client.nom}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              for (final q in questions) _fieldFor(q),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => _save(context, row),
                child: const Text('ENREGISTRER LA QUALIFICATION'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fieldFor(QualificationQuestion q) {
    final obligatoire = q.obligatoire ? ' *' : '';
    switch (q.type) {
      case QuestionType.multiligne:
        return MsnTextField(
          label: '${q.label}$obligatoire',
          controller: _answers[q.label]!,
          maxLines: 3,
        );
      case QuestionType.nombre:
        return MsnTextField(
          label: '${q.label}$obligatoire',
          controller: _answers[q.label]!,
          keyboardType: TextInputType.number,
        );
      case QuestionType.date:
        return MsnDateField(
          label: '${q.label}$obligatoire',
          value: _dates[q.label],
          onChanged: (v) => setState(() => _dates[q.label] = v),
        );
      case QuestionType.liste:
        final options = _options(q);
        // Robustesse : une question de liste sans options (config
        // incomplète) ne doit jamais être inutilisable — champ texte.
        if (options.isEmpty) {
          return MsnTextField(
            label: '${q.label}$obligatoire',
            controller: _answers.putIfAbsent(
                q.label, () => TextEditingController()),
            hint: 'Liste d\'options non configurée — saisissez la valeur',
          );
        }
        return MsnDropdown<String>(
          label: '${q.label}$obligatoire',
          value: _choices[q.label],
          items: options,
          itemLabel: (v) => v,
          onChanged: (v) => setState(() => _choices[q.label] = v ?? ''),
        );
      case QuestionType.texte:
        return MsnTextField(
          label: '${q.label}$obligatoire',
          controller: _answers[q.label]!,
        );
    }
  }

  List<String> _options(QualificationQuestion q) {
    if (q.optionsJson == null) return const [];
    try {
      final decoded = jsonDecode(q.optionsJson!) as List;
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _save(
      BuildContext context, RequestWithClientRow row) async {
    // Validation des champs obligatoires.
    final missing = <String>[];
    for (final q in _allQuestions()) {
      if (!q.obligatoire) continue;
      final value = _valueFor(q);
      if (value == null || value.isEmpty) missing.add(q.label);
    }
    if (missing.isNotEmpty && mounted) {
      showMsnSnack(
          context,
          'Champs obligatoires manquants : ${missing.join(', ')}',
          error: true);
      return;
    }

    final answers = <String, String?>{};
    for (final q in _allQuestions()) {
      answers[q.label] = _valueFor(q);
    }

    await ref.read(requestsDaoProvider).saveQualification(
          row.request.id,
          jsonEncode(answers),
        );
    await ref
        .read(requestsDaoProvider)
        .updateStatut(row.request.id, RequestStatut.qualifiee);
    await ref.read(syncEngineProvider).enqueue(
          entite: 'requests',
          entityId: row.request.id,
          operation: SyncOperation.update,
          payload: {'statut': 'qualifiee', 'qualificationComplete': true},
        );
    await ref.read(activityLoggerProvider).log(
          action: ActivityAction.modification,
          entite: 'demande',
          entityId: row.request.id,
          details:
              'Qualification terminée pour ${row.request.reference} '
              '(${answers.length} réponses).',
        );
    if (mounted) {
      showMsnSnack(context, 'Qualification enregistrée. Brief complet !');
      context.go('/requests/${row.request.id}');
    }
  }

  // Les questions sont récupérées depuis le provider courant.
  List<QualificationQuestion> _allQuestions() {
    final detail = ref.read(requestDetailProvider(widget.requestId)).value;
    final serviceId = detail?.request.serviceId;
    if (serviceId == null) return const [];
    final form =
        ref.read(serviceQualificationFormProvider(serviceId)).value;
    if (form == null) return const [];
    return ref.read(qualificationQuestionsProvider(form.id)).value ?? const [];
  }

  String? _valueFor(QualificationQuestion q) {
    switch (q.type) {
      case QuestionType.date:
        final d = _dates[q.label];
        return d?.toIso8601String();
      case QuestionType.liste:
        final c = _choices[q.label];
        return (c == null || c.isEmpty) ? null : c;
      default:
        return _answers[q.label]?.text.trim().isEmpty ?? true
            ? null
            : _answers[q.label]!.text.trim();
    }
  }

  @override
  void dispose() {
    for (final c in _answers.values) {
      c.dispose();
    }
    super.dispose();
  }
}
