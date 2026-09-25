/// Contrôleur de synchronisation — état global affiché dans l'interface
/// (ONLINE / OFFLINE / SYNCHRONISATION EN COURS / SYNCHRONISÉ /
/// ERREUR DE SYNCHRONISATION) et déclenchement automatique.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/daos/system_dao.dart';
import '../domain/enums.dart';
import '../providers/database_provider.dart';
import '../providers/services_providers.dart';
import '../services/connectivity_service.dart';
import 'sync_engine.dart';

/// État de synchronisation observable par l'UI.
class SyncState {
  const SyncState({
    required this.status,
    this.lastRun,
    this.pendingCount = 0,
    this.error,
  });

  final SyncStatus status;
  final DateTime? lastRun;
  final int pendingCount;
  final String? error;

  SyncState copyWith({
    SyncStatus? status,
    DateTime? lastRun,
    int? pendingCount,
    String? error,
  }) {
    return SyncState(
      status: status ?? this.status,
      lastRun: lastRun ?? this.lastRun,
      pendingCount: pendingCount ?? this.pendingCount,
      error: error,
    );
  }
}

class SyncController extends Notifier<SyncState> {
  Timer? _timer;
  bool _wired = false;

  @override
  SyncState build() {
    ref.onDispose(() {
      _timer?.cancel();
      _timer = null;
    });
    // État initial : évalué immédiatement puis rafraîchi.
    Future.microtask(_bootstrap);
    return const SyncState(status: SyncStatus.offline);
  }

  SyncEngine get _engine => ref.read(syncEngineProvider);
  SystemDao get _system => ref.read(systemDaoProvider);

  Future<void> _bootstrap() async {
    try {
      final status = await _engine.currentStatus();
      final pending = (await _system.pending(limit: 500)).length;
      state = state.copyWith(status: status, pendingCount: pending);
      await ref.read(reminderServiceProvider).flushDue();
    } catch (e) {
      debugPrint('SyncController bootstrap: $e');
    }
    if (_wired) return;
    _wired = true;
    // Déclenchement automatique quand la connexion revient.
    ref.listen(connectivityProvider, (prev, next) {
      next.whenData((online) {
        if (online) {
          runNow();
        } else {
          state = state.copyWith(status: SyncStatus.offline);
        }
      });
    });
    // Cycle périodique de sécurité (toutes les 5 minutes).
    _timer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => runNow(),
    );
  }

  /// Lance un cycle de synchronisation manuellement.
  Future<void> runNow() async {
    state = state.copyWith(status: SyncStatus.enCours, error: null);
    try {
      final report = await _engine.run();
      final pending = (await _system.pending(limit: 500)).length;
      state = state.copyWith(
        status: report.status,
        lastRun: DateTime.now(),
        pendingCount: pending,
        error: report.error,
      );
    } catch (e) {
      state = state.copyWith(
        status: SyncStatus.erreur,
        lastRun: DateTime.now(),
        error: e.toString(),
      );
    }
  }

  Future<void> refreshPendingCount() async {
    final pending = (await _system.pending(limit: 500)).length;
    state = state.copyWith(pendingCount: pending);
  }
}

final syncControllerProvider =
    NotifierProvider<SyncController, SyncState>(SyncController.new);
