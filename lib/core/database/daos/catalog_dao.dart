/// DAO catalogue — catégories, services et tarifs.
library;

import 'package:drift/drift.dart';

import '../app_database.dart';

class ServiceWithCategory {
  const ServiceWithCategory(this.service, this.category);

  final Service service;
  final Category? category;

  String get categoryNom => category?.nom ?? 'Sans catégorie';
}

class CatalogDao extends DatabaseAccessor<AppDatabase> {
  CatalogDao(super.db);

  // Tables exposées via la base attachée (voir docs/01-architecture.md)
  $CategoriesTable get categories => attachedDatabase.categories;
  $ServicesTable get services => attachedDatabase.services;
  $CatalogImagesTable get catalogImages => attachedDatabase.catalogImages;
  $ServiceTranslationsTable get serviceTranslations =>
      attachedDatabase.serviceTranslations;

  // ── Images de catalogue (v4) ───────────────────────────────────────────────

  Stream<List<CatalogImage>> watchCatalogImages({bool onlyActive = false}) =>
      (select(catalogImages)
            ..where((i) =>
                i.deletedAt.isNull() &
                (onlyActive
                    ? i.actif.equals(true)
                    : const CustomExpression<bool>('1 = 1')))
            ..orderBy([(i) => OrderingTerm.asc(i.ordre)]))
          .watch();

  Future<CatalogImage?> catalogImageById(String id) =>
      (select(catalogImages)..where((i) => i.id.equals(id)))
          .getSingleOrNull();

  Future<void> upsertCatalogImage(CatalogImage row) =>
      into(catalogImages).insertOnConflictUpdate(row);

  Future<void> softDeleteCatalogImage(String id) =>
      (update(catalogImages)..where((i) => i.id.equals(id))).write(
        CatalogImagesCompanion(
          deletedAt: Value(DateTime.now()),
          actif: const Value(false),
        ),
      );

  Future<int> countCatalogImages() async {
    final count = countAll();
    final query = selectOnly(catalogImages)
      ..where(catalogImages.deletedAt.isNull());
    query.addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  // ── Traductions de services (v4) ───────────────────────────────────────────

  Stream<List<ServiceTranslation>> watchServiceTranslations(
          String serviceId) =>
      (select(serviceTranslations)
            ..where((t) => t.serviceId.equals(serviceId)))
          .watch();

  Future<ServiceTranslation?> serviceTranslation(
          String serviceId, String langue) =>
      (select(serviceTranslations)
            ..where((t) => t.serviceId.equals(serviceId) &
                t.langue.equals(langue)))
          .getSingleOrNull();

  Future<void> upsertServiceTranslation(ServiceTranslation row) =>
      into(serviceTranslations).insertOnConflictUpdate(row);

  Future<void> deleteServiceTranslation(String id) =>
      (delete(serviceTranslations)..where((t) => t.id.equals(id))).go();


  // ── Catégories ────────────────────────────────────────────────────────────

  Stream<List<Category>> watchCategories() {
    return (select(categories)..orderBy([(c) => OrderingTerm.asc(c.ordre)]))
        .watch();
  }

  Future<void> upsertCategory(Category row) =>
      into(categories).insertOnConflictUpdate(row);

  Future<void> deleteCategory(String id) =>
      (delete(categories)..where((c) => c.id.equals(id))).go();

  // ── Services ──────────────────────────────────────────────────────────────

  JoinedSelectStatement _serviceQuery({bool onlyActive = false, String query = ''}) {
    final q = query.trim().toLowerCase();
    return select(services).join([
      leftOuterJoin(categories, categories.id.equalsExp(services.categoryId)),
    ])
      ..where(services.deletedAt.isNull())
      ..where(onlyActive ? services.actif.equals(true) : const CustomExpression<bool>('1 = 1'))
      ..where(q.isEmpty
          ? const CustomExpression<bool>('1 = 1')
          : services.nom.lower().like('%$q%'))
      ..orderBy([OrderingTerm.asc(services.nom)]);
  }

  Stream<List<ServiceWithCategory>> watchServices({bool onlyActive = false, String query = ''}) {
    return _serviceQuery(onlyActive: onlyActive, query: query).watch().map(
          (rows) => rows
              .map((row) => ServiceWithCategory(
                    row.readTable(services),
                    row.readTable(categories),
                  ))
              .toList(),
        );
  }

  Future<ServiceWithCategory?> serviceById(String id) async {
    final rows = await (select(services).join([
      leftOuterJoin(categories, categories.id.equalsExp(services.categoryId)),
    ])
          ..where(services.id.equals(id)))
        .get();
    if (rows.isEmpty) return null;
    return ServiceWithCategory(
      rows.first.readTable(services),
      rows.first.readTable(categories),
    );
  }

  Stream<Service?> watchService(String id) =>
      (select(services)..where((s) => s.id.equals(id))).watchSingleOrNull();

  Future<void> upsertService(Service row) =>
      into(services).insertOnConflictUpdate(row);

  Future<void> softDeleteService(String id) =>
      (update(services)..where((s) => s.id.equals(id))).write(
        ServicesCompanion(
          deletedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
          actif: const Value(false),
        ),
      );

  Future<void> restoreService(String id) =>
      (update(services)..where((s) => s.id.equals(id))).write(
        const ServicesCompanion(deletedAt: Value(null)),
      );

  Future<List<Service>> activeServices() =>
      (select(services)..where((s) => s.deletedAt.isNull() & s.actif.equals(true)))
          .get();
}
