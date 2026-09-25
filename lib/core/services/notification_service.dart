/// Notifications locales — rappels de deadlines, relances, acomptes…
///
/// Architecture compatible Firebase Cloud Messaging : la réception de
/// notifications push s'ajoutera ultérieurement sans modifier ce service
/// (voir docs/12-feuille-de-route.md).
///
/// Si l'initialisation échoue (plateforme non supportée, permissions),
/// les rappels restent visibles dans l'application — aucune perte de
/// fonctionnalité métier, uniquement l'alerte système en moins.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Fuseau par défaut : Madagascar (Indian/Antananarivo, UTC+3 sans DST).
  /// Modifiable en un seul endroit si MSN ouvre une agence ailleurs.
  static const String defaultTimezone = 'Indian/Antananarivo';

  Future<void> init() async {
    if (_initialized) return;
    try {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(defaultTimezone));

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);
      final ok = await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (_) {},
      );
      _initialized = ok ?? false;
    } catch (e) {
      debugPrint('NotificationService: initialisation impossible ($e). '
          'Les rappels resteront visibles dans l’app.');
      _initialized = false;
    }
  }

  bool get canSchedule => _initialized;

  /// Demande la permission de notifications (Android 13+, POST_NOTIFICATIONS).
  ///
  /// Appelée au démarrage, juste avant la planification des premiers
  /// rappels : l'utilisateur voit une demande système claire au moment
  /// réel où les notifications deviennent utiles. En cas de refus, rien ne
  /// bloque : les rappels restent visibles dans l'application et la
  /// permission peut être accordée plus tard depuis les réglages Android.
  Future<bool> requestPermission() async {
    if (!_initialized) return false;
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? false;
    } catch (e) {
      debugPrint('NotificationService: demande de permission impossible ($e).');
      return false;
    }
  }

  /// Planifie une notification locale à [when] (rappel de deadline…).
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    if (!_initialized) return;
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(when, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'msn_reminders',
            'Rappels MSN',
            channelDescription: 'Deadlines, relances, acomptes et soldes',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('NotificationService: planification impossible ($e).');
    }
  }

  /// Notification immédiate (éléments échus au lancement).
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;
    try {
      await _plugin.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'msn_urgent',
            'Alertes MSN',
            channelDescription: 'Rappels échus',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    } catch (e) {
      debugPrint('NotificationService: affichage impossible ($e).');
    }
  }
}
