/// Bibliothèque de modèles de messages — catégories métier (section 12).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/enums.dart';
import '../../core/theme/msn_theme.dart';
import '../../shared/widgets/empty_state.dart';
import 'communication_providers.dart';
import 'translation_sheet.dart';

class TemplatesScreen extends ConsumerStatefulWidget {
  const TemplatesScreen({super.key});

  @override
  ConsumerState<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends ConsumerState<TemplatesScreen> {
  TemplateCategorie? _categorie;

  @override
  Widget build(BuildContext context) {
    final templates =
        ref.watch(messageTemplatesByCategoryProvider(_categorie));

    return Scaffold(
      appBar: AppBar(title: const Text('Modèles de messages')),
      body: Column(
        children: [
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _chip(null, 'Tous'),
                ...TemplateCategorie.values.map((c) => _chip(c, c.label)),
              ],
            ),
          ),
          Expanded(
            child: templates.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (list) => list.isEmpty
                  ? const EmptyState(
                      icon: Icons.forum_outlined,
                      title: 'Aucun modèle',
                      message:
                          'L’administrateur peut créer des modèles dans '
                          'Administration > Modèles de messages.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final t = list[index];
                        return Card(
                          child: ListTile(
                            title: Text(t.titre,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5)),
                            subtitle: Text(
                              t.corps,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11.5),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (t.corpsMg?.trim().isNotEmpty ?? false)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 6),
                                    child: Icon(Icons.verified_outlined,
                                        size: 16, color: MsnColors.success),
                                  ),
                                const Icon(Icons.chevron_right,
                                    size: 18,
                                    color: MsnColors.textSecondary),
                              ],
                            ),
                            onTap: () => context.push(
                              '/communication/composer',
                              extra: ComposerArgs(templateCode: t.code),
                            ),
                            onLongPress: () => showTranslationSheet(
                                context, ref, t),
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

  Widget _chip(TemplateCategorie? value, String label) {
    final selected = _categorie == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _categorie = value),
      ),
    );
  }
}
