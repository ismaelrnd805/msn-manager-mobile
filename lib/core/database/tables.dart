/// Schéma de la base de données locale (Drift / SQLite) — version 3.
///
/// Principes offline-first :
/// - chaque table métier porte des colonnes de synchronisation
///   (lastSyncedAt) et de corbeille (deletedAt — suppression douce) ;
/// - les données de démonstration sont insérées au premier lancement ;
/// - toute évolution du schéma passe par une migration (voir
///   docs/02-donnees-et-migrations.md).
library;

import 'package:drift/drift.dart';

import 'converters.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Utilisateurs & sécurité
// ─────────────────────────────────────────────────────────────────────────────

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get nom => text()();
  TextColumn get pinHash => text()();
  TextColumn get role => text().map(const UserRoleConverter()).withDefault(const Constant('operateur'))();
  BoolColumn get actif => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────────────────────────
// CRM — clients
// ─────────────────────────────────────────────────────────────────────────────

class Clients extends Table {
  TextColumn get id => text()();
  TextColumn get nom => text()();
  TextColumn get telephone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get canalPrefere => text().nullable().map(const CanalConverter())();
  TextColumn get adresse => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────────────────────────
// Catalogue — catégories, services, tarifs
// ─────────────────────────────────────────────────────────────────────────────

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get nom => text()();
  IntColumn get ordre => integer().withDefault(const Constant(0))();
  BoolColumn get actif => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

class Services extends Table {
  TextColumn get id => text()();
  TextColumn get nom => text()();
  TextColumn get description => text().nullable()();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  IntColumn get prixBase => integer().withDefault(const Constant(0))();
  TextColumn get unite => text().withDefault(const Constant('forfait'))();
  IntColumn get delaiJours => integer().nullable()();
  TextColumn get inclus => text().nullable()();
  TextColumn get exclusions => text().nullable()();
  TextColumn get conditions => text().nullable()();
  BoolColumn get actif => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────────────────────────
// Demandes clients
// ─────────────────────────────────────────────────────────────────────────────

@TableIndex(name: 'idx_requests_statut', columns: {#statut})
class Requests extends Table {
  TextColumn get id => text()();
  TextColumn get reference => text().unique()();
  TextColumn get clientId => text().references(Clients, #id)();
  TextColumn get canal => text().map(const CanalConverter())();
  TextColumn get serviceId => text().nullable().references(Services, #id)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get deadlineSouhaitee => dateTime().nullable()();
  IntColumn get budget => integer().nullable()();
  TextColumn get priorite => text().map(const PrioriteConverter()).withDefault(const Constant('normale'))();
  TextColumn get statut => text().map(const RequestStatutConverter()).withDefault(const Constant('nouvelle'))();
  TextColumn get notes => text().nullable()();
  TextColumn get qualificationJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────────────────────────
// Qualification dynamique (formulaires modifiables sans toucher au code)
// ─────────────────────────────────────────────────────────────────────────────

class QualificationForms extends Table {
  TextColumn get id => text()();
  TextColumn get serviceId => text().nullable().references(Services, #id)();
  TextColumn get nom => text()();
  BoolColumn get actif => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

class QualificationQuestions extends Table {
  TextColumn get id => text()();
  TextColumn get formId => text().references(QualificationForms, #id)();
  IntColumn get ordre => integer().withDefault(const Constant(0))();
  TextColumn get label => text()();
  TextColumn get type => text().map(const QuestionTypeConverter()).withDefault(const Constant('texte'))();
  TextColumn get optionsJson => text().nullable()();
  BoolColumn get obligatoire => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────────────────────────
// Workflows
// ─────────────────────────────────────────────────────────────────────────────

class WorkflowTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get serviceId => text().nullable().references(Services, #id)();
  TextColumn get nom => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get actif => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

class WorkflowSteps extends Table {
  TextColumn get id => text()();
  TextColumn get workflowId => text().references(WorkflowTemplates, #id)();
  IntColumn get ordre => integer()();
  TextColumn get nom => text()();
  TextColumn get actionsJson => text().withDefault(const Constant('[]'))();
  @override
  Set<Column> get primaryKey => {id};
}

class WorkflowInstances extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text().references(Orders, #id)();
  TextColumn get workflowId => text().references(WorkflowTemplates, #id)();
  TextColumn get statut => text().withDefault(const Constant('actif'))();
  IntColumn get currentStepIndex => integer().withDefault(const Constant(0))();
  DateTimeColumn get startedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class WorkflowStepStates extends Table {
  TextColumn get id => text()();
  TextColumn get instanceId => text().references(WorkflowInstances, #id)();
  TextColumn get stepId => text().references(WorkflowSteps, #id)();
  IntColumn get ordre => integer()();
  TextColumn get nom => text()();
  TextColumn get actionsJson => text().withDefault(const Constant('[]'))();
  TextColumn get statut => text().withDefault(const Constant('en_attente'))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get note => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────────────────────────
// Règles métier & exceptions
// ─────────────────────────────────────────────────────────────────────────────

class BusinessRules extends Table {
  TextColumn get id => text()();
  TextColumn get serviceId => text().nullable().references(Services, #id)();
  TextColumn get cle => text()();
  TextColumn get valeur => text()();
  TextColumn get description => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<Set<Column>> get uniqueKeys => [{serviceId, cle}];
}

class RuleExceptions extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text().nullable().references(Orders, #id)();
  TextColumn get ruleKey => text()();
  TextColumn get raison => text()();
  TextColumn get userName => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────────────────────────
// Documents commerciaux — devis
// ─────────────────────────────────────────────────────────────────────────────

class Quotes extends Table {
  TextColumn get id => text()();
  TextColumn get reference => text().unique()();
  TextColumn get clientId => text().references(Clients, #id)();
  TextColumn get requestId => text().nullable().references(Requests, #id)();
  TextColumn get statut => text().map(const QuoteStatutConverter()).withDefault(const Constant('brouillon'))();
  IntColumn get reduction => integer().withDefault(const Constant(0))();
  IntColumn get acompte => integer().withDefault(const Constant(0))();
  IntColumn get delaiJours => integer().nullable()();
  TextColumn get conditions => text().nullable()();
  IntColumn get validiteJours => integer().withDefault(const Constant(15))();
  IntColumn get montantTotal => integer().withDefault(const Constant(0))();
  DateTimeColumn get dateEmission => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class QuoteItems extends Table {
  TextColumn get id => text()();
  TextColumn get quoteId => text().references(Quotes, #id)();
  TextColumn get serviceId => text().nullable().references(Services, #id)();
  TextColumn get designation => text()();
  RealColumn get quantite => real().withDefault(const Constant(1.0))();
  IntColumn get prixUnitaire => integer().withDefault(const Constant(0))();
  IntColumn get ordre => integer().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────────────────────────
// Documents commerciaux — factures
// ─────────────────────────────────────────────────────────────────────────────

class Invoices extends Table {
  TextColumn get id => text()();
  TextColumn get reference => text().unique()();
  TextColumn get clientId => text().references(Clients, #id)();
  TextColumn get orderId => text().nullable().references(Orders, #id)();
  TextColumn get quoteId => text().nullable().references(Quotes, #id)();
  TextColumn get statut => text().map(const InvoiceStatutConverter()).withDefault(const Constant('brouillon'))();
  IntColumn get reduction => integer().withDefault(const Constant(0))();
  IntColumn get montantTotal => integer().withDefault(const Constant(0))();
  TextColumn get conditions => text().nullable()();
  DateTimeColumn get dateEmission => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get dateEcheance => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class InvoiceItems extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceId => text().references(Invoices, #id)();
  TextColumn get serviceId => text().nullable().references(Services, #id)();
  TextColumn get designation => text()();
  RealColumn get quantite => real().withDefault(const Constant(1.0))();
  IntColumn get prixUnitaire => integer().withDefault(const Constant(0))();
  IntColumn get ordre => integer().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────────────────────────
// Paiements
// ─────────────────────────────────────────────────────────────────────────────

@TableIndex(name: 'idx_payments_invoice', columns: {#invoiceId})
class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get reference => text().unique()();
  TextColumn get clientId => text().nullable().references(Clients, #id)();
  TextColumn get invoiceId => text().nullable().references(Invoices, #id)();
  TextColumn get orderId => text().nullable().references(Orders, #id)();
  IntColumn get montant => integer()();
  TextColumn get methode => text().map(const PaymentMethodeConverter())();
  TextColumn get referenceExterne => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get datePaiement => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────────────────────────
// Commandes
// ─────────────────────────────────────────────────────────────────────────────

@TableIndex(name: 'idx_orders_statut', columns: {#statut})
class Orders extends Table {
  TextColumn get id => text()();
  TextColumn get reference => text().unique()();
  TextColumn get clientId => text().references(Clients, #id)();
  TextColumn get serviceId => text().nullable().references(Services, #id)();
  TextColumn get requestId => text().nullable().references(Requests, #id)();
  TextColumn get quoteId => text().nullable().references(Quotes, #id)();
  TextColumn get titre => text()();
  TextColumn get statut => text().map(const OrderStatutConverter()).withDefault(const Constant('enCours'))();
  DateTimeColumn get deadline => dateTime().nullable()();
  IntColumn get montantTotal => integer().withDefault(const Constant(0))();
  IntColumn get acompteRequis => integer().withDefault(const Constant(0))();
  BoolColumn get briefComplet => boolean().withDefault(const Constant(false))();
  BoolColumn get conditionsAcceptees => boolean().withDefault(const Constant(false))();
  BoolColumn get pretPourProduction => boolean().withDefault(const Constant(false))();
  BoolColumn get transferePc => boolean().withDefault(const Constant(false))();
  DateTimeColumn get transfereLe => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class OrderFiles extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text().nullable().references(Orders, #id)();
  TextColumn get requestId => text().nullable().references(Requests, #id)();
  TextColumn get dossier => text().map(const DossierFichierConverter()).withDefault(const Constant('documents'))();
  TextColumn get nom => text()();
  TextColumn get cheminLocal => text().nullable()();
  IntColumn get taille => integer().nullable()();
  TextColumn get mime => text().nullable()();
  TextColumn get origine => text().withDefault(const Constant('mobile'))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────────────────────────
// Communication — modèles de messages
// ─────────────────────────────────────────────────────────────────────────────

class MessageTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get titre => text()();
  TextColumn get categorie => text().map(const TemplateCategorieConverter())();
  TextColumn get corps => text()();
  BoolColumn get actif => boolean().withDefault(const Constant(true))();
  IntColumn get ordre => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────────────────────────
// Rappels & tâches
// ─────────────────────────────────────────────────────────────────────────────

class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get titre => text()();
  TextColumn get description => text().nullable()();
  TextColumn get type => text().map(const ReminderTypeConverter())();
  TextColumn get cibleType => text().nullable()();
  TextColumn get cibleId => text().nullable()();
  DateTimeColumn get dateRappel => dateTime()();
  BoolColumn get termine => boolean().withDefault(const Constant(false))();
  BoolColumn get notifie => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get titre => text()();
  TextColumn get description => text().nullable()();
  TextColumn get priorite => text().map(const PrioriteConverter()).withDefault(const Constant('normale'))();
  DateTimeColumn get echeance => dateTime().nullable()();
  TextColumn get statut => text().map(const TaskStatutConverter()).withDefault(const Constant('aFaire'))();
  TextColumn get cibleType => text().nullable()();
  TextColumn get cibleId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────────────────────────
// Journal d'activité
// ─────────────────────────────────────────────────────────────────────────────

class ActivityLog extends Table {
  TextColumn get id => text()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  TextColumn get userName => text()();
  TextColumn get action => text().map(const ActivityActionConverter())();
  TextColumn get entite => text()();
  TextColumn get entityId => text().nullable()();
  TextColumn get details => text()();
  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────────────────────────────────────
// Paramètres, modules, synchronisation
// ─────────────────────────────────────────────────────────────────────────────

class Settings extends Table {
  TextColumn get cle => text()();
  TextColumn get valeur => text()();
  @override
  Set<Column> get primaryKey => {cle};
}

class ModuleFlags extends Table {
  TextColumn get code => text()();
  BoolColumn get actif => boolean().withDefault(const Constant(true))();
  IntColumn get ordre => integer().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {code};
}

@TableIndex(name: 'idx_sync_queue_statut', columns: {#statut})
class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get entite => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text().map(const SyncOperationConverter())();
  TextColumn get payload => text()();
  TextColumn get statut => text().map(const SyncQueueStatutConverter()).withDefault(const Constant('enAttente'))();
  IntColumn get tentatives => integer().withDefault(const Constant(0))();
  TextColumn get derniereErreur => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  @override
  Set<Column> get primaryKey => {id};
}

class SyncConflicts extends Table {
  TextColumn get id => text()();
  TextColumn get entite => text()();
  TextColumn get entityId => text()();
  TextColumn get localPayload => text()();
  TextColumn get remotePayload => text()();
  TextColumn get statut => text().withDefault(const Constant('ouvert'))();
  DateTimeColumn get detecteLe => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get resoluLe => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}
