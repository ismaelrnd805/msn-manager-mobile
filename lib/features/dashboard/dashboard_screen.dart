/// Écran d'accueil — vue d'ensemble immédiate de l'activité MSN.
///
/// v4 — hiérarchie visuelle repensée :
///   1. alertes prioritaires (grosses pastilles rouges/cyan) ;
///   2. statistiques essentielles (chiffres très lisibles) ;
///   3. demandes récentes ;
///   4. deadlines proches ;
///   5. activité récente.
/// La barre de recherche est grande et fixe ; la barre supérieure ne
/// disparaît jamais ; les actions rapides restent accessibles via le
/// bouton flottant permanent du shell.
library;

import 'package:drift/drift.dart'
    show OrderingTerm, OrderingMode, innerJoin;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/enums.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../core/sync/sync_provider.dart';
import '../../core/theme/msn_theme.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/cards.dart';
import '../requests/requests_providers.dart';
import 'dashboard_providers.dart';
import 'global_search_sheet.dart';

/// Demandes récentes (avec client), indépendantes des filtres de la
/// liste : le dashboard montre toujours les 3 dernières.
final recentRequestsWithClientProvider =
    StreamProvider<List<RequestWithClientRow>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final query = db.select(db.requests).join([
    innerJoin(db.clients, db.clients.id.equalsExp(db.requests.clientId)),
  ])
    ..where(db.requests.deletedAt.isNull())
    ..orderBy([OrderingTerm(
        expression: db.requests.createdAt, mode: OrderingMode.desc)])
    ..limit(3);
  return query.watch().map((rows) => rows
      .map((row) => RequestWithClientRow(
          row.readTable(db.requests), row.readTable(db.clients)))
      .toList());
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counters = ref.watch(dashboardCountersProvider);
    final session = ref.watch(sessionProvider);
    final deadlines = ref.watch(todayDeadlinesProvider);
    final activity = ref.watch(dashboardActivityProvider);
    final recents = ref.watch(recentRequestsWithClientProvider);

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
            tooltip: 'Synchronisation',
            onPressed: () => context.push('/sync'),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Barre de recherche grande et FIXE ──────────────────────────
          Container(
            color: MsnColors.primary,
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => GlobalSearchSheet.show(context),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, size: 22, color: MsnColors.textSecondary),
                    SizedBox(width: 10),
                    Text('Rechercher (demande, client, service)…',
                        style: TextStyle(
                            fontSize: 14.5,
                            color: MsnColors.textSecondary)),
                  ],
                ),
              ),
            ),
          ),

          // ── Contenu défilable ─────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async =>
                  ref.read(syncControllerProvider.notifier).runNow(),
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  // ── 1. Alertes prioritaires ─────────────────────────────
                  counters.when(
                    loading: () => const Center(
                        child: Padding(
                            padding: EdgeInsets.all(16),
                            child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2)))),
                    error: (e, _) => Text('Erreur indicateurs : $e',
                        style: const TextStyle(color: MsnColors.danger)),
                    data: (c) {
                      final alerts = <_Alert>[
                        if (c.nouvellesDemandes > 0)
                          _Alert(
                              value: c.nouvellesDemandes,
                              label: 'Nouvelles\ndemandes',
                              color: MsnColors.danger,
                              onTap: () => context.go('/requests')),
                        if (c.aTransfererPc > 0)
                          _Alert(
                              value: c.aTransfererPc,
                              label: 'À transférer\nau PC',
                              color: MsnColors.accent,
                              onTap: () => context.go('/orders')),
                        if (c.deadlinesAujourdHui > 0)
                          _Alert(
                              value: c.deadlinesAujourdHui,
                              label: "Deadlines\naujourd'hui",
                              color: MsnColors.warning,
                              onTap: () => context.push('/tasks')),
                        if (c.paiementsAttente > 0)
                          _Alert(
                              value: c.paiementsAttente,
                              label: 'Paiements\nen attente',
                              color: MsnColors.success,
                              onTap: () => context.push('/invoices')),
                      ];
                      if (alerts.isEmpty) {
                        return Row(
                          children: [
                            const Icon(Icons.verified_outlined,
                                size: 16, color: MsnColors.success),
                            const SizedBox(width: 6),
                            Text('Tout est à jour — aucune alerte.',
                                style: TextStyle(
                                    fontSize: 12.5,
                                    color: MsnColors.textSecondary
                                        .withValues(alpha: 0.9))),
                          ],
                        );
                      }
                      return Row(
                        children: alerts
                            .map((a) => Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: a,
                                  ),
                                ))
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  // ── 2. Statistiques essentielles ───────────────────────
                  counters.when(
                    loading: () => const SizedBox.shrink(),
                    error: (e, _) => const SizedBox.shrink(),
                    data: (c) => GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.65,
                      children: [
                        StatTile(
                            label: 'À répondre',
                            value: c.aRepondre,
                            icon: Icons.reply,
                            color: MsnColors.info,
                            onTap: () => context.go('/requests')),
                        StatTile(
                            label: 'En production',
                            value: c.enProduction,
                            icon: Icons.build,
                            color: MsnColors.primaryDark,
                            onTap: () => context.go('/orders')),
                        StatTile(
                            label: 'En attente client',
                            value: c.enAttenteClient,
                            icon: Icons.hourglass_top,
                            color: MsnColors.warning,
                            onTap: () => context.go('/orders')),
                        StatTile(
                            label: 'Catalogue & tarifs',
                            value: 0,
                            valueLabel: 'Voir',
                            icon: Icons.storefront,
                            color: MsnColors.textSecondary,
                            onTap: () => context.push('/catalog')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── 3. Demandes récentes ───────────────────────────────
                  SectionCard(
                    title: 'Demandes récentes',
                    action: TextButton(
                      onPressed: () => context.go('/requests'),
                      child: const Text('Tout voir'),
                    ),
                    child: recents.when(
                      loading: () => const SizedBox(
                          height: 40,
                          child: Center(
                              child: CircularProgressIndicator(
                                  strokeWidth: 2))),
                      error: (e, _) => Text('$e',
                          style: const TextStyle(color: MsnColors.danger)),
                      data: (list) => list.isEmpty
                          ? const Text(
                              'Aucune demande pour le moment. '
                              'Utilisez le bouton + pour en enregistrer.',
                              style: TextStyle(
                                  fontSize: 12.5,
                                  color: MsnColors.textSecondary))
                          : Column(
                              children: list
                                  .map((r) => ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                        leading: const Icon(
                                            Icons.inbox_outlined,
                                            size: 18,
                                            color: MsnColors.primary),
                                        title: Text(
                                            '${r.request.reference} — ${r.client.nom}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 13)),
                                        trailing: StatusChip.statut(
                                            statut: r.request.statut.name,
                                            label: r.request.statut.label),
                                        onTap: () => context.push(
                                            '/requests/${r.request.id}'),
                                      ))
                                  .toList(),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── 4. Deadlines proches ───────────────────────────────
                  SectionCard(
                    title: 'Deadlines à venir',
                    action: TextButton(
                      onPressed: () => context.push('/tasks'),
                      child: const Text('Tout voir'),
                    ),
                    child: deadlines.when(
                      loading: () => const SizedBox(
                          height: 40,
                          child: Center(
                              child: CircularProgressIndicator(
                                  strokeWidth: 2))),
                      error: (e, _) => Text('$e',
                          style: const TextStyle(color: MsnColors.danger)),
                      data: (list) => list.isEmpty
                          ? const Text(
                              'Aucune deadline proche. Continuez !',
                              style: TextStyle(
                                  fontSize: 12.5,
                                  color: MsnColors.textSecondary))
                          : Column(
                              children: list
                                  .map((d) => ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                        leading: const Icon(Icons.flag,
                                            size: 18,
                                            color: MsnColors.danger),
                                        title: Text('${d.reference} — ${d.titre}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 13)),
                                        subtitle: Text(d.clientNom,
                                            style: const TextStyle(
                                                fontSize: 11.5)),
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
                                        onTap: () => context
                                            .push('/orders/${d.orderId}'),
                                      ))
                                  .toList(),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── 5. Activité récente ────────────────────────────────
                  SectionCard(
                    title: 'Activité récente',
                    child: activity.when(
                      loading: () => const SizedBox(
                          height: 40,
                          child: Center(
                              child: CircularProgressIndicator(
                                  strokeWidth: 2))),
                      error: (e, _) => Text('$e',
                          style: const TextStyle(color: MsnColors.danger)),
                      data: (list) => list.isEmpty
                          ? const Text('Aucune activité enregistrée.',
                              style: TextStyle(
                                  fontSize: 12.5,
                                  color: MsnColors.textSecondary))
                          : Column(
                              children: list
                                  .map((a) => ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        dense: true,
                                        leading: Icon(_iconFor(a.action),
                                            size: 16,
                                            color: MsnColors.primary),
                                        title: Text(a.details,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 12.5)),
                                        subtitle: Text(
                                            '${a.userName} — '
                                            '${Formatters.dateTime(a.timestamp)}',
                                            style: const TextStyle(
                                                fontSize: 10.5)),
                                      ))
                                  .toList(),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
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

/// Pastille d'alerte prioritaire : gros chiffre sur fond coloré.
class _Alert extends StatelessWidget {
  const _Alert({
    required this.value,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final int value;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = color == MsnColors.warning || color == MsnColors.accent;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Text('$value',
                style: TextStyle(
                    fontSize: 26,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    color: dark
                        ? color.withValues(alpha: 0.95)
                        : color)),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 10.5,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                    color: MsnColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
