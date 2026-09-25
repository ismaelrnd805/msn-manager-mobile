/// Registre des modules — système d'activation/désactivation des
/// fonctionnalités (section 7 du cahier des charges).
///
/// Ajouter un nouveau module = ajouter une entrée ici + un écran gardé
/// par [ModuleGuard]. Aucune réécriture nécessaire (voir
/// docs/06-ajouter-module.md).
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/daos/system_dao.dart';
import '../providers/database_provider.dart';

class ModuleDescriptor {
  const ModuleDescriptor({
    required this.code,
    required this.label,
    required this.description,
    this.core = true,
  });

  final String code;
  final String label;
  final String description;

  /// Les modules cœur ne devraient pas être désactivés en production.
  final bool core;
}

class ModuleCatalog {
  ModuleCatalog._();

  static const List<ModuleDescriptor> all = [
    ModuleDescriptor(code: 'clients', label: 'Clients', description: 'Fiches clients, historique, réutilisation pour nouvelles commandes.'),
    ModuleDescriptor(code: 'requests', label: 'Demandes', description: 'Réception et qualification des demandes clients.'),
    ModuleDescriptor(code: 'orders', label: 'Commandes', description: 'Suivi des commandes et workflows de production.'),
    ModuleDescriptor(code: 'quotes', label: 'Devis', description: 'Génération et suivi des devis.'),
    ModuleDescriptor(code: 'invoices', label: 'Factures', description: 'Facturation depuis les commandes/devis.'),
    ModuleDescriptor(code: 'payments', label: 'Paiements', description: 'Acomptes et soldes, toutes méthodes locales.'),
    ModuleDescriptor(code: 'catalog', label: 'Catalogue', description: 'Services, tarifs et catégories présentables au client.'),
    ModuleDescriptor(code: 'communication', label: 'Communication', description: 'Modèles de messages et compositeur.'),
    ModuleDescriptor(code: 'documents', label: 'Documents', description: 'Génération de PDF et visuels prêts à partager.'),
    ModuleDescriptor(code: 'workflows', label: 'Workflows', description: 'Moteur d’étapes et actions prêtes.'),
    ModuleDescriptor(code: 'tasks', label: 'Tâches & rappels', description: 'Deadlines, relances, validations.'),
    ModuleDescriptor(code: 'files', label: 'Fichiers', description: 'Fichiers clients par commande (SOURCE, TRAVAIL…).'),
    ModuleDescriptor(code: 'sync', label: 'Synchronisation', description: 'Transfert local → serveur / serveur → local.'),
    ModuleDescriptor(code: 'admin', label: 'Administration', description: 'Paramètres, modules, utilisateurs, journal.'),
    // Modules futurs — le code est déjà prêt à les recevoir :
    ModuleDescriptor(code: 'crm_avance', label: 'CRM avancé', description: 'Segmentation, campagnes, statistiques clients (à venir).', core: false),
    ModuleDescriptor(code: 'comptabilite_avance', label: 'Comptabilité avancée', description: 'Grand livre, TVA, exports comptables (à venir).', core: false),
    ModuleDescriptor(code: 'module_avance', label: 'Module avancé', description: 'Fonctionnalités métier étendues futures.', core: false),
  ];

  static ModuleDescriptor? byCode(String code) {
    for (final m in all) {
      if (m.code == code) return m;
    }
    return null;
  }
}

/// État des modules actifs (chargé depuis la base).
class ModuleRegistry {
  const ModuleRegistry(this.activeCodes);

  final Set<String> activeCodes;

  bool isActive(String code) => activeCodes.contains(code);
}

/// Stream des modules actifs — réactif : désactiver un module met à jour
/// instantanément l'interface.
final moduleRegistryProvider = StreamProvider<ModuleRegistry>((ref) {
  final dao = ref.watch(systemDaoProvider);
  return dao.watchModules().map(
        (flags) => ModuleRegistry(
          flags.where((f) => f.actif).map((f) => f.code).toSet(),
        ),
      );
});

/// Helper synchrone pour les tests et la logique hors UI.
@visibleForTesting
ModuleRegistry registryFromFlags(List<ModuleFlagLike> flags) =>
    ModuleRegistry(flags.where((f) => f.actif).map((f) => f.code).toSet());

/// Interface minimale pour éviter une dépendance directe au code généré
/// dans les tests.
abstract class ModuleFlagLike {
  String get code;
  bool get actif;
}
