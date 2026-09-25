/// Journal d'activité — traçabilité complète des opérations (section 27).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/enums.dart';
import '../../core/providers/database_provider.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/msn_theme.dart';
import '../../core/utils/formatters.dart';

final journalProvider = StreamProvider<List<ActivityLogData>>((ref) {
  return ref.watch(systemDaoProvider).watchRecentActivity(limit: 200);
});

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(journalProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Journal d\u2019activité')),
      body: entries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => list.isEmpty
            ? const Center(
                child: Text('Aucune activité enregistrée.',
                    style: TextStyle(color: MsnColors.textSecondary)))
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final a = list[index];
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      _icon(a.action),
                      size: 18,
                      color: _color(a.action),
                    ),
                    title: Text(a.details,
                        style: const TextStyle(fontSize: 12.5)),
                    subtitle: Text(
                        '${a.userName} · ${a.entite} · '
                        '${Formatters.dateTime(a.timestamp)}',
                        style: const TextStyle(fontSize: 10.5)),
                  );
                },
              ),
      ),
    );
  }

  IconData _icon(ActivityAction action) {
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

  Color _color(ActivityAction action) {
    switch (action) {
      case ActivityAction.paiement:
        return MsnColors.success;
      case ActivityAction.suppression:
      case ActivityAction.exceptionRegles:
        return MsnColors.danger;
      case ActivityAction.changementTarif:
      case ActivityAction.changementStatut:
        return MsnColors.warning;
      default:
        return MsnColors.primary;
    }
  }
}
