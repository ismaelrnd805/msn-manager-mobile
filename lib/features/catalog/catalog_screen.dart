/// Catalogue dynamique — présentation des services et tarifs
/// (section 14). Chaque service est présentable sous 3 formats.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/services_providers.dart';
import '../../core/theme/msn_theme.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/empty_state.dart';
import 'catalog_providers.dart';

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(catalogServicesProvider);
    final categories = ref.watch(catalogCategoriesProvider);
    final search = ref.watch(catalogSearchProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Catalogue & tarifs')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/catalog/new'),
        icon: const Icon(Icons.add_business),
        label: const Text('Service'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) =>
                  ref.read(catalogSearchProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Rechercher un service…',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: search.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => ref
                            .read(catalogSearchProvider.notifier)
                            .state = '',
                      ),
              ),
            ),
          ),
          Expanded(
            child: services.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                  child: Text('Erreur : $e',
                      style: const TextStyle(color: MsnColors.danger))),
              data: (list) {
                if (list.isEmpty) {
                  return EmptyState(
                    icon: Icons.storefront_outlined,
                    title: 'Catalogue vide',
                    message:
                        'Ajoutez vos services avec leurs tarifs : ils seront '
                        'utilisés par les devis, les messages et les PDF.',
                    action: FilledButton.icon(
                      onPressed: () => context.push('/catalog/new'),
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter un service'),
                    ),
                  );
                }
                // Regroupement par catégorie en conservant l'ordre des
                // catégories défini dans la base.
                final catOrder = <String, int>{
                  for (var i = 0;
                      i < (categories.value ?? []).length;
                      i++)
                    (categories.value!)[i].nom: i,
                };
                final sorted = [...list]..sort((a, b) {
                    final ca = catOrder[a.categoryNom] ?? 999;
                    final cb = catOrder[b.categoryNom] ?? 999;
                    if (ca != cb) return ca.compareTo(cb);
                    return a.service.nom.compareTo(b.service.nom);
                  });
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                  itemCount: sorted.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = sorted[index];
                    final s = item.service;
                    return Card(
                      child: ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(s.nom,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14)),
                            ),
                            if (!s.actif)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: MsnColors.textSecondary
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('INACTIF',
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: MsnColors.textSecondary)),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          '${item.categoryNom} · '
                          '${Formatters.ar(s.prixBase)} / ${s.unite}'
                          '${s.delaiJours != null ? ' · ${s.delaiJours} j' : ''}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(Icons.chevron_right,
                            size: 20, color: MsnColors.textSecondary),
                        onTap: () => context.push('/catalog/${s.id}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
