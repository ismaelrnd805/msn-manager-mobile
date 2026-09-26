/// Base de données applicative Drift — version de schéma 4.
///
/// La chaîne de migrations 1 → 2 → 3 → 4 est implémentée dans [migration] :
/// chaque évolution future du schéma doit ajouter un bloc `onUpgrade`
/// (jamais de modification directe — voir docs/02-donnees-et-migrations.md).
library;

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';
import 'converters.dart';
import '../domain/enums.dart';

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
  Conditions,
  DictionaryEntries,
  ServiceTranslations,
  ProcessSteps,
  CatalogImages,
  Settings,
  ModuleFlags,
  SyncQueue,
  SyncConflicts,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

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
          // Migration v3 → v4 : contenus administrables (conditions,
          // dictionnaire FR/MG, traductions, processus, images) +
          // enrichissement étapes / journal / modèles / documents.
          if (from < 4) {
            await m.createTable(conditions);
            await m.createTable(dictionaryEntries);
            await m.createTable(serviceTranslations);
            await m.createTable(processSteps);
            await m.createTable(catalogImages);

            await m.addColumn(services, services.descriptionDetaillee);
            await m.addColumn(services, services.avantages);
            await m.addColumn(services, services.faq);
            await m.addColumn(services, services.icone);
            await m.addColumn(services, services.ordre);

            await m.addColumn(workflowSteps, workflowSteps.description);
            await m.addColumn(workflowSteps, workflowSteps.responsable);
            await m.addColumn(workflowSteps, workflowSteps.fichiersRequis);
            await m.addColumn(workflowSteps, workflowSteps.resultatAttendu);
            await m.addColumn(
                workflowSteps, workflowSteps.conditionsValidation);

            await m.addColumn(workflowStepStates, workflowStepStates.completedBy);
            await m.addColumn(workflowStepStates, workflowStepStates.annuleLe);
            await m.addColumn(workflowStepStates, workflowStepStates.annulePar);

            await m.addColumn(quotes, quotes.conditionsJson);
            await m.addColumn(invoices, invoices.conditionsJson);
            await m.addColumn(messageTemplates, messageTemplates.corpsMg);

            await m.addColumn(activityLog, activityLog.champ);
            await m.addColumn(activityLog, activityLog.ancienneValeur);
            await m.addColumn(activityLog, activityLog.nouvelleValeur);

            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_conditions_actif '
                'ON conditions (actif, ordre);');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_dictionary_fr '
                'ON dictionary_entries (terme_fr);');
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
