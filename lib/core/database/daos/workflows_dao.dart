/// DAO workflows — modèles, étapes, instances et états d'étapes.
///
/// Une instance copie les étapes du modèle au moment de la création
/// (table workflow_step_states) : si l'administrateur modifie ensuite le
/// modèle, les commandes en cours conservent leur propre progression.
library;

import 'package:drift/drift.dart';

import '../app_database.dart';

class WorkflowsDao extends DatabaseAccessor<AppDatabase> {
  WorkflowsDao(super.db);

  // Tables exposées via la base attachée (voir docs/01-architecture.md)
  $WorkflowTemplatesTable get workflowTemplates => attachedDatabase.workflowTemplates;
  $WorkflowStepsTable get workflowSteps => attachedDatabase.workflowSteps;
  $WorkflowInstancesTable get workflowInstances => attachedDatabase.workflowInstances;
  $WorkflowStepStatesTable get workflowStepStates => attachedDatabase.workflowStepStates;
  $ProcessStepsTable get processSteps => attachedDatabase.processSteps;

  // ── Processus client (présentation, administrable) ─────────────────────────

  Stream<List<ProcessStep>> watchActiveProcessSteps() =>
      (select(processSteps)
            ..where((s) => s.actif.equals(true))
            ..orderBy([(s) => OrderingTerm.asc(s.ordre)]))
          .watch();

  Stream<List<ProcessStep>> watchAllProcessSteps() =>
      (select(processSteps)
            ..orderBy([(s) => OrderingTerm.asc(s.ordre)]))
          .watch();

  Future<void> upsertProcessStep(ProcessStep row) =>
      into(processSteps).insertOnConflictUpdate(row);

  Future<void> deleteProcessStep(String id) =>
      (delete(processSteps)..where((s) => s.id.equals(id))).go();

  Future<int> countProcessSteps() async {
    final count = countAll();
    final query = selectOnly(processSteps)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }


  // ── Modèles ───────────────────────────────────────────────────────────────

