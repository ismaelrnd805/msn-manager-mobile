/// Journal d'activité — trace toutes les opérations sensibles
/// (section 27 du cahier des charges).
///
/// L'utilisateur courant est injecté par [services_providers] à partir de
/// la session active ; sans session, l'entrée est attribuée à « système ».
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
    );
    return _dao.insertActivity(entry);
  }
}
