/// Hub « Plus » — accès à tous les modules (gardés par le registre).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/modules/module_registry.dart';
import '../../core/theme/msn_theme.dart';
import '../../shared/widgets/empty_state.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(moduleRegistryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Plus de fonctions')),
      body: modules.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (registry) {
          final entries = <(String, String, IconData, String)>[
            ('catalog', 'Catalogue & tarifs', Icons.storefront, '/catalog'),
            ('quotes', 'Devis', Icons.request_quote, '/quotes'),
            ('invoices', 'Factures', Icons.receipt_long, '/invoices'),
            ('payments', 'Paiements', Icons.payments, '/payments'),
            ('communication', 'Modèles de messages', Icons.forum,
                '/communication/templates'),
            ('documents', 'Documents générés', Icons.folder_open, '/documents'),
            ('tasks', 'Tâches & rappels', Icons.task_alt, '/tasks'),
            ('sync', 'Synchronisation', Icons.sync, '/sync'),
            ('admin', 'Administration', Icons.admin_panel_settings_outlined,
                '/settings'),
          ];
          final visible = entries
              .where((e) => registry.isActive(e.$1))
              .toList();
          final disabled = entries
              .where((e) => !registry.isActive(e.$1))
              .toList();

          if (visible.isEmpty) {
            return const EmptyState(
              icon: Icons.apps,
              title: 'Tous les modules sont désactivés',
              message:
                  'Un administrateur peut réactiver les modules dans '
                  'Administration > Modules.',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              ...visible.map((e) => Card(
                    child: ListTile(
                      leading: Icon(e.$3),
                      title: Text(e.$2,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      trailing: const Icon(Icons.chevron_right,
                          size: 20, color: MsnColors.textSecondary),
                      onTap: () => context.push(e.$4),
                    ),
                  )),
              if (disabled.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(4, 16, 4, 6),
                  child: Text('MODULES DÉSACTIVÉS',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: MsnColors.textSecondary)),
                ),
                ...disabled.map((e) => Card(
                      color: MsnColors.surface,
                      child: ListTile(
                        leading: Icon(e.$3,
                            color: MsnColors.textSecondary.withValues(alpha: 0.5)),
                        title: Text(e.$2,
                            style: TextStyle(
                                fontSize: 14,
                                color: MsnColors.textSecondary
                                    .withValues(alpha: 0.8))),
                        subtitle: const Text(
                            'Module désactivé — réactivez-le dans '
                            'Administration > Modules.',
                            style: TextStyle(fontSize: 10.5)),
                        onTap: registry.isActive('admin')
                            ? () => context.push('/settings/modules')
                            : null,
                      ),
                    )),
              ],
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
