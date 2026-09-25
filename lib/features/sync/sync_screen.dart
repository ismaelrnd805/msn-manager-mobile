/// Écran de synchronisation — statut global, file d'attente, conflits
/// et configuration du serveur (réservé à l'administration).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/database/app_database.dart';
import '../../core/domain/enums.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../core/sync/sync_provider.dart';
import '../../core/theme/msn_theme.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/badges.dart';
import '../../shared/widgets/feedback.dart';

final syncQueueProvider = StreamProvider<List<SyncQueueData>>((ref) {
  return ref.watch(systemDaoProvider).watchQueue();
});

final syncConflictsProvider = StreamProvider<List<SyncConflict>>((ref) {
  return ref.watch(systemDaoProvider).watchOpenConflicts();
});

class SyncScreen extends ConsumerStatefulWidget {
  const SyncScreen({super.key});

  @override
  ConsumerState<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends ConsumerState<SyncScreen> {
  final _serverUrl = TextEditingController();
  bool _loadedUrl = false;

  @override
  Widget build(BuildContext context) {
    final sync = ref.watch(syncControllerProvider);
    final queue = ref.watch(syncQueueProvider);
    final conflicts = ref.watch(syncConflictsProvider);
    final session = ref.watch(sessionProvider);
    final isAdmin = session?.isAdmin ?? false;

    if (!_loadedUrl) {
      ref.read(systemDaoProvider).getValue(AppConstants.keyServerUrl).then(
            (v) {
          _serverUrl.text = v ?? '';
          if (mounted) setState(() => _loadedUrl = true);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Synchronisation')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // ── Statut ───────────────────────────────────────────────────
          Card(
            color: MsnColors.accentSoft,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SyncStatusChip(status: sync.status),
                  const SizedBox(height: 8),
                  Text(
                    switch (sync.status) {
                      SyncStatus.synchronise =>
                        'Toutes les données sont à jour avec le serveur.',
                      SyncStatus.enCours => 'Synchronisation en cours…',
                      SyncStatus.erreur =>
                        sync.error ?? 'Une erreur est survenue.',
                      SyncStatus.online =>
                        'En ligne — lancez une synchronisation.',
                      SyncStatus.offline =>
                        'Hors connexion. L’application continue de '
                            'fonctionner normalement ; la reprise se fera '
                            'automatiquement au retour du réseau.',
                      SyncStatus.nonConfigure =>
                        'Aucun serveur configuré : toutes les données '
                            'restent sur ce téléphone. Configurez le serveur '
                            'MSN pour activer le transfert PC.',
                    },
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12.5, height: 1.4),
                  ),
                  if (sync.lastRun != null) ...[
                    const SizedBox(height: 6),
                    Text('Dernier cycle : ${Formatters.dateTime(sync.lastRun)}',
                        style: const TextStyle(
                            fontSize: 11, color: MsnColors.textSecondary)),
                  ],
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: sync.status == SyncStatus.enCours
                        ? null
                        : () =>
                            ref.read(syncControllerProvider.notifier).runNow(),
                    icon: const Icon(Icons.sync, size: 18),
                    label: const Text('SYNCHRONISER MAINTENANT'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Conflits ─────────────────────────────────────────────────
          if ((conflicts.value ?? []).isNotEmpty) ...[
            Text('CONFLITS À RÉSOUDRE (${conflicts.value!.length})'
                .toUpperCase(),
                style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: MsnColors.danger)),
            const SizedBox(height: 6),
            ...conflicts.value!.map(
              (c) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${c.entite} — ${c.entityId}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 4),
                      const Text(
                          'Cette donnée a été modifiée des deux côtés. '
                          'Choisissez la version à conserver.',
                          style: TextStyle(
                              fontSize: 11.5,
                              color: MsnColors.textSecondary)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isAdmin
                                  ? () => _resolve(c, 'resolu_local')
                                  : null,
                              child: const Text('Garder local',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isAdmin
                                  ? () => _resolve(c, 'resolu_remote')
                                  : null,
                              child: const Text('Garder distant',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // ── File d'attente ───────────────────────────────────────────
          Text(
              'FILE D\u2019ATTENTE (${(queue.value ?? []).where((q) => q.statut != SyncQueueStatut.synchronise).length} en attente)'
                  .toUpperCase(),
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: MsnColors.textSecondary)),
          const SizedBox(height: 6),
          Card(
            child: (queue.value ?? []).isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('File vide — tout est synchronisé.',
                        style: TextStyle(
                            fontSize: 12, color: MsnColors.textSecondary)))
                : Column(
                    children: queue.value!
                        .take(20)
                        .map(
                          (q) => ListTile(
                            dense: true,
                            leading: Icon(
                              switch (q.statut) {
                                SyncQueueStatut.enAttente => Icons.schedule,
                                SyncQueueStatut.enCours => Icons.sync,
                                SyncQueueStatut.synchronise =>
                                  Icons.cloud_done,
                                SyncQueueStatut.erreur => Icons.error_outline,
                                SyncQueueStatut.conflit =>
                                  Icons.warning_amber,
                              },
                              size: 18,
                              color: q.statut == SyncQueueStatut.synchronise
                                  ? MsnColors.success
                                  : q.statut == SyncQueueStatut.erreur ||
                                          q.statut == SyncQueueStatut.conflit
                                      ? MsnColors.danger
                                      : MsnColors.info,
                            ),
                            title: Text('${q.entite} · ${q.operation.label}',
                                style: const TextStyle(fontSize: 12.5)),
                            subtitle: Text(
                                '${q.entityId} · tentatives : ${q.tentatives}',
                                style: const TextStyle(fontSize: 10.5)),
                            trailing: Text(q.statut.label,
                                style: const TextStyle(fontSize: 10.5)),
                          ),
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(height: 14),

          // ── Serveur (admin) ──────────────────────────────────────────
          if (isAdmin) ...[
            Text('SERVEUR MSN (ADMINISTRATION)'.toUpperCase(),
                style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: MsnColors.textSecondary)),
            const SizedBox(height: 6),
            TextField(
              controller: _serverUrl,
              decoration: const InputDecoration(
                labelText: 'URL du serveur NestJS (/api/v1)',
                hintText: 'ex. http://192.168.1.20:3000',
                suffixIcon: Icon(Icons.dns),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _saveServerUrl,
              child: const Text('ENREGISTRER L\u2019URL DU SERVEUR'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tant qu’aucune URL n’est configurée, aucune donnée ne quitte '
              'le téléphone. La spécification du serveur attendu est dans '
              'docs/05-backend-nestjs.md.',
              style: TextStyle(fontSize: 11.5, color: MsnColors.textSecondary),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _saveServerUrl() async {
    await ref
        .read(systemDaoProvider)
        .setValue(AppConstants.keyServerUrl, _serverUrl.text.trim());
    if (mounted) {
      showMsnSnack(context, 'URL du serveur enregistrée.');
    }
  }

  Future<void> _resolve(SyncConflict conflict, String resolution) async {
    await ref
        .read(systemDaoProvider)
        .resolveConflict(conflict.id, resolution);
    await ref.read(activityLoggerProvider).log(
          action: ActivityAction.synchronisation,
          entite: 'conflit',
          entityId: conflict.entityId,
          details:
              'Conflit sur ${conflict.entite}/${conflict.entityId} résolu '
              '($resolution).',
        );
    if (mounted) showMsnSnack(context, 'Conflit résolu.');
  }
}
