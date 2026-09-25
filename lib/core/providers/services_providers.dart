/// Wiring central des services et contrôleurs Riverpod.
///
/// Tout l'application résout ses dépendances ici : chaque écran consomme
/// des providers — jamais de singletons globaux ni d'init implicite.
library;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session.dart';
import '../services/activity_logger.dart';
import '../services/backup_service.dart';
import '../services/connectivity_service.dart';
import '../services/file_ingest_service.dart';
import '../services/notification_service.dart';
import '../services/numbering_service.dart';
import '../services/pdf/pdf_service.dart';
import '../services/reminder_service.dart';
import '../services/share_service.dart';
import '../sync/api_client.dart';
import '../sync/sync_engine.dart';
import 'database_provider.dart';

// ── Services ────────────────────────────────────────────────────────────────

final numberingServiceProvider = Provider<NumberingService>(
    (ref) => NumberingService(ref.watch(appDatabaseProvider)));

final shareServiceProvider =
    Provider<ShareService>((ref) => const ShareService());

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());

final pdfServiceProvider =
    Provider<PdfService>((ref) => PdfService(ref.watch(appDatabaseProvider)));

final backupServiceProvider = Provider<BackupService>(
    (ref) => BackupService(ref.watch(appDatabaseProvider)));

final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService(
    ref.watch(systemDaoProvider),
    ref.watch(notificationServiceProvider),
  );
});

final fileIngestServiceProvider = Provider<FileIngestService>(
    (ref) => FileIngestService(ref.watch(appDatabaseProvider)));

final connectivityServiceProvider = Provider<ConnectivityService>(
    (ref) => ConnectivityService(_connectivityInstance()));

final syncEngineProvider = Provider<SyncEngine>((ref) {
  return SyncEngine(
    ref.watch(appDatabaseProvider),
    ref.watch(systemDaoProvider),
    ref.watch(connectivityServiceProvider),
  );
});

final apiClientFactoryProvider = Provider<ApiClient Function(String baseUrl)>(
  (ref) => (baseUrl) => ApiClient(
        baseUrl: baseUrl,
        deviceId: 'mobile-msn',
      ),
);

// ── Journal & session ───────────────────────────────────────────────────────

final activityLoggerProvider = Provider<ActivityLogger>((ref) {
  final dao = ref.watch(systemDaoProvider);
  return ActivityLogger(dao, () {
    final session = ref.read(sessionProvider);
    return session?.userName ?? 'système';
  });
});

final sessionProvider =
    NotifierProvider<SessionNotifier, Session?>(SessionNotifier.new);

// ── Helpers internes ────────────────────────────────────────────────────────

// connectivity_plus : une instance par service, suffisante pour l'app.
Connectivity _connectivityInstance() => Connectivity();

