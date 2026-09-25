/// DAO système — paramètres, journal, file de sync, conflits, rappels,
/// tâches, utilisateurs, modules.
library;

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

class SystemDao extends DatabaseAccessor<AppDatabase> {
  SystemDao(super.db);

  // ── Paramètres ────────────────────────────────────────────────────────────

  Future<String?> getValue(String cle) async {
    final row = await (select(settings)..where((s) => s.cle.equals(cle)))
        .getSingleOrNull();
    return row?.valeur;
  }

  Future<void> setValue(String cle, String valeur) =>
      into(settings).insertOnConflictUpdate(
        SettingsCompanion.insert(cle: cle, valeur: valeur),
      );

  // ── Journal d'activité ────────────────────────────────────────────────────

  Future<void> insertActivity(ActivityLog row) => into(activityLog).insert(row);

  Stream<List<ActivityLog>> watchRecentActivity({int limit = 50}) =>
      (select(activityLog)
            ..orderBy([(a) => OrderingTerm.desc(a.timestamp)])
            ..limit(limit))
          .watch();

  // ── File de synchronisation ───────────────────────────────────────────────

  Future<void> enqueue(SyncQueue row) => into(syncQueue).insert(row);

  Stream<List<SyncQueue>> watchQueue({int limit = 100}) =>
      (select(syncQueue)
            ..orderBy([(q) => OrderingTerm.desc(q.createdAt)])
            ..limit(limit))
          .watch();

  Future<List<SyncQueue>> pending({int limit = 50}) =>
      (select(syncQueue)
            ..where((q) => q.statut.isIn(
                [SyncQueueStatut.enAttente.name, SyncQueueStatut.erreur.name]))
            ..orderBy([(q) => OrderingTerm.asc(q.createdAt)])
            ..limit(limit))
          .get();

  Future<void> markQueueStatut(String id, SyncQueueStatut statut,
      {String? erreur}) {
    return (update(syncQueue)..where((q) => q.id.equals(id))).write(
      SyncQueueCompanion(
        statut: Value(statut),
        derniereErreur: Value(erreur),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> incrementTentative(String id, String erreur) async {
    final row =
        await (select(syncQueue)..where((q) => q.id.equals(id))).getSingle();
    await (update(syncQueue)..where((q) => q.id.equals(id))).write(
      SyncQueueCompanion(
        tentatives: Value(row.tentatives + 1),
        statut: const Value(SyncQueueStatut.erreur),
        derniereErreur: Value(erreur),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> clearSynchronized() =>
      (delete(syncQueue)..where((q) => q.statut.equals(SyncQueueStatut.synchronise.name)))
          .go();

  // ── Conflits ──────────────────────────────────────────────────────────────

  Future<void> insertConflict(SyncConflict row) =>
      into(syncConflicts).insert(row);

  Stream<List<SyncConflict>> watchOpenConflicts() =>
      (select(syncConflicts)..where((c) => c.statut.equals('ouvert'))
            ..orderBy([(c) => OrderingTerm.desc(c.detecteLe)]))
          .watch();

  Future<void> resolveConflict(String id, String resolution) =>
      (update(syncConflicts)..where((c) => c.id.equals(id))).write(
        SyncConflictsCompanion(
          statut: Value(resolution),
          resoluLe: Value(DateTime.now()),
        ),
      );

  // ── Rappels ───────────────────────────────────────────────────────────────

  Stream<List<Reminder>> watchReminders({bool onlyActive = false}) =>
      (select(reminders)
            ..where(onlyActive
                ? (r) => r.termine.equals(false)
                : (r) => const CustomExpression<bool>('1 = 1'))
            ..orderBy([(r) => OrderingTerm.asc(r.dateRappel)]))
          .watch();

  Future<void> upsertReminder(Reminder row) =>
      into(reminders).insertOnConflictUpdate(row);

  Future<void> markReminderDone(String id) =>
      (update(reminders)..where((r) => r.id.equals(id)))
          .write(const RemindersCompanion(termine: Value(true)));

  Future<void> markReminderNotified(String id) =>
      (update(reminders)..where((r) => r.id.equals(id)))
          .write(const RemindersCompanion(notifie: Value(true)));

  /// Rappels à notifier (date passée, pas encore notifiés ni terminés).
  Future<List<Reminder>> dueReminders() =>
      (select(reminders)
            ..where((r) =>
                r.termine.equals(false) &
                r.notifie.equals(false) &
                r.dateRappel.isSmallerOrEqualValue(DateTime.now())))
          .get();

  // ── Tâches ────────────────────────────────────────────────────────────────

  Stream<List<Task>> watchTasks({bool onlyOpen = false}) =>
      (select(tasks)
            ..where(onlyOpen
                ? (t) => t.statut.isIn(['aFaire', 'enCours'])
                : (t) => const CustomExpression<bool>('1 = 1'))
            ..orderBy([
              (t) => OrderingTerm.asc(t.echeance),
              (t) => OrderingTerm.desc(t.createdAt),
            ]))
          .watch();

  Future<void> upsertTask(Task row) => into(tasks).insertOnConflictUpdate(row);

  // ── Utilisateurs ──────────────────────────────────────────────────────────

  Stream<List<User>> watchUsers() =>
      (select(users)..orderBy([(u) => OrderingTerm.asc(u.nom)])).watch();

  Future<List<User>> activeUsers() =>
      (select(users)..where((u) => u.actif.equals(true))).get();

  Future<User?> userByName(String nom) =>
      (select(users)..where((u) => u.nom.equals(nom))).getSingleOrNull();

  Future<void> upsertUser(User row) => into(users).insertOnConflictUpdate(row);

  // ── Modules ───────────────────────────────────────────────────────────────

  Stream<List<ModuleFlag>> watchModules() =>
      (select(moduleFlags)..orderBy([(m) => OrderingTerm.asc(m.ordre)]))
          .watch();

  Future<List<ModuleFlag>> allModules() =>
      (select(moduleFlags)..orderBy([(m) => OrderingTerm.asc(m.ordre)])).get();

  Future<void> setModuleActif(String code, bool actif) {
    return transaction(() async {
      final existing =
          await (select(moduleFlags)..where((m) => m.code.equals(code)))
              .getSingleOrNull();
      if (existing == null) {
        await into(moduleFlags).insert(
          ModuleFlagsCompanion.insert(code: code, actif: Value(actif)),
        );
      } else {
        await (update(moduleFlags)..where((m) => m.code.equals(code)))
            .write(ModuleFlagsCompanion(actif: Value(actif)));
      }
    });
  }
}
