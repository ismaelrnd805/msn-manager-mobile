/// Liste des devis — filtres, recherche, accès rapide.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/enums.dart';
import '../../core/theme/msn_theme.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/empty_state.dart';
import 'quotes_providers.dart';

class QuotesScreen extends ConsumerWidget {
  const QuotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotes = ref.watch(quotesProvider);
    final filter = ref.watch(quotesFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Devis')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/quotes/new'),
        icon: const Icon(Icons.request_quote),
        label: const Text('Nouveau'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) =>
                  ref.read(quotesSearchProvider.notifier).state = v,
              decoration: const InputDecoration(
                hintText: 'Rechercher (réf. ou client)…',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
            ),
          ),
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _chip(ref, filter, null, 'Tous'),
                ...QuoteStatut.values
                    .map((s) => _chip(ref, filter, s.name, s.label)),
              ],
            ),
          ),
          Expanded(
            child: quotes.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                  child: Text('Erreur : $e',
                      style: const TextStyle(color: MsnColors.danger))),
              data: (list) => list.isEmpty
                  ? EmptyState(
                      icon: Icons.request_quote_outlined,
                      title: 'Aucun devis',
                      message:
                          'Créez un devis depuis une demande ou directement '
                          'pour un client.',
                      action: FilledButton.icon(
                        onPressed: () => context.push('/quotes/new'),
                        icon: const Icon(Icons.add),
                        label: const Text('Créer un devis'),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final q = list[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                                '${q.quote.reference} — ${Formatters.ar(q.quote.montantTotal)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14)),
                            subtitle: Text(
                                '${q.clientNom} · '
                                '${Formatters.date(q.quote.dateEmission)}',
                                style: const TextStyle(fontSize: 12)),
                            trailing: StatusChip.statut(
                                statut: q.quote.statut.name,
                                label: q.quote.statut.label),
                            onTap: () =>
                                context.push('/quotes/${q.quote.id}'),
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

  Widget _chip(WidgetRef ref, String? current, String? value, String label) {
    final selected = current == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => ref.read(quotesFilterProvider.notifier).state = value,
      ),
    );
  }
}
