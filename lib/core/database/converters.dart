/// Convertisseurs Drift : persistance des énumérations sous forme de texte
/// (lisible dans SQLite, robuste face aux ajouts futurs de valeurs).
library;

import 'package:drift/drift.dart';

import '../domain/enums.dart';

class CanalConverter extends TypeConverter<Canal, String> {
  const CanalConverter();
  @override
  Canal fromSql(String fromDb) => Canal.values.byName(fromDb);
  @override
  String toSql(Canal value) => value.name;
}

class PrioriteConverter extends TypeConverter<Priorite, String> {
  const PrioriteConverter();
  @override
  Priorite fromSql(String fromDb) => Priorite.values.byName(fromDb);
  @override
  String toSql(Priorite value) => value.name;
}

class RequestStatutConverter extends TypeConverter<RequestStatut, String> {
  const RequestStatutConverter();
  @override
  RequestStatut fromSql(String fromDb) => RequestStatut.values.byName(fromDb);
  @override
  String toSql(RequestStatut value) => value.name;
}

class QuoteStatutConverter extends TypeConverter<QuoteStatut, String> {
  const QuoteStatutConverter();
  @override
  QuoteStatut fromSql(String fromDb) => QuoteStatut.values.byName(fromDb);
  @override
  String toSql(QuoteStatut value) => value.name;
}

class InvoiceStatutConverter extends TypeConverter<InvoiceStatut, String> {
  const InvoiceStatutConverter();
  @override
  InvoiceStatut fromSql(String fromDb) => InvoiceStatut.values.byName(fromDb);
  @override
  String toSql(InvoiceStatut value) => value.name;
}

class OrderStatutConverter extends TypeConverter<OrderStatut, String> {
  const OrderStatutConverter();
  @override
  OrderStatut fromSql(String fromDb) => OrderStatut.values.byName(fromDb);
  @override
  String toSql(OrderStatut value) => value.name;
}

class PaymentMethodeConverter extends TypeConverter<PaymentMethode, String> {
  const PaymentMethodeConverter();
  @override
  PaymentMethode fromSql(String fromDb) => PaymentMethode.values.byName(fromDb);
  @override
  String toSql(PaymentMethode value) => value.name;
}

class TemplateCategorieConverter
    extends TypeConverter<TemplateCategorie, String> {
  const TemplateCategorieConverter();
  @override
  TemplateCategorie fromSql(String fromDb) =>
      TemplateCategorie.values.byName(fromDb);
  @override
  String toSql(TemplateCategorie value) => value.name;
}

class QuestionTypeConverter extends TypeConverter<QuestionType, String> {
  const QuestionTypeConverter();
  @override
  QuestionType fromSql(String fromDb) => QuestionType.values.byName(fromDb);
  @override
  String toSql(QuestionType value) => value.name;
}

class TaskStatutConverter extends TypeConverter<TaskStatut, String> {
  const TaskStatutConverter();
  @override
  TaskStatut fromSql(String fromDb) => TaskStatut.values.byName(fromDb);
  @override
  String toSql(TaskStatut value) => value.name;
}

class ReminderTypeConverter extends TypeConverter<ReminderType, String> {
  const ReminderTypeConverter();
  @override
  ReminderType fromSql(String fromDb) => ReminderType.values.byName(fromDb);
  @override
  String toSql(ReminderType value) => value.name;
}

class UserRoleConverter extends TypeConverter<UserRole, String> {
  const UserRoleConverter();
  @override
  UserRole fromSql(String fromDb) => UserRole.values.byName(fromDb);
  @override
  String toSql(UserRole value) => value.name;
}

class DossierFichierConverter extends TypeConverter<DossierFichier, String> {
  const DossierFichierConverter();
  @override
  DossierFichier fromSql(String fromDb) => DossierFichier.values.byName(fromDb);
  @override
  String toSql(DossierFichier value) => value.name;
}

class ActivityActionConverter extends TypeConverter<ActivityAction, String> {
  const ActivityActionConverter();
  @override
  ActivityAction fromSql(String fromDb) => ActivityAction.values.byName(fromDb);
  @override
  String toSql(ActivityAction value) => value.name;
}

class SyncOperationConverter extends TypeConverter<SyncOperation, String> {
  const SyncOperationConverter();
  @override
  SyncOperation fromSql(String fromDb) => SyncOperation.values.byName(fromDb);
  @override
  String toSql(SyncOperation value) => value.name;
}

class SyncQueueStatutConverter extends TypeConverter<SyncQueueStatut, String> {
  const SyncQueueStatutConverter();
  @override
  SyncQueueStatut fromSql(String fromDb) =>
      SyncQueueStatut.values.byName(fromDb);
  @override
  String toSql(SyncQueueStatut value) => value.name;
}
