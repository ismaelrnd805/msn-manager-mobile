/// Providers catalogue — services, catégories, sélecteurs partagés.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/database_provider.dart';

final catalogSearchProvider = StateProvider<String>((ref) => '');

/// Liste enrichie (service + catégorie).
final catalogServicesProvider =
    StreamProvider<List<ServiceWithCategoryRow>>((ref) {
  final query = ref.watch(catalogSearchProvider);
  return ref
      .watch(catalogDaoProvider)
      .watchServices(query: query)
      .map((rows) => rows
          .map((r) => ServiceWithCategoryRow(r.service, r.categoryNom))
          .toList());
});

/// Services actifs uniquement (présentation client, sélecteurs).
final catalogServicesForPickProvider = StreamProvider<List<Service>>((ref) {
  return ref.watch(catalogDaoProvider).watchServices(onlyActive: true).map(
      (rows) => rows.map((r) => r.service).toList());
});

final catalogCategoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(catalogDaoProvider).watchCategories();
});

/// Détail d'un service.
final serviceDetailProvider =
    StreamProvider.family<ServiceWithCategoryRow?, String>((ref, id) {
  final dao = ref.watch(catalogDaoProvider);
  return dao.watchService(id).asyncMap((service) async {
    if (service == null) return null;
    final full = await dao.serviceById(id);
    return full == null
        ? null
        : ServiceWithCategoryRow(full.service, full.categoryNom);
  });
});

/// Règles métier d'un service (clé → valeur).
final serviceRulesProvider =
    StreamProvider.family<Map<String, String>, String>((ref, serviceId) {
  final dao = ref.watch(templatesDaoProvider);
  return dao.watchRulesForService(serviceId).map((rows) =>
      {for (final r in rows) r.cle: r.valeur});
});

/// Formulaire de qualification d'un service (chargement ponctuel).
final serviceQualificationFormProvider =
    FutureProvider.family<QualificationForm?, String>((ref, serviceId) async {
  final dao = ref.watch(templatesDaoProvider);
  return dao.formForService(serviceId);
});

class ServiceWithCategoryRow {
  const ServiceWithCategoryRow(this.service, this.categoryNom);

  final Service service;
  final String categoryNom;
}
