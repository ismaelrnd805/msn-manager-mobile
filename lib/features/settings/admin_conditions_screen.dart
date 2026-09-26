/// Administration — bibliothèque de conditions contractuelles (CRUD).
///
/// Les conditions cochées dans les devis/factures proviennent toutes de
/// cette bibliothèque : plus aucun texte contractuel codé en dur.
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

class AdminConditionsScreen extends ConsumerWidget {
  const AdminConditionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conditions = ref.watch(_conditionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Conditions contractuelles')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle condition'),
      ),
      body: conditions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Erreur : $e',
                style: const TextStyle(color: MsnColors.danger))),
        data: (list) => list.isEmpty
            ? const EmptyState(
                icon: Icons.rule,
                title: 'Aucune condition',
                message:
                    'Ajoutez les conditions contractuelles (acompte, validité, '
                    'retouches…) qui seront cochées dans les devis et factures.',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final c = list[i];
                  return Card(
                    child: ListTile(
                      title: Text(c.titre,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(c.contenu,
                            style: const TextStyle(fontSize: 12.5)),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _CategorieChip(categorie: c.categorie),
                          if (!c.actif) const Icon(Icons.visibility_off,
                              size: 16, color: MsnColors.textSecondary),
                          PopupMenuButton<String>(
                            onSelected: (v) async {
                              if (v == 'edit') {
                                await _edit(context, ref, c);
                              } else if (v == 'toggle') {
                                await ref.read(templatesDaoProvider).upsertCondition(
                                    Condition(
                                        id: c.id,
                                        titre: c.titre,
                                        contenu: c.contenu,
                                        categorie: c.categorie,
                                        actif: !c.actif,
                                        ordre: c.ordre,
                                        createdAt: c.createdAt,
                                        updatedAt: DateTime.now()));
                              } else if (v == 'delete') {
                                await _delete(context, ref, c);
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                  value: 'edit', child: Text('Modifier')),
                              PopupMenuItem(
                                  value: 'toggle',
                                  child: Text(c.actif
                                      ? 'Désactiver'
                                      : 'Réactiver')),
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
      BuildContext context, WidgetRef ref, Condition? existing) async {
    final titre = TextEditingController(text: existing?.titre);
    final contenu = TextEditingController(text: existing?.contenu);
    var categorie = existing?.categorie ?? 'devis';
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
              Text(existing == null ? 'Nouvelle condition' : 'Modifier',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 14),
              MsnTextField(label: 'Titre *', controller: titre, autofocus: true),
              MsnTextField(
                  label: 'Texte de la condition *',
                  controller: contenu,
                  maxLines: 4),
              MsnDropdown<String>(
                label: 'Catégorie',
                value: categorie,
                items: const ['devis', 'facture'],
                itemLabel: (v) => v == 'devis' ? 'Devis' : 'Facture',
                onChanged: (v) =>
                    setSheetState(() => categorie = v ?? 'devis'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active',
                    style: TextStyle(fontSize: 14)),
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
    if (titre.text.trim().isEmpty || contenu.text.trim().isEmpty) {
      showMsnSnack(context, 'Titre et texte obligatoires.', error: true);
      return;
    }

    final now = DateTime.now();
    final all = await ref.read(templatesDaoProvider).allActiveConditions();
    await ref.read(templatesDaoProvider).upsertCondition(Condition(
          id: existing?.id ?? 'cond_${now.microsecondsSinceEpoch}',
          titre: titre.text.trim(),
          contenu: contenu.text.trim(),
          categorie: categorie,
          actif: actif,
          ordre: existing?.ordre ?? all.length,
          createdAt: existing?.createdAt ?? now,
          updatedAt: now,
        ));
    await ref.read(activityLoggerProvider).log(
          action: existing == null
              ? ActivityAction.creation
              : ActivityAction.modification,
          entite: 'condition',
          entityId: existing?.id,
          details: existing == null
              ? 'Condition « ${titre.text.trim()} » créée.'
              : 'Condition « ${titre.text.trim()} » modifiée.',
        );
    if (context.mounted) showMsnSnack(context, 'Condition enregistrée.');
  }

  Future<void> _delete(
      BuildContext context, WidgetRef ref, Condition c) async {
    final ok = await confirmAction(context,
        title: 'Supprimer la condition ?',
        message:
            '« ${c.titre} » sera retirée de la bibliothèque. Les documents '
            'existants qui la citent ne sont pas modifiés.',
        danger: true);
    if (!ok) return;
    await ref.read(templatesDaoProvider).softDeleteCondition(c.id);
    await ref.read(activityLoggerProvider).log(
          action: ActivityAction.suppression,
          entite: 'condition',
          entityId: c.id,
          details: 'Condition « ${c.titre} » supprimée.',
        );
    if (context.mounted) showMsnSnack(context, 'Condition supprimée.');
  }
}

class _CategorieChip extends StatelessWidget {
  const _CategorieChip({required this.categorie});

  final String categorie;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: MsnColors.accentSoft,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(categorie == 'devis' ? 'Devis' : 'Facture',
          style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF08424D))),
    );
  }
}

final _conditionsProvider = StreamProvider<List<Condition>>((ref) {
  return ref.watch(templatesDaoProvider).watchAllConditions();
});
