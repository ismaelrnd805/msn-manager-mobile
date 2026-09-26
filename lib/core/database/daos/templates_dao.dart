/// DAO modèles de communication, qualification, règles métier.
library;

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../../domain/enums.dart';

class TemplatesDao extends DatabaseAccessor<AppDatabase> {
  TemplatesDao(super.db);

  // Tables exposées via la base attachée (voir docs/01-architecture.md)
  $QualificationFormsTable get qualificationForms => attachedDatabase.qualificationForms;
  $QualificationQuestionsTable get qualificationQuestions => attachedDatabase.qualificationQuestions;
  $BusinessRulesTable get businessRules => attachedDatabase.businessRules;
  $RuleExceptionsTable get ruleExceptions => attachedDatabase.ruleExceptions;
  $MessageTemplatesTable get messageTemplates => attachedDatabase.messageTemplates;
  $ConditionsTable get conditions => attachedDatabase.conditions;
  $DictionaryEntriesTable get dictionaryEntries => attachedDatabase.dictionaryEntries;

  // ── Conditions contractuelles (bibliothèque administrable) ───────────────

  Stream<List<Condition>> watchActiveConditions({String categorie = 'devis'}) =>
      (select(conditions)
            ..where((c) => c.actif.equals(true) &
                c.deletedAt.isNull() &
                c.categorie.equals(categorie))
            ..orderBy([(c) => OrderingTerm.asc(c.ordre)]))
          .watch();

  Stream<List<Condition>> watchAllConditions() =>
      (select(conditions)
            ..where((c) => c.deletedAt.isNull())
            ..orderBy([(c) => OrderingTerm.asc(c.ordre)]))
          .watch();

  Future<List<Condition>> allActiveConditions() =>
      (select(conditions)
            ..where((c) => c.actif.equals(true) & c.deletedAt.isNull())
            ..orderBy([(c) => OrderingTerm.asc(c.ordre)]))
          .get();

  Future<Condition?> conditionById(String id) =>
      (select(conditions)..where((c) => c.id.equals(id))).getSingleOrNull();

  /// Construit le texte consolidé des conditions d'un document :
  /// « Titre : contenu » pour chaque condition cochée + conditions libres.
  /// Utilisé par les formulaires devis/facture — le PDF n'affiche que ce
  /// texte, jamais les cases.
  String activeConditionsText(Set<String> ids, String extraText) =>
      _conditionsTextSync(ids, extraText, []);

  /// Variante pré-chargée (évite une lecture base quand la liste est
  /// déjà disponible dans l'UI).
  String conditionsTextFrom(
          List<Condition> all, Set<String> ids, String extraText) =>
      _conditionsTextSync(ids, extraText, all);

  String _conditionsTextSync(
      Set<String> ids, String extraText, List<Condition> preloaded) {
    final lignes = <String>[];
    if (ids.isNotEmpty) {
      final selected = preloaded.where((c) => ids.contains(c.id)).toList();
      selected.sort((a, b) => a.ordre.compareTo(b.ordre));
      for (final c in selected) {
        lignes.add('${c.titre} : ${c.contenu}');
      }
    }
    if (extraText.trim().isNotEmpty) {
      lignes.addAll(extraText
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty));
    }
    return lignes.isEmpty ? '' : lignes.join('\n');
  }

  Future<void> upsertCondition(Condition row) =>
      into(conditions).insertOnConflictUpdate(row);

  Future<int> countConditions() async {
    final count = countAll();
    final query = selectOnly(conditions)
      ..where(conditions.deletedAt.isNull());
    query.addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// Suppression douce : la condition disparaît des listes mais reste
  /// référençable par les documents existants.
  Future<void> softDeleteCondition(String id) =>
      (update(conditions)..where((c) => c.id.equals(id))).write(
        ConditionsCompanion(deletedAt: Value(DateTime.now()), actif: const Value(false)),
      );

  // ── Dictionnaire français → malagasy ─────────────────────────────────────

  Stream<List<DictionaryEntry>> watchDictionary({String? recherche}) =>
      (select(dictionaryEntries)
            ..where((d) => recherche == null || recherche.isEmpty
                ? const CustomExpression<bool>('1 = 1')
                : d.termeFr.lower().like('%${recherche.toLowerCase()}%') |
                    d.traductionMg.lower().like('%${recherche.toLowerCase()}%'))
            ..orderBy([(d) => OrderingTerm.asc(d.termeFr)]))
          .watch();

  Future<List<DictionaryEntry>> activeDictionary() =>
      (select(dictionaryEntries)..where((d) => d.actif.equals(true)))
          .get();

  Future<void> upsertDictionaryEntry(DictionaryEntry row) =>
      into(dictionaryEntries).insertOnConflictUpdate(row);

  Future<void> deleteDictionaryEntry(String id) =>
      (delete(dictionaryEntries)..where((d) => d.id.equals(id))).go();

  Future<int> countDictionary() async {
    final count = countAll();
    final query = selectOnly(dictionaryEntries)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }


  // ── Modèles de messages ───────────────────────────────────────────────────

  Stream<List<MessageTemplate>> watchMessageTemplates({
    TemplateCategorie? categorie,
  }) {
    return (select(messageTemplates)
          ..where((t) => t.actif.equals(true))
          ..where((t) => categorie == null
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
