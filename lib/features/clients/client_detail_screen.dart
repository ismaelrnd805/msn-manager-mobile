/// Fiche client complète : coordonnées, historique complet (demandes,
/// devis, commandes, factures, paiements) et actions rapides.
library;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/session.dart';
import '../../core/domain/enums.dart';
import '../../core/providers/services_providers.dart';
import '../../core/sync/sync_engine.dart';
import '../../core/theme/msn_theme.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/feedback.dart';
import 'clients_providers.dart';

class ClientDetailScreen extends ConsumerWidget {
  const ClientDetailScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(clientOrdersProvider(clientId));
    final quotes = ref.watch(clientQuotesProvider(clientId));
    final invoices = ref.watch(clientInvoicesProvider(clientId));
    final requests = ref.watch(clientRequestsProvider(clientId));
    final clientsAsync = ref.watch(clientsProvider);
    final session = ref.watch(sessionProvider);

    final client = clientsAsync.value
        ?.where((c) => c.id == clientId)
        .firstOrNull;

    if (client == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(client.nom),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/clients/$clientId/edit'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // ── Coordonnées ───────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row('Téléphone', client.telephone ?? '—'),
                  _row('Email', client.email ?? '—'),
                  _row('Canal préféré', client.canalPrefere?.label ?? '—'),
                  _row('Adresse', client.adresse ?? '—'),
                  if (client.notes != null && client.notes!.isNotEmpty)
                    _row('Notes', client.notes!),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push(
                              '/requests/new?clientId=${client.id}'),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Demande',
                              style: TextStyle(fontSize: 12.5)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push(
                              '/quotes/new?clientId=${client.id}'),
                          icon: const Icon(Icons.request_quote, size: 16),
                          label: const Text('Devis',
                              style: TextStyle(fontSize: 12.5)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Historique ────────────────────────────────────────────────
          _section(
              'Demandes (${requests.value?.length ?? 0})',
              requests.value
                  ?.map((r) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.inbox, size: 18),
                        title: Text('${r.reference} — ${r.statut.label}',
                            style: const TextStyle(fontSize: 13)),
                        onTap: () => context.push('/requests/${r.id}'),
                      ))
                  .toList()),
          _section(
              'Commandes (${orders.value?.length ?? 0})',
              orders.value
                  ?.map((o) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.work, size: 18),
                        title: Text('${o.reference} — ${o.titre}',
                            style: const TextStyle(fontSize: 13)),
                        subtitle: Text(o.statut.label,
                            style: const TextStyle(fontSize: 11.5)),
                        onTap: () => context.push('/orders/${o.id}'),
                      ))
                  .toList()),
          _section(
              'Devis (${quotes.value?.length ?? 0})',
              quotes.value
                  ?.map((q) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.request_quote, size: 18),
                        title: Text(
                            '${q.reference} — ${Formatters.ar(q.montantTotal)}',
                            style: const TextStyle(fontSize: 13)),
                        subtitle: Text(q.statut.label,
                            style: const TextStyle(fontSize: 11.5)),
                        onTap: () => context.push('/quotes/${q.id}'),
                      ))
                  .toList()),
          _section(
              'Factures (${invoices.value?.length ?? 0})',
              invoices.value
                  ?.map((i) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.receipt_long, size: 18),
                        title: Text(
                            '${i.reference} — ${Formatters.ar(i.montantTotal)}',
                            style: const TextStyle(fontSize: 13)),
                        subtitle: Text(i.statut.label,
                            style: const TextStyle(fontSize: 11.5)),
                        onTap: () => context.push('/invoices/${i.id}'),
                      ))
                  .toList()),
          const SizedBox(height: 20),
          // Suppression douce (corbeille), admin uniquement.
          if (session?.isAdmin ?? false)
            Center(
              child: TextButton.icon(
                style: TextButton.styleFrom(
                    foregroundColor: MsnColors.danger),
                onPressed: () async {
                  final ok = await confirmAction(
                    context,
                    title: 'Mettre à la corbeille ?',
                    message: 'Le client « ${client.nom} » sera déplacé '
                        'vers la corbeille. Vous pourrez le restaurer.',
                    confirmLabel: 'Mettre à la corbeille',
                    danger: true,
                  );
                  if (!ok || !context.mounted) return;
                  await ref.read(clientsDaoProvider).softDelete(client.id);
                  await ref.read(syncEngineProvider).enqueue(
                        entite: 'clients',
                        entityId: client.id,
                        operation: SyncOperation.update,
                        payload: {'deletedAt': DateTime.now().toIso8601String()},
                      );
                  await ref.read(activityLoggerProvider).log(
                        action: ActivityAction.suppression,
                        entite: 'client',
                        entityId: client.id,
                        details:
                            'Client « ${client.nom} » mis à la corbeille.',
                      );
                  if (context.mounted) context.go('/clients');
                },
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Mettre à la corbeille'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 110,
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 12.5, color: MsnColors.textSecondary))),
            Expanded(
                child: Text(value,
                    style: const TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w600))),
          ],
        ),
      );

  Widget _section(String title, List<Widget>? children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(),
            style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: MsnColors.textSecondary,
                letterSpacing: 0.8)),
        const SizedBox(height: 4),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: children == null || children.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Aucun élément.',
                        style: TextStyle(
                            fontSize: 12, color: MsnColors.textSecondary)))
                : Column(children: children),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
