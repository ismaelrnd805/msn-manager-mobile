/// Journal d'activité — trace toutes les opérations sensibles
/// (section 27 du cahier des charges).
///
/// L'utilisateur courant est injecté par [services_providers] à partir de
/// la session active ; sans session, l'entrée est attribuée à « système ».
///
/// v4 : chaque modification peut être tracée champ par champ
/// (ancienne valeur → nouvelle valeur).
library;

import '../database/app_database.dart';
import '../database/daos/system_dao.dart';
import '../domain/enums.dart';

class ActivityLogger {
  ActivityLogger(this._dao, this._currentUser);

  final SystemDao _dao;
  final String Function() _currentUser;

  Future<void> log({
    required ActivityAction action,
    required String entite,
    String? entityId,
    required String details,
    String? userName,
    String? champ,
    String? ancienneValeur,
    String? nouvelleValeur,
  }) {
    final entry = ActivityLogData(
      id: DateTime.now().microsecondsSinceEpoch.toString() +
          entite.hashCode.toString(),
      timestamp: DateTime.now(),
      userName: userName ?? _currentUser(),
      action: action,
      entite: entite,
      entityId: entityId,
      details: details,
      champ: champ,
      ancienneValeur: ancienneValeur,
      nouvelleValeur: nouvelleValeur,
    );
    return _dao.insertActivity(entry);
  }

  /// Trace une modification de champ : « X a modifié [champ] de A vers B ».
  ///
  /// Utilisée par tous les écrans d'édition pour garantir un historique
  /// homogène sans dupliquer la logique.
  Future<void> logFieldChange({
    required String entite,
    required String entityId,
    required String reference,
    required String champ,
    required String libelleChamp,
    String? ancienneValeur,
    String? nouvelleValeur,
  }) {
    final avant = ancienneValeur == null || ancienneValeur.isEmpty
        ? '—'
        : '« $ancienneValeur »';
    final apres = nouvelleValeur == null || nouvelleValeur.isEmpty
        ? '—'
        : '« $nouvelleValeur »';
    return log(
      action: ActivityAction.modification,
      entite: entite,
      entityId: entityId,
      champ: champ,
      ancienneValeur: ancienneValeur,
      nouvelleValeur: nouvelleValeur,
      details: 'Modification de $libelleChamp de $avant vers $apres '
          '($reference).',
    );
  }
}
