/// Écran liste des clients — recherche rapide, création, réutilisation
/// pour une nouvelle commande (section 18 : un client existant doit être
/// réutilisable immédiatement).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/enums.dart';
import '../../core/theme/msn_theme.dart';
import '../../shared/widgets/empty_state.dart';
import 'clients_providers.dart';

class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(clientsProvider);
    final search = ref.watch(clientsSearchProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Clients')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/clients/new'),
        icon: const Icon(Icons.person_add),
        label: const Text('Nouveau'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) =>
                  ref.read(clientsSearchProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Rechercher un client…',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: search.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => ref
                            .read(clientsSearchProvider.notifier)
                            .state = '',
                      ),
              ),
            ),
          ),
          Expanded(
            child: clients.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                  child: Text('Erreur : $e',
                      style: const TextStyle(color: MsnColors.danger))),
              data: (list) => list.isEmpty
                  ? EmptyState(
                      icon: Icons.people_outline,
                      title: search.isEmpty
                          ? 'Aucun client pour le moment'
                          : 'Aucun résultat',
                      message: search.isEmpty
                          ? 'Créez votre premier client pour démarrer '
                              'votre CRM.'
                          : 'Essayez un autre nom.',
                      action: search.isEmpty
                          ? FilledButton.icon(
                              onPressed: () => context.push('/clients/new'),
                              icon: const Icon(Icons.person_add),
                              label: const Text('Créer un client'),
                            )
                          : null,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final client = list[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  MsnColors.primary.withOpacity(0.12),
                              child: Text(
                                client.nom.isNotEmpty
                                    ? client.nom[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                    color: MsnColors.primary,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                            title: Text(client.nom,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            subtitle: Text(
                              [
                                if (client.telephone != null)
                                  client.telephone!,
                                if (client.canalPrefere != null)
                                  client.canalPrefere!.label,
                              ].join(' · '),
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: const Icon(Icons.chevron_right,
                                size: 20, color: MsnColors.textSecondary),
                            onTap: () =>
                                context.push('/clients/${client.id}'),
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
}
