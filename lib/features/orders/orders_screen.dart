/// Liste des commandes — progression, badges « prêt PC », deadlines.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/enums.dart';
import '../../core/theme/msn_theme.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/empty_state.dart';
import 'orders_providers.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final filter = ref.watch(ordersFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Commandes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) =>
                  ref.read(ordersSearchProvider.notifier).state = v,
              decoration: const InputDecoration(
                hintText: 'Rechercher (réf., client, titre)…',
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
                ...OrderStatut.values
                    .map((s) => _chip(ref, filter, s.name, s.label)),
              ],
            ),
          ),
          Expanded(
            child: orders.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                  child: Text('Erreur : $e',
                      style: const TextStyle(color: MsnColors.danger))),
              data: (list) => list.isEmpty
                  ? EmptyState(
                      icon: Icons.work_outline,
                      title: 'Aucune commande',
                      message:
                          'Les commandes naissent d’un devis accepté '
                          '(Demande → Devis → Commande).',
                      action: OutlinedButton.icon(
                        onPressed: () => context.go('/quotes'),
                        icon: const Icon(Icons.request_quote_outlined),
                        label: const Text('Voir les devis'),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final o = list[index];
                        final order = o.order;
                        final deadlineInfo = order.deadline == null
                            ? null
                            : Formatters.relative(order.deadline!);
                        final enRetard =
                            Formatters.daysUntil(order.deadline) < 0 &&
                                order.deadline != null &&
                                order.statut != OrderStatut.terminee &&
                                order.statut != OrderStatut.livree;
                        return Card(
                          child: ListTile(
                            title: Text(
                                '${order.reference} — ${order.titre}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14)),
                            subtitle: Text(
                                '${o.clientNom} · '
                                '${Formatters.ar(order.montantTotal)}'
                                '${deadlineInfo != null ? ' · $deadlineInfo' : ''}',
                                style: const TextStyle(fontSize: 12)),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                StatusChip.statut(
                                    statut: order.statut.name,
                                    label: order.statut.label),
                                if (order.pretPourProduction &&
                                    !order.transferePc) ...[
                                  const SizedBox(height: 4),
                                  const Text('PRÊT PC',
                                      style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: MsnColors.accent)),
                                ],
                                if (enRetard) ...[
                                  const SizedBox(height: 4),
                                  const Text('EN RETARD',
                                      style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: MsnColors.danger)),
                                ],
                              ],
                            ),
                            onTap: () => context.push('/orders/${order.id}'),
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
            ref.read(ordersFilterProvider.notifier).state = value,
      ),
    );
  }
}
