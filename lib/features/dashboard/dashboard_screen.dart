/// Écran d'accueil — vue d'ensemble immédiate de l'activité MSN.
///
/// Priorité UX (section 28) : nouvelles demandes, réponses, transferts PC,
/// paiements, deadlines — accessibles en un tap depuis cet écran.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/enums.dart';
import '../../core/providers/services_providers.dart';
import '../../core/sync/sync_provider.dart';
import '../../core/theme/msn_theme.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/cards.dart';
import 'dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counters = ref.watch(dashboardCountersProvider);
    final sync = ref.watch(syncControllerProvider);
    final session = ref.watch(sessionProvider);
    final deadlines = ref.watch(todayDeadlinesProvider);
    final activity = ref.watch(dashboardActivityProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bonjour, ${session?.userName ?? '—'}',
                style: const TextStyle(fontSize: 17)),
            Text('MSN — Multi-Services Numériques',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.75))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => context.push('/sync'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.read(syncControllerProvider.notifier).runNow(),
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            // ── État de synchronisation ─────────────────────────────────
            Row(
              children: [
                SyncStatusChip(status: sync.status),
                const SizedBox(width: 8),
                if (sync.pendingCount > 0)
                  Text(
                    '${sync.pendingCount} changement(s) en file',
                    style: const TextStyle(
                        fontSize: 11.5, color: MsnColors.textSecondary),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/sync'),
                  child: const Text('Détails'),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // ── Actions rapides ─────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => context.push('/requests/new'),
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text('Nouvelle demande'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => context.go('/clients'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search, size: 18),
                      SizedBox(width: 4),
                      Text('Client'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Indicateurs ─────────────────────────────────────────────
            counters.when(
              loading: () => const Center(
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator())),
              error: (e, _) => Text('Erreur indicateurs : $e',
                  style: const TextStyle(color: MsnColors.danger)),
              data: (c) => GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.55,
                children: [
                  StatTile(
                    label: 'Nouvelles demandes',
                    value: c.nouvellesDemandes,
                    icon: Icons.inbox,
                    alert: c.nouvellesDemandes > 0,
                    onTap: () => context.go('/requests'),
                  ),
                  StatTile(
                    label: 'À répondre',
                    value: c.aRepondre,
                    icon: Icons.reply,
                    color: MsnColors.info,
                    onTap: () => context.go('/requests'),
                  ),
                  StatTile(
                    label: 'À transférer au PC',
                    value: c.aTransfererPc,
                    icon: Icons.computer,
                    color: MsnColors.accent,
                    alert: c.aTransfererPc > 0,
                    onTap: () => context.go('/orders'),
                  ),
                  StatTile(
                    label: 'En production',
                    value: c.enProduction,
                    icon: Icons.build,
                    color: MsnColors.primaryDark,
                    onTap: () => context.go('/orders'),
                  ),
                  StatTile(
                    label: 'En attente client',
                    value: c.enAttenteClient,
                    icon: Icons.hourglass_top,
                    color: MsnColors.warning,
                    onTap: () => context.go('/orders'),
                  ),
                  StatTile(
                    label: 'Paiements en attente',
                    value: c.paiementsAttente,
                    icon: Icons.payments_outlined,
                    color: MsnColors.success,
                    alert: c.paiementsAttente > 0,
                    onTap: () => context.push('/invoices'),
                  ),
                  StatTile(
                    label: "Deadlines aujourd'hui",
                    value: c.deadlinesAujourdHui,
                    icon: Icons.event,
                    color: MsnColors.danger,
                    alert: c.deadlinesAujourdHui > 0,
                    onTap: () => context.push('/tasks'),
                  ),
                  StatTile(
                    label: 'Catalogue & tarifs',
                    value: 0,
                    icon: Icons.storefront,
                    color: MsnColors.textSecondary,
                    onTap: () => context.push('/catalog'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Deadlines proches ───────────────────────────────────────
            SectionCard(
              title: 'Deadlines à venir',
              action: TextButton(
                onPressed: () => context.push('/tasks'),
                child: const Text('Tout voir'),
              ),
              child: deadlines.when(
                loading: () => const SizedBox(
                    height: 40,
                    child: Center(child: CircularProgressIndicator())),
                error: (e, _) => Text('$e',
                    style: const TextStyle(color: MsnColors.danger)),
                data: (list) => list.isEmpty
                    ? const Text('Aucune deadline proche. Continuez !',
                        style: TextStyle(
                            fontSize: 12.5, color: MsnColors.textSecondary))
                    : Column(
                        children: list
                            .map((d) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  leading: const Icon(Icons.flag,
                                      size: 18, color: MsnColors.danger),
                                  title: Text('${d.reference} — ${d.titre}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13)),
                                  subtitle: Text(d.clientNom,
                                      style:
                                          const TextStyle(fontSize: 11.5)),
                                  trailing: Text(
                                      Formatters.dateShort(d.deadline),
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Formatters.daysUntil(
                                                      d.deadline) <=
                                                  0
                                              ? MsnColors.danger
                                              : MsnColors.warning)),
                                  onTap: () =>
                                      context.push('/orders/${d.orderId}'),
                                ))
                            .toList(),
                      ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Journal récent ──────────────────────────────────────────
            SectionCard(
              title: 'Activité récente',
              child: activity.when(
                loading: () => const SizedBox(
                    height: 40,
                    child: Center(child: CircularProgressIndicator())),
                error: (e, _) => Text('$e',
                    style: const TextStyle(color: MsnColors.danger)),
                data: (list) => list.isEmpty
                    ? const Text('Aucune activité enregistrée.',
                        style: TextStyle(
                            fontSize: 12.5, color: MsnColors.textSecondary))
                    : Column(
                        children: list
                            .map((a) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  leading: Icon(_iconFor(a.action),
                                      size: 16, color: MsnColors.primary),
                                  title: Text(a.details,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12.5)),
                                  subtitle: Text(
                                      '${a.userName} — '
                                      '${Formatters.dateTime(a.timestamp)}',
                                      style: const TextStyle(fontSize: 10.5)),
                                ))
                            .toList(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(ActivityAction action) {
    switch (action) {
      case ActivityAction.creation:
        return Icons.add_circle_outline;
      case ActivityAction.modification:
        return Icons.edit;
      case ActivityAction.suppression:
        return Icons.delete_outline;
      case ActivityAction.paiement:
        return Icons.payments;
      case ActivityAction.validation:
        return Icons.check_circle_outline;
      case ActivityAction.changementStatut:
        return Icons.swap_horiz;
      case ActivityAction.changementTarif:
        return Icons.sell;
      case ActivityAction.modificationWorkflow:
        return Icons.account_tree;
      case ActivityAction.exceptionRegles:
        return Icons.warning_amber;
      case ActivityAction.transfertPc:
        return Icons.computer;
      case ActivityAction.synchronisation:
        return Icons.sync;
      case ActivityAction.connexion:
        return Icons.login;
    }
  }
}
