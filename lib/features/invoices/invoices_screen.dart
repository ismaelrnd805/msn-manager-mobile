/// Liste des factures — filtres par statut, recherche.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/enums.dart';
import '../../core/theme/msn_theme.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/empty_state.dart';
import 'invoices_providers.dart';

class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(invoicesProvider);
    final filter = ref.watch(invoicesFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Factures')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) =>
                  ref.read(invoicesSearchProvider.notifier).state = v,
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
                _chip(ref, filter, null, 'Toutes'),
                ...InvoiceStatut.values
                    .map((s) => _chip(ref, filter, s.name, s.label)),
              ],
            ),
          ),
          Expanded(
            child: invoices.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                  child: Text('Erreur : $e',
                      style: const TextStyle(color: MsnColors.danger))),
              data: (list) => list.isEmpty
                  ? EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'Aucune facture',
                      message:
                          'Les factures sont créées depuis une commande '
                          '(section Paiements et Factures).',
                      action: OutlinedButton.icon(
                        onPressed: () => context.go('/orders'),
                        icon: const Icon(Icons.work_outlined),
                        label: const Text('Voir les commandes'),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final i = list[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                                '${i.invoice.reference} — '
                                '${Formatters.ar(i.invoice.montantTotal)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14)),
                            subtitle: Text(
                                '${i.clientNom} · '
                                '${Formatters.date(i.invoice.dateEmission)}',
                                style: const TextStyle(fontSize: 12)),
                            trailing: StatusChip.statut(
                                statut: i.invoice.statut.name,
                                label: i.invoice.statut.label),
                            onTap: () =>
                                context.push('/invoices/${i.invoice.id}'),
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
        onSelected: (_) =>
            ref.read(invoicesFilterProvider.notifier).state = value,
      ),
    );
  }
}
