/// Service de rappels — vérifie les rappels échus, affiche les
/// notifications locales et les marque comme notifiés.
///
/// Appelé au démarrage de l'application et à chaque cycle de
/// synchronisation. Les rappels restent visibles dans l'app même si les
/// notifications système ne sont pas disponibles.
library;

import 'package:flutter/foundation.dart';

import '../database/daos/system_dao.dart';
import 'notification_service.dart';

class ReminderService {
  ReminderService(this._system, this._notifications);

  final SystemDao _system;
  final NotificationService _notifications;

  /// Notifie tous les rappels échus et marque leurs notifications.
  Future<int> flushDue() async {
    try {
      final due = await _system.dueReminders();
      for (final r in due) {
        await _notifications.showNow(
          id: r.id.hashCode & 0x7fffffff,
          title: r.titre,
          body: r.description ?? r.type.label,
        );
        await _system.markReminderNotified(r.id);
      }
      return due.length;
    } catch (e) {
      debugPrint('ReminderService.flushDue: $e');
      return 0;
    }
  }
}
