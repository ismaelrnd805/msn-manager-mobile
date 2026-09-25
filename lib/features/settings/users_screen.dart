/// Utilisateurs & PIN — gestion des comptes locaux (admin).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/domain/enums.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../core/theme/msn_theme.dart';
import '../../shared/widgets/feedback.dart';

final usersProvider = StreamProvider<List<User>>((ref) {
  return ref.watch(systemDaoProvider).watchUsers();
});

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Utilisateurs')),
      body: users.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final u = list[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: MsnColors.primary.withValues(alpha: 0.12),
                  child: Text(u.nom.isNotEmpty ? u.nom[0].toUpperCase() : '?',
                      style: const TextStyle(
                          color: MsnColors.primary,
                          fontWeight: FontWeight.w800)),
                ),
                title: Text(u.nom,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(u.role.label, style: const TextStyle(fontSize: 12)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => _changePassword(context, ref, u),
                      child: const Text('PIN'),
                    ),
                    Switch(
                      value: u.actif,
                      onChanged: (v) async {
                        await ref.read(systemDaoProvider).upsertUser(
                              User(
                                id: u.id,
                                nom: u.nom,
                                pinHash: u.pinHash,
                                role: u.role,
                                actif: v,
                                createdAt: u.createdAt,
                              ),
                            );
                        await ref.read(activityLoggerProvider).log(
                              action: ActivityAction.modification,
                              entite: 'utilisateur',
                              entityId: u.id,
                              details: v
                                  ? 'Utilisateur « ${u.nom} » activé.'
                                  : 'Utilisateur « ${u.nom} » désactivé.',
                            );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _changePassword(
      BuildContext context, WidgetRef ref, User user) async {
    final secret = TextEditingController();
    final confirm = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mot de passe de ${user.nom}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: secret,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                  labelText: 'Nouveau mot de passe (4+ caractères)'),
            ),
            TextField(
              controller: confirm,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Confirmer le mot de passe'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Valider')),
        ],
      ),
    );
    if (ok != true) return;
    if (secret.text != confirm.text || secret.text.length < 4) {
      if (context.mounted) {
        showMsnSnack(
            context, 'Mots de passe différents ou trop courts (4 minimum).',
            error: true);
      }
      return;
    }
    try {
      await ref
          .read(sessionProvider.notifier)
          .changePassword(user.id, secret.text);
      if (context.mounted) showMsnSnack(context, 'Mot de passe mis à jour.');
    } catch (e) {
      if (context.mounted) showMsnSnack(context, e.toString(), error: true);
    }
  }
}
