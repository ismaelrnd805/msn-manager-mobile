/// Authentification locale : session, rôles, permissions, verrouillage.
///
/// Le PIN est haché (SHA-256 salé) et la session vit en mémoire :
/// au redémarrage de l'application, une nouvelle connexion est exigée
/// (expiration de session garantie, cf. section 29 du cahier des charges).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/daos/system_dao.dart';
import '../domain/enums.dart';
import '../errors/app_exception.dart';
import '../providers/database_provider.dart';
import '../providers/services_providers.dart';
import '../services/activity_logger.dart';
import '../database/seed/demo_data.dart';

/// Session courante de l'utilisateur.
class Session {
  const Session({required this.userName, required this.role});

  final String userName;
  final UserRole role;

  bool get isAdmin => role == UserRole.admin;
}

/// Permissions fines par action sensible.
class AppPermissions {
  AppPermissions._();

  static bool canManageCatalog(Session? session) => session?.isAdmin ?? false;

  static bool canManageModules(Session? session) => session?.isAdmin ?? false;

  static bool canManageUsers(Session? session) => session?.isAdmin ?? false;

  static bool canEditTemplates(Session? session) => session?.isAdmin ?? false;

  static bool canResolveConflicts(Session? session) => session?.isAdmin ?? false;

  static bool canPurgeTrash(Session? session) => session?.isAdmin ?? false;

  static bool canImportBackup(Session? session) => session?.isAdmin ?? false;

  static bool canOverrideRules(Session? session) => session?.isAdmin ?? false;
}

/// Contrôleur de session (Notifier Riverpod).
class SessionNotifier extends Notifier<Session?> {
  @override
  Session? build() => null;

  SystemDao get _system => ref.read(systemDaoProvider);

  ActivityLogger get _logger => ref.read(activityLoggerProvider);

  /// Connexion : vérifie le PIN et ouvre la session.
  Future<void> login(String nom, String pin) async {
    final user = await _system.userByName(nom.trim());
    if (user == null || !user.actif) {
      throw const AppException('Utilisateur inconnu ou désactivé.');
    }
    if (user.pinHash != DemoData.hashPin(pin)) {
      throw const AppException('PIN incorrect.');
    }
    state = Session(userName: user.nom, role: user.role);
    await _logger.log(
      action: ActivityAction.connexion,
      entite: 'session',
      details: 'Connexion de ${user.nom} (${user.role.label}).',
    );
    await _system.setValue('last_user', user.nom);
  }

  /// Déconnexion : invalide la session en mémoire.
  Future<void> logout() async {
    final name = state?.userName;
    state = null;
    if (name != null) {
      await _logger.log(
        action: ActivityAction.connexion,
        entite: 'session',
        details: 'Déconnexion de $name.',
      );
    }
  }

  /// Change le PIN d'un utilisateur (réservé à l'administration).
  Future<void> changePin(String userId, String newPin) async {
    if (!AppPermissions.canManageUsers(state)) {
      throw const PermissionException('Changement de PIN');
    }
    if (newPin.length < 4) {
      throw const AppException('Le PIN doit contenir au moins 4 chiffres.');
    }
    final user = await _system.userByName(userId);
    if (user == null) throw const AppException('Utilisateur introuvable.');
    await _system.upsertUser(
      User(
        id: user.id,
        nom: user.nom,
        pinHash: DemoData.hashPin(newPin),
        role: user.role,
        actif: user.actif,
        createdAt: user.createdAt,
      ),
    );
  }
}
