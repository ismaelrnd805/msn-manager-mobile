# 06 — Ajouter un module (tutoriel « Statistiques »)

Le système de modules est dans `lib/core/modules/module_registry.dart`. Ajouter un module = 6 touches, sans réécrire quoi que ce soit d'existant. Objectif d'exemple : un module « Statistiques » accessible depuis l'onglet Plus.

## 1. Entrée dans `ModuleCatalog`

Dans `core/modules/module_registry.dart`, ajouter un `ModuleDescriptor` à la liste `all` (après les modules existants, avec les futurs modules) :

```dart
static const List<ModuleDescriptor> all = [
  // … modules existants …
  ModuleDescriptor(
    code: 'statistiques',
    label: 'Statistiques',
    description: 'Chiffre d’affaires, taux de conversion, délais réels par service.',
    core: false,
  ),
];
```

- `code` : identifiant stocké dans la table `module_flags` (unicité).
- `core: true` serait réservé à un module non désactivable ; ici `false`.

## 2. Créer la feature

`lib/features/statistiques/statistiques_providers.dart` — agrégations en Stream (réactives, hors ligne) :

```dart
final chiffreAffairesMensuelProvider = StreamProvider<int>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final debutMois = DateTime(DateTime.now().year, DateTime.now().month);
  return db.customSelect(
    'SELECT COALESCE(SUM(montant), 0) AS total FROM payments '
    'WHERE date_paiement >= ?',
    variables: [Variable(debutMois.toIso8601String())],
    readsFrom: {db.payments},
  ).map((row) => row.data['total'] as int? ?? 0).watchSingle();
});
```

`lib/features/statistiques/statistiques_screen.dart` — écran `ConsumerWidget` standard (Scaffold + `ref.watch(...)`, widgets partagés de `lib/shared/widgets/`).

## 3. Route go_router

Dans `core/router/app_router.dart`, avec les routes support :

```dart
GoRoute(
    path: '/statistiques',
    builder: (_, __) => const StatistiquesScreen()),
```

## 4. Garde par `moduleRegistryProvider`

Deux niveaux, selon la sévérité voulue :

- **Masquage doux (recommandé, comme MoreScreen)** : ne pas afficher l'entrée si le module est désactivé.
- **Blocage explicite** dans l'écran ou une route guard personnalisée :

```dart
class StatistiquesScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registry = ref.watch(moduleRegistryProvider).valueOrNull
        ?? const ModuleRegistry({});
    if (!registry.isActive('statistiques')) {
      return const EmptyState(
        icon: Icons.bar_chart,
        title: 'Module désactivé',
        message: 'Activez-le dans Administration > Modules.',
      );
    }
    // … contenu normal …
  }
}
```

L'état des modules vient de la table `module_flags` (`SystemDao.watchModules()` -> `moduleRegistryProvider`) : l'activation/désactivation est instantanée et persistée via `SystemDao.setModuleActif(code, actif)`.

## 5. Entrée dans `MoreScreen`

Dans `features/more/more_screen.dart`, la liste `entries` (tuple `code, libellé, icône, route`) :

```dart
final entries = <(String, String, IconData, String)>[
  // … entrées existantes …
  ('statistiques', 'Statistiques', Icons.bar_chart, '/statistiques'),
];
```

Rien d'autre : `MoreScreen` filtre déjà `visible` / `disabled` avec `registry.isActive(e.$1)` et propose le raccourci « Administration > Modules » pour les modules désactivés.

## 6. Drapeau en base

Le module est actif/désactivable dès que sa ligne existe. Deux façons :
- Écran **Administration > Modules** (`/settings/modules`, `ModulesScreen`) qui liste `ModuleCatalog.all` avec un switch (insert automatique via `setModuleActif`).
- Pour la valeur par défaut au premier lancement, ajouter `'statistiques': false` (ou `true`) dans la map `modules` de `DemoData.seedIfNeeded` — uniquement pour les nouvelles installations.

## 7. Test

```dart
// test/module_registry_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:msn_manager_mobile/core/modules/module_registry.dart';

class _Flag implements ModuleFlagLike {
  _Flag(this.code, this.actif);
  @override final String code;
  @override final bool actif;
}

void main() {
  test('le module statistiques est reconnu et activable', () {
    expect(ModuleCatalog.byCode('statistiques'), isNotNull);
    final registry = registryFromFlags([_Flag('statistiques', true)]);
    expect(registry.isActive('statistiques'), isTrue);
    expect(registryFromFlags([]).isActive('statistiques'), isFalse);
  });
}
```

## Récapitulatif

| # | Fichier | Modification |
|---|---|---|
| 1 | `core/modules/module_registry.dart` | `ModuleDescriptor(code: 'statistiques', …)` |
| 2 | `features/statistiques/…` | écran + providers |
| 3 | `core/router/app_router.dart` | `GoRoute('/statistiques')` |
| 4 | écran | garde `registry.isActive('statistiques')` |
| 5 | `features/more/more_screen.dart` | entrée dans `entries` |
| 6 | base | flag via `/settings/modules` ou seed |
| 7 | `test/` | test `registryFromFlags` |