  Stream<List<WorkflowTemplate>> watchTemplates() =>
      (select(workflowTemplates)
            ..where((t) => t.actif.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.nom)]))
          .watch();

  Future<List<WorkflowTemplate>> templatesForService(String? serviceId) =>
      (select(workflowTemplates)
            ..where((t) => t.serviceId.equalsNullable(serviceId))
            ..where((t) => t.actif.equals(true)))
          .get();

  /// Workflow actif d'un service, ou le workflow générique (serviceId null).
  Future<WorkflowTemplate?> templateForService(String? serviceId) async {
    if (serviceId != null) {
      final rows = await (select(workflowTemplates)
            ..where((t) => t.serviceId.equals(serviceId) & t.actif.equals(true)))
          .get();
      if (rows.isNotEmpty) return rows.first;
    }
    final generic = await (select(workflowTemplates)
          ..where((t) => t.serviceId.isNull() & t.actif.equals(true)))
        .get();
    return generic.isEmpty ? null : generic.first;
  }

  Future<List<WorkflowStep>> stepsForTemplate(String workflowId) =>
      (select(workflowSteps)..where((s) => s.workflowId.equals(workflowId))
            ..orderBy([(s) => OrderingTerm.asc(s.ordre)]))
          .get();

  Future<void> upsertTemplate(WorkflowTemplate row) =>
      into(workflowTemplates).insertOnConflictUpdate(row);

  /// Remplace toutes les étapes d'un modèle (édition admin).
  Future<void> replaceSteps(String workflowId, List<WorkflowStep> steps) {
    return transaction(() async {
      await (delete(workflowSteps)..where((s) => s.workflowId.equals(workflowId)))
          .go();
      for (final step in steps) {
        await into(workflowSteps).insert(step);
      }
    });
  }

  // ── Instances ─────────────────────────────────────────────────────────────

  /// Instancie un workflow pour une commande en copiant les étapes.
  Future<String> instantiate({
    required String instanceId,
    required String orderId,
    required String workflowId,
    required List<WorkflowStep> steps,
  }) {
    return transaction(() async {
      await into(workflowInstances).insert(
        WorkflowInstancesCompanion.insert(
          id: instanceId,
          orderId: orderId,
          workflowId: workflowId,
        ),
      );
      for (var i = 0; i < steps.length; i++) {
        await into(workflowStepStates).insert(
          WorkflowStepStatesCompanion.insert(
            id: '${instanceId}_s$i',
            instanceId: instanceId,
            stepId: steps[i].id,
            ordre: i,
            nom: steps[i].nom,
            actionsJson: Value(steps[i].actionsJson),
          ),
        );
      }
      return instanceId;
    });
  }

  Stream<WorkflowInstance?> watchInstanceForOrder(String orderId) =>
      (select(workflowInstances)..where((i) => i.orderId.equals(orderId)))
          .watchSingleOrNull();

  Future<WorkflowInstance?> instanceForOrder(String orderId) =>
      (select(workflowInstances)..where((i) => i.orderId.equals(orderId)))
          .getSingleOrNull();

  Stream<List<WorkflowStepState>> watchStepStates(String instanceId) =>
      (select(workflowStepStates)
            ..where((s) => s.instanceId.equals(instanceId))
            ..orderBy([(s) => OrderingTerm.asc(s.ordre)]))
          .watch();

  Future<List<WorkflowStepState>> stepStates(String instanceId) =>
      (select(workflowStepStates)
            ..where((s) => s.instanceId.equals(instanceId))
            ..orderBy([(s) => OrderingTerm.asc(s.ordre)]))
          .get();

  /// Met à jour les instructions d'une étape (édition admin).
  Future<void> updateStepInstructions(WorkflowStep step) =>
      into(workflowSteps).insertOnConflictUpdate(step);

  /// Termine l'étape donnée et avance le curseur de l'instance.
  Future<void> completeStep({
    required String instanceId,
    required String stepStateId,
    required int newStepIndex,
    String? note,
    String? completedBy,
  }) {
    return transaction(() async {
      await (update(workflowStepStates)
            ..where((s) => s.id.equals(stepStateId)))
          .write(WorkflowStepStatesCompanion(
        statut: const Value('terminee'),
        completedAt: Value(DateTime.now()),
        note: Value(note),
        completedBy: Value(completedBy),
        annuleLe: const Value(null),
        annulePar: const Value(null),
      ));
      final isLast = await (select(workflowStepStates)
            ..where((s) =>
                s.instanceId.equals(instanceId) &
                s.statut.equals('en_attente')))
          .get()
          .then((rows) => rows.isEmpty);
      await (update(workflowInstances)
            ..where((i) => i.id.equals(instanceId)))
          .write(WorkflowInstancesCompanion(
        currentStepIndex: Value(newStepIndex),
        statut: Value(isLast ? 'termine' : 'actif'),
        completedAt: Value(isLast ? DateTime.now() : null),
      ));
    });
  }

  /// Annule la validation d'une étape (retour en arrière) : remet l'étape
  /// en attente, remet les étapes suivantes validées en attente si
  /// nécessaire et recule le curseur de l'instance.
  Future<void> cancelStep({
    required String instanceId,
    required String stepStateId,
    required int stepOrdre,
    String? annulePar,
  }) {
    return transaction(() async {
      // Les étapes suivantes déjà validées sont remises en attente —
      // la progression reste cohérente (une étape en aval ne peut pas
      // rester validée quand une étape en amont est annulée).
      final states = await (select(workflowStepStates)
            ..where((s) =>
                s.instanceId.equals(instanceId) &
                s.ordre.isBiggerOrEqualValue(stepOrdre)))
          .get();
      for (final s in states) {
        await (update(workflowStepStates)
              ..where((w) => w.id.equals(s.id)))
            .write(WorkflowStepStatesCompanion(
          statut: const Value('en_attente'),
          completedAt: const Value(null),
          completedBy: const Value(null),
          annuleLe: Value(DateTime.now()),
          annulePar: Value(annulePar),
        ));
      }
      await (update(workflowInstances)
            ..where((i) => i.id.equals(instanceId)))
          .write(WorkflowInstancesCompanion(
        currentStepIndex: Value(stepOrdre),
        statut: const Value('actif'),
        completedAt: const Value(null),
      ));
    });
  }
}
