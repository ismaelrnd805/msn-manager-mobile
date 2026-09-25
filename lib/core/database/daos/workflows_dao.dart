/// DAO workflows — modèles, étapes, instances et états d'étapes.
///
/// Une instance copie les étapes du modèle au moment de la création
/// (table workflow_step_states) : si l'administrateur modifie ensuite le
/// modèle, les commandes en cours conservent leur propre progression.
library;

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

class WorkflowsDao extends DatabaseAccessor<AppDatabase> {
  WorkflowsDao(super.db);

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

  /// Termine l'étape donnée et avance le curseur de l'instance.
  Future<void> completeStep({
    required String instanceId,
    required String stepStateId,
    required int newStepIndex,
    String? note,
  }) {
    return transaction(() async {
      await (update(workflowStepStates)
            ..where((s) => s.id.equals(stepStateId)))
          .write(WorkflowStepStatesCompanion(
        statut: const Value('terminee'),
        completedAt: Value(DateTime.now()),
        note: Value(note),
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
}
