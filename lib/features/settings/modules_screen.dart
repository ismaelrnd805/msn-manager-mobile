/// Activation / désactivation des modules (section 7) — effet immédiat
/// sur l'ensemble de l'application, sans redémarrage.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/modules/module_registry.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../core/domain/enums.dart';
import '../../core/theme/msn_theme.dart';

class ModulesScreen extends ConsumerWidget {
  const ModulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(moduleRegistryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Modules de l\u2019application')),
      body: modules.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (registry) => ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Activez uniquement ce dont MSN a besoin aujourd\u2019hui. '
                'De nouveaux modules pourront être ajoutés plus tard sans '
                'réécrire l\u2019application.',
                style: TextStyle(fontSize: 12.5, color: MsnColors.textSecondary),
              ),
            ),
            for (final module in ModuleCatalog.all)
              SwitchListTile(
                value: registry.isActive(module.code),
                onChanged: (v) async {
                  await ref
                      .read(systemDaoProvider)
                      .setModuleActif(module.code, v);
                  await ref.read(activityLoggerProvider).log(
                        action: v
                            ? ActivityAction.modification
                            : ActivityAction.modification,
                        entite: 'module',
                        entityId: module.code,
                        details: v
                            ? 'Module « ${module.label} » activé.'
                            : 'Module « ${module.label} » désactivé.',
                      );
                },
                title: Text(module.label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(
                  module.core
                      ? module.description
                      : '${module.description} — optionnel',
                  style: const TextStyle(fontSize: 11.5),
                ),
                secondary: Icon(
                  module.core ? Icons.lock_outline : Icons.extension,
                  size: 20,
                  color: module.core
                      ? MsnColors.primary
                      : MsnColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
