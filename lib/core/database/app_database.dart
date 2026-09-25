/// Base de données applicative Drift — version de schéma 3.
///
/// La chaîne de migrations 1 → 2 → 3 est implémentée dans [migration] :
/// chaque évolution future du schéma doit ajouter un bloc `onUpgrade`
/// (jamais de modification directe — voir docs/02-donnees-et-migrations.md).
library;

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Users,
  Clients,
  Categories,
  Services,
  Requests,
  QualificationForms,
  QualificationQuestions,
  WorkflowTemplates,
  WorkflowSteps,
  WorkflowInstances,
  WorkflowStepStates,
  BusinessRules,
  RuleExceptions,
  Quotes,
  QuoteItems,
  Invoices,
  InvoiceItems,
  Payments,
  Orders,
  OrderFiles,
  MessageTemplates,
  Reminders,
  Tasks,
  ActivityLog,
  Settings,
  ModuleFlags,
  SyncQueue,
  SyncConflicts,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Migration v1 → v2 : index de performance + table des tâches.
          if (from < 2) {
            await m.createTable(tasks);
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_orders_statut ON orders (statut);');
          }
          // Migration v2 → v3 : index synchronisation + paiement.
          if (from < 3) {
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_sync_queue_statut ON sync_queue (statut);');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_payments_invoice ON payments (invoice_id);');
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Compteur de références : incrémente atomiquement le compteur
  /// {prefix}_{année} et renvoie la séquence suivante.
  Future<int> nextSequence(String prefix, int year) {
    return transaction(() async {
      final key = 'counter_${prefix}_$year';
      final row = await (select(settings)..where((s) => s.cle.equals(key)))
          .getSingleOrNull();
      final current = int.tryParse(row?.valeur ?? '') ?? 0;
      final next = current + 1;
      await into(settings).insertOnConflictUpdate(
        SettingsCompanion.insert(cle: key, valeur: next.toString()),
      );
      return next;
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    // Les fichiers générés (PDF, images) et la base vivent dans le dossier
    // applicatif MSN — tout reste fonctionnel hors connexion.
    final dbFolder = Directory(p.join(dir.path, 'msn_manager'));
    if (!dbFolder.existsSync()) {
      await dbFolder.create(recursive: true);
    }
    final file = File(p.join(dbFolder.path, 'msn_manager.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
