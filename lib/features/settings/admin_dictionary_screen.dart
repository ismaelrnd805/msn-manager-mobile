/// Administration — dictionnaire français → malagasy (CRUD).
///
/// Source unique des traductions : les documents et messages traduits
/// consultent ce dictionnaire. Les termes se complètent progressivement ;
/// aucune traduction n'est codée dans l'application.
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

final _dictionarySearchProvider = StateProvider<String>((_) => '');

final _dictionaryProvider =
    StreamProvider<List<DictionaryEntry>>((ref) {
  final recherche = ref.watch(_dictionarySearchProvider);
  return ref.watch(templatesDaoProvider).watchDictionary(recherche: recherche);
});

class AdminDictionaryScreen extends ConsumerWidget {
  const AdminDictionaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(_dictionaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dictionnaire FR → MG')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau terme'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              onChanged: (v) =>
                  ref.read(_dictionarySearchProvider.notifier).state = v,
              decoration: const InputDecoration(
                hintText: 'Rechercher un terme français ou malagasy…',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
            ),
          ),
          Expanded(
            child: entries.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                  child: Text('Erreur : $e',
                      style: const TextStyle(color: MsnColors.danger))),
              data: (list) => list.isEmpty
                  ? const EmptyState(
                      icon: Icons.translate,
                      title: 'Aucun terme',
                      message:
                          'Ajoutez les traductions français → malagasy qui '
                          'serviront aux documents et aux messages.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, i) {
                        final d = list[i];
                        return Card(
                          child: ListTile(
                            dense: true,
                            title: Text(d.termeFr,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5)),
                            subtitle: Text(d.traductionMg,
                                style: const TextStyle(
                                    fontSize: 13, color: MsnColors.primary)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (d.categorie != null &&
                                    d.categorie!.isNotEmpty)
                                  Text(d.categorie!,
                                      style: TextStyle(
                                          fontSize: 10.5,
                                          color: MsnColors
                                              .textSecondary
                                              .withValues(alpha: 0.8))),
                                PopupMenuButton<String>(
                                  onSelected: (v) async {
                                    if (v == 'edit') {
                                      await _edit(context, ref, d);
                                    } else if (v == 'toggle') {
                                      await ref
                                          .read(templatesDaoProvider)
                                          .upsertDictionaryEntry(
                                              DictionaryEntry(
                                                  id: d.id,
                                                  termeFr: d.termeFr,
                                                  traductionMg: d.traductionMg,
                                                  categorie: d.categorie,
                                                  contexte: d.contexte,
                                                  actif: !d.actif,
                                                  createdAt: d.createdAt,
                                                  updatedAt:
                                                      DateTime.now()));
                                    } else if (v == 'delete') {
                                      await _delete(context, ref, d);
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Modifier')),
                                    PopupMenuItem(
                                        value: 'toggle',
                                        child: Text(d.actif
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
          ),
        ],
      ),
    );
  }

  Future<void> _edit(
      BuildContext context, WidgetRef ref, DictionaryEntry? existing) async {
    final fr = TextEditingController(text: existing?.termeFr);
    final mg = TextEditingController(text: existing?.traductionMg);
    final categorie = TextEditingController(text: existing?.categorie);
    final contexte = TextEditingController(text: existing?.contexte);

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
            18, 18, 18, 18 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(existing == null ? 'Nouveau terme' : 'Modifier le terme',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 14),
            MsnTextField(
                label: 'Terme français *',
                controller: fr,
                autofocus: existing == null),
            MsnTextField(label: 'Traduction malagasy *', controller: mg),
            MsnTextField(
                label: 'Catégorie (optionnel)',
                controller: categorie,
                hint: 'commercial, technique, suivi…'),
            MsnTextField(
                label: 'Contexte (optionnel)',
                controller: contexte,
                maxLines: 2),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('ENREGISTRER'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    if (fr.text.trim().isEmpty || mg.text.trim().isEmpty) {
      showMsnSnack(context,
          'Le terme français et la traduction sont obligatoires.',
          error: true);
      return;
    }
    final now = DateTime.now();
    await ref.read(templatesDaoProvider).upsertDictionaryEntry(DictionaryEntry(
          id: existing?.id ?? 'dict_${now.microsecondsSinceEpoch}',
          termeFr: fr.text.trim(),
          traductionMg: mg.text.trim(),
          categorie: categorie.text.trim().isEmpty
              ? null
              : categorie.text.trim(),
          contexte:
              contexte.text.trim().isEmpty ? null : contexte.text.trim(),
          actif: existing?.actif ?? true,
          createdAt: existing?.createdAt ?? now,
          updatedAt: now,
        ));
    await ref.read(activityLoggerProvider).log(
          action: existing == null
              ? ActivityAction.creation
              : ActivityAction.modification,
          entite: 'dictionnaire',
          entityId: existing?.id,
          details: existing == null
              ? 'Terme « ${fr.text.trim()} → ${mg.text.trim()} » ajouté.'
              : 'Terme « ${fr.text.trim()} » modifié.',
        );
    if (context.mounted) showMsnSnack(context, 'Terme enregistré.');
  }

  Future<void> _delete(
      BuildContext context, WidgetRef ref, DictionaryEntry d) async {
    final ok = await confirmAction(context,
        title: 'Supprimer le terme ?',
        message: '« ${d.termeFr} → ${d.traductionMg} » sera définitivement '
            'retiré du dictionnaire.',
        danger: true);
    if (!ok) return;
    await ref
        .read(templatesDaoProvider)
        .deleteDictionaryEntry(d.id);
    await ref.read(activityLoggerProvider).log(
          action: ActivityAction.suppression,
          entite: 'dictionnaire',
          entityId: d.id,
          details: 'Terme « ${d.termeFr} » supprimé du dictionnaire.',
        );
    if (context.mounted) showMsnSnack(context, 'Terme supprimé.');
  }
}
