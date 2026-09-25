/// Hub d'administration — modules, modèles, questions, utilisateurs,
/// journal, corbeille, sauvegarde et informations système.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/services_providers.dart';
import '../../core/theme/msn_theme.dart';
import '../../shared/widgets/feedback.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () async {
              await ref.read(sessionProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // ── Session ──────────────────────────────────────────────────
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: MsnColors.primary.withValues(alpha: 0.12),
                child: Text(
                  (session?.userName.isNotEmpty ?? false)
                      ? session!.userName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      color: MsnColors.primary,
                      fontWeight: FontWeight.w800),
                ),
              ),
              title: Text(session?.userName ?? '—',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(session?.role.label ?? '',
                  style: const TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(height: 12),

          _section(context, 'CONFIGURATION', [
            ('Modules de l\u2019application', Icons.extension, '/settings/modules'),
            ('Modèles de messages', Icons.forum, '/settings/templates'),
            ('Questions de qualification', Icons.quiz_outlined,
                '/settings/qualification'),
            ('Utilisateurs & mots de passe', Icons.manage_accounts,
                '/settings/users'),
          ]),
          _section(context, 'CONTENUS CLIENT', [
            ('Conditions contractuelles', Icons.rule, '/settings/conditions'),
            ('Catalogues en image', Icons.image_outlined,
                '/settings/catalog-images'),
            ('Processus client', Icons.route, '/settings/process'),
            ('Workflows & instructions', Icons.account_tree,
                '/settings/workflows'),
            ('Dictionnaire FR → MG', Icons.translate, '/settings/dictionary'),
          ]),
          _section(context, 'DONNÉES', [
            ('Journal d\u2019activité', Icons.history, '/settings/journal'),
            ('Corbeille', Icons.delete_outline, '/settings/trash'),
          ]),
          const SizedBox(height: 4),

          // ── Sauvegarde ───────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SAUVEGARDE LOCALE',
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: MsnColors.textSecondary)),
                  const SizedBox(height: 8),
                  const Text(
                      'Export complet de la base (JSON) partageable par '
                      'email/WhatsApp. La restauration remplace toutes les '
                      'données actuelles.',
                      style: TextStyle(
                          fontSize: 12, color: MsnColors.textSecondary)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _export(context, ref),
                          icon: const Icon(Icons.file_download, size: 18),
                          label: const Text('Exporter',
                              style: TextStyle(fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── À propos ─────────────────────────────────────────────────
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('À PROPOS',
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: MsnColors.textSecondary)),
                  SizedBox(height: 8),
                  Text('MSN Manager Mobile',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  Text(
                      'Version ${AppConstants.appVersion} · '
                      'Schéma base v${AppConstants.databaseSchemaVersion}',
                      style: TextStyle(fontSize: 12)),
                  Text(
                      'Offline-first : fonctionne intégralement sans '
                      'connexion. Synchronisation vers le serveur MSN '
                      'quand elle est configurée.',
                      style:
                          TextStyle(fontSize: 11.5, height: 1.4)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title,
      List<(String, IconData, String)> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
          child: Text(title,
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: MsnColors.textSecondary)),
        ),
        Card(
          child: Column(
            children: items
                .map((e) => ListTile(
                      leading: Icon(e.$2),
                      title: Text(e.$1,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () => context.push(e.$3),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    try {
      final path = await runWithLoading(
        context,
        'Export en cours…',
        () => ref.read(backupServiceProvider).exportToJson(),
      );
      if (context.mounted) {
        await Share.shareXFiles([XFile(path)],
            subject: 'Sauvegarde MSN Manager');
      }
    } catch (e) {
      if (context.mounted) showMsnSnack(context, e.toString(), error: true);
    }
  }
}
