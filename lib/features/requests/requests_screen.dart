/// Liste des demandes — avec filtres de statut et recherche.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/enums.dart';
import '../../core/theme/msn_theme.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/empty_state.dart';
import 'requests_providers.dart';

class RequestsScreen extends ConsumerWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(requestsProvider);
    final filter = ref.watch(requestsFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Demandes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/requests/new'),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              onChanged: (v) =>
                  ref.read(requestsSearchProvider.notifier).state = v,
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
                _filterChip(ref, filter, null, 'Toutes'),
                ...RequestStatut.values.map(
                  (s) => _filterChip(ref, filter, s.name, s.label),
                ),
              ],
            ),
          ),
          Expanded(
            child: requests.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                  child: Text('Erreur : $e',
                      style: const TextStyle(color: MsnColors.danger))),
              data: (list) => list.isEmpty
                  ? EmptyState(
                      icon: Icons.inbox_outlined,
                      title: 'Aucune demande',
                      message:
                          'Enregistrez ici chaque demande reçue sur Messenger, '
                          'WhatsApp ou par téléphone.',
                      action: FilledButton.icon(
                        onPressed: () => context.push('/requests/new'),
                        icon: const Icon(Icons.add),
                        label: const Text('Enregistrer une demande'),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {},
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final r = list[index];
                          return Card(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () =>
                                  context.push('/requests/${r.request.id}'),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(r.request.reference,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 13,
                                                color:
                                                    MsnColors.primaryDark)),
                                        const Spacer(),
                                        StatusChip.statut(
                                            statut: r.request.statut.name,
                                            label: r.request.statut.label),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${r.clientNom}'
                                      '${r.request.serviceId != null ? ' · service demandé' : ''}',
                                      style: const TextStyle(fontSize: 13.5),
                                    ),
                                    if (r.request.description != null &&
                                        r.request.description!.isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 2),
                                        child: Text(
                                          r.request.description!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color:
                                                  MsnColors.textSecondary),
                                        ),
                                      ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        PriorityBadge(
                                            priorite: r.request.priorite),
                                        const Spacer(),
                                        Text(
                                          Formatters.relative(
                                              r.request.createdAt),
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: MsnColors
                                                  .textSecondary),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
      WidgetRef ref, String? current, String? value, String label) {
    final selected = current == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) =>
            ref.read(requestsFilterProvider.notifier).state = value,
      ),
    );
  }
}
