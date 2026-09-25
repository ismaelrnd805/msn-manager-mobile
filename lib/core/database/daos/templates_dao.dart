/// DAO modèles de communication, qualification, règles métier.
library;

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

class TemplatesDao extends DatabaseAccessor<AppDatabase> {
  TemplatesDao(super.db);

  // ── Modèles de messages ───────────────────────────────────────────────────

  Stream<List<MessageTemplate>> watchMessageTemplates({
    TemplateCategorie? categorie,
  }) {
    return (select(messageTemplates)
          ..where((t) => t.actif.equals(true))
          ..where(categorie == null
              ? const CustomExpression<bool>('1 = 1')
              : t.categorie.equals(categorie.name))
          ..orderBy([(t) => OrderingTerm.asc(t.ordre)]))
        .watch();
  }

  Future<MessageTemplate?> messageTemplateByCode(String code) =>
      (select(messageTemplates)..where((t) => t.code.equals(code)))
          .getSingleOrNull();

  Future<void> upsertMessageTemplate(MessageTemplate row) =>
      into(messageTemplates).insertOnConflictUpdate(row);

  Future<List<MessageTemplate>> allMessageTemplates() =>
      (select(messageTemplates)..orderBy([(t) => OrderingTerm.asc(t.ordre)]))
          .get();

  // ── Formulaires de qualification ──────────────────────────────────────────

  Future<QualificationForm?> formForService(String serviceId) {
    return (select(qualificationForms)
          ..where((f) => f.serviceId.equals(serviceId) & f.actif.equals(true)))
        .getSingleOrNull();
  }

  Future<void> upsertForm(QualificationForm row) =>
      into(qualificationForms).insertOnConflictUpdate(row);

  Stream<List<QualificationQuestion>> watchQuestions(String formId) =>
      (select(qualificationQuestions)
            ..where((q) => q.formId.equals(formId))
            ..orderBy([(q) => OrderingTerm.asc(q.ordre)]))
          .watch();

  Future<List<QualificationQuestion>> questions(String formId) =>
      (select(qualificationQuestions)
            ..where((q) => q.formId.equals(formId))
            ..orderBy([(q) => OrderingTerm.asc(q.ordre)]))
          .get();

  Future<void> upsertQuestion(QualificationQuestion row) =>
      into(qualificationQuestions).insertOnConflictUpdate(row);

  Future<void> deleteQuestion(String id) =>
      (delete(qualificationQuestions)..where((q) => q.id.equals(id))).go();

  // ── Règles métier ─────────────────────────────────────────────────────────

  Future<List<BusinessRule>> rulesForService(String? serviceId) =>
      (select(businessRules)..where((r) => r.serviceId.equalsNullable(serviceId)))
          .get();

  Stream<List<BusinessRule>> watchRulesForService(String serviceId) =>
      (select(businessRules)..where((r) => r.serviceId.equals(serviceId)))
          .watch();

  Future<void> upsertRule(BusinessRule row) =>
      into(businessRules).insertOnConflictUpdate(row);

  // ── Exceptions autorisées ─────────────────────────────────────────────────

  Future<void> insertRuleException(RuleException row) =>
      into(ruleExceptions).insert(row);

  Stream<List<RuleException>> watchExceptionsForOrder(String orderId) =>
      (select(ruleExceptions)..where((e) => e.orderId.equals(orderId))
            ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]))
          .watch();
}
