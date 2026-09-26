/// Catalogue dynamique — présentation des services et tarifs
/// (section 14). Chaque service est présentable sous 3 formats.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/daos/catalog_dao.dart';
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
                // Regroupement par branche numérotée (1 à 6) en conservant
                // l'ordre des catégories défini dans la base.
                final cats = categories.value ?? const [];
                final widgets = <Widget>[];
                var branche = 0;
                for (final cat in cats) {
                  branche++;
                  final items = list
                      .where((e) => e.categoryNom == cat.nom)
                      .toList()
                    ..sort((a, b) => a.service.nom.compareTo(b.service.nom));
                  if (items.isEmpty) continue;
                  widgets.add(_BrancheHeader(
                      numero: branche, nom: cat.nom.toUpperCase()));
                  for (final item in items) {
                    widgets.add(_ServiceCard(item: item));
                    widgets.add(const SizedBox(height: 8));
                  }
                }
                // Services sans catégorie connue (sécurité).
                final orphans = list
                    .where((e) => !cats.any((c) => c.nom == e.categoryNom))
                    .toList();
                if (orphans.isNotEmpty) {
                  widgets.add(const _BrancheHeader(numero: null, nom: 'AUTRES'));
                  for (final item in orphans) {
                    widgets.add(_ServiceCard(item: item));
                    widgets.add(const SizedBox(height: 8));
                  }
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                  children: widgets,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// En-tête de section : pastille numérotée + nom de branche.
class _BrancheHeader extends StatelessWidget {
  const _BrancheHeader({required this.nom, this.numero});

  final String nom;
  final int? numero;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [MsnColors.primary, MsnColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              numero?.toString() ?? '•',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            numero != null ? 'BRANCHE $numero · $nom' : nom,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
              letterSpacing: 0.6,
              color: MsnColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte service — tarification lisible d'un coup d'œil.
class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.item});

  final ServiceWithCategory item;

  @override
  Widget build(BuildContext context) {
    final s = item.service;
    return Card(
      child: ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(s.nom,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14)),
            ),
            if (!s.actif)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: MsnColors.textSecondary.withValues(alpha: 0.15),
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
          _tarifLigne(s.prixBase, s.unite, s.delaiJours),
          style: const TextStyle(
              fontSize: 12.5, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.chevron_right,
            size: 20, color: MsnColors.textSecondary),
        onTap: () => context.push('/catalog/${s.id}'),
      ),
    );
  }

  static String _tarifLigne(int? prix, String unite, int? delaiJours) {
    final tarif = Formatters.tarif(prix, unite);
    final delai =
        (delaiJours != null && delaiJours > 0) ? ' · $delaiJours j' : '';
    return '$tarif$delai';
  }
}
