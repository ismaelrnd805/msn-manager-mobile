/// Exceptions applicatives centralisées.
library;

class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

/// Levée quand une règle métier bloque une transition de workflow.
class RuleViolationException extends AppException {
  const RuleViolationException(this.violations)
      : super('Règles métier non satisfaites');

  final List<RuleViolationInfo> violations;
}

/// Représentation transportable d'une violation (sans dépendre du moteur).
class RuleViolationInfo {
  const RuleViolationInfo({required this.cle, required this.message});

  final String cle;
  final String message;
}

/// Levée quand une action nécessite un rôle supérieur.
class PermissionException extends AppException {
  const PermissionException(this.action)
      : super('Action réservée : $action. Connectez-vous avec un compte '
          'administrateur.');

  final String action;
}

/// Levée quand une opération réseau échoue (le mode offline reste garanti).
class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// Levée quand un conflit de synchronisation nécessite une décision humaine.
class SyncConflictException extends AppException {
  const SyncConflictException(this.entity, this.entityId)
      : super('Conflit de synchronisation sur $entity/$entityId');

  final String entity;
  final String entityId;
}
