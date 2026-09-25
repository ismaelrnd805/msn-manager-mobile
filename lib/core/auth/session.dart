/// Authentification locale : session persistante, rôles, permissions.
///
/// v4 — session PERSISTANTE et sécurisée (flutter_secure_storage) :
/// - fermer/réduire l'application ne déconnecte plus l'utilisateur ;
/// - la session porte une date d'expiration (30 jours par défaut,
///   configurable via les paramètres) ;
/// - la déconnexion efface intégralement la session stockée ;
/// - le dernier écran consulté est mémorisé pour restaurer la navigation.
///
/// Le mot de passe est haché (SHA-256 salé) côté base : il n'est ni
/// stocké ni affiché en clair nulle part.
library;

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  const Session({
    required this.userName,
    required this.role,
    required this.issuedAt,
    required this.expiresAt,
  });

  final String userName;
  final UserRole role;
  final DateTime issuedAt;
  final DateTime expiresAt;

  bool get isAdmin => role == UserRole.admin;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
        'userName': userName,
        'role': role.name,
        'issuedAt': issuedAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      };

  static Session fromJson(Map<String, dynamic> json) => Session(
        userName: json['userName'] as String,
        role: UserRole.values
            .firstWhere((r) => r.name == json['role'], orElse: () => UserRole.operateur),
        issuedAt: DateTime.parse(json['issuedAt'] as String),
        expiresAt: DateTime.parse(json['expiresAt'] as String),
      );
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

/// Contrôleur de session (Notifier Riverpod) avec persistance sécurisée.
class SessionNotifier extends Notifier<Session?> {
  static const _storageKey = 'msn_session_v1';
  static const _lastRouteKey = 'msn_last_route';
  static const _defaultExpiryDays = 30;

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  Session? build() => null;

  SystemDao get _system => ref.read(systemDaoProvider);

  ActivityLogger get _logger => ref.read(activityLoggerProvider);

  /// Restaure la session persistée (appelée au démarrage, AVANT toute
  /// redirection du splash). Une session expirée ou dont l'utilisateur
  /// a été désactivé/supprimé est rejetée.
  Future<void> restore() async {
    try {
      final raw = await _storage.read(key: _storageKey);
      if (raw == null || raw.isEmpty) return;
      final session = Session.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
      if (session.isExpired) {
        await _storage.delete(key: _storageKey);
        return;
      }
      final user = await _system.userByName(session.userName);
      if (user == null || !user.actif) {
        await _storage.delete(key: _storageKey);
        return;
      }
      state = session;
    } catch (_) {
      // Session corrompue : on repart d'une session vierge sans
      // jamais bloquer le démarrage.
      try {
        await _storage.delete(key: _storageKey);
      } catch (_) {}
    }
  }

  /// Connexion : vérifie le nom d'utilisateur et le mot de passe, ouvre
  /// la session et la persiste.
  Future<void> login(String nom, String motDePasse) async {
    if (nom.trim().isEmpty || motDePasse.isEmpty) {
      throw const AppException('Saisissez votre nom d\'utilisateur et votre mot de passe.');
    }
    final user = await _system.userByName(nom.trim());
    if (user == null || !user.actif) {
      throw const AppException('Utilisateur inconnu ou désactivé.');
    }
    if (user.pinHash != DemoData.hashPin(motDePasse)) {
      throw const AppException('Mot de passe incorrect.');
    }

    final now = DateTime.now();
    final days = await _expiryDays();
    final session = Session(
      userName: user.nom,
      role: user.role,
      issuedAt: now,
      expiresAt: now.add(Duration(days: days)),
    );
    state = session;
    try {
      await _storage.write(key: _storageKey, value: jsonEncode(session.toJson()));
    } catch (_) {
      // Sans secure storage (cas très rare), l'app fonctionne avec une
      // session mémoire : l'utilisateur devra se reconnecter.
    }
    await _logger.log(
      action: ActivityAction.connexion,
      entite: 'session',
      details: 'Connexion de ${user.nom} (${user.role.label}).',
    );
    await _system.setValue('last_user', user.nom);
  }

  /// Déconnexion : invalide la session mémoire ET efface le stockage
  /// sécurisé (nettoyage complet).
  Future<void> logout() async {
    final name = state?.userName;
    state = null;
    try {
      await _storage.delete(key: _storageKey);
      await _storage.delete(key: _lastRouteKey);
    } catch (_) {}
    if (name != null) {
      await _logger.log(
        action: ActivityAction.connexion,
        entite: 'session',
        details: 'Déconnexion de $name.',
      );
    }
  }

  /// Mémorise le dernier écran consulté (restauration de navigation).
  Future<void> saveLastRoute(String location) async {
    if (location == '/login' || location == '/') return;
    try {
      await _storage.write(key: _lastRouteKey, value: location);
    } catch (_) {}
  }

  /// Dernier écran consulté (null si aucun / invalide).
  Future<String?> lastRoute() async {
    try {
      return await _storage.read(key: _lastRouteKey);
    } catch (_) {
      return null;
    }
  }

  /// Durée d'expiration de session (en jours) — administrable.
  Future<int> _expiryDays() async {
    final raw = await _system.getValue('session_expiry_days');
    return int.tryParse(raw ?? '') ?? _defaultExpiryDays;
  }

  /// Change le mot de passe d'un utilisateur (réservé à l'administration).
  Future<void> changePassword(String userId, String newSecret) async {
    if (!AppPermissions.canManageUsers(state)) {
      throw const PermissionException('Changement de mot de passe');
    }
    if (newSecret.length < 4) {
      throw const AppException(
          'Le mot de passe doit contenir au moins 4 caractères.');
    }
    final user = await _system.userById(userId);
    if (user == null) throw const AppException('Utilisateur introuvable.');
    await _system.upsertUser(
      User(
        id: user.id,
        nom: user.nom,
        pinHash: DemoData.hashPin(newSecret),
        role: user.role,
        actif: user.actif,
        createdAt: user.createdAt,
      ),
    );
    await _logger.log(
      action: ActivityAction.modification,
      entite: 'utilisateur',
      entityId: user.id,
      details: 'Mot de passe de ${user.nom} modifié.',
    );
  }
}
