// Tables Drift — miroir fidèle du schéma SQLite de la spécification MSN Manager V1 §5.
// Montants : entiers MGA. Quantités : TEXT décimal exact (jamais de flottant).
// Les contraintes CHECK du schéma de référence sont appliquées via customConstraints.
import 'package:drift/drift.dart';

/// Contraintes CHECK partagées (spécification §5).
class Checks {
  static const clients = [
    "CHECK (type_client IN ('particulier','entreprise'))",
    'CHECK (actif IN (0,1))',
    'CHECK (version >= 1)',
  ];
  static const contacts = [
    "CHECK (canal_prefere IS NULL OR canal_prefere IN ('messenger','whatsapp','email','telephone','autre'))",
    'CHECK (principal IN (0,1))',
  ];
  static const tarifs = [
    'CHECK (prix_unitaire >= 0)',
    "CHECK (devise = 'MGA')",
    'CHECK (date_fin_validite IS NULL OR date_fin_validite >= date_debut_validite)',
  ];
  static const demandes = [
    "CHECK (canal_origine IN ('messenger','facebook','whatsapp','email','telephone','presentiel','autre'))",
    "CHECK (statut IN ('a_qualifier','offre_presentee','en_attente_client','devis_a_preparer','gagnee','perdue'))",
    'CHECK (budget_indicatif IS NULL OR budget_indicatif >= 0)',
    "CHECK (devise_budget = 'MGA')",
  ];
  static const demandePrestations = [
    'CHECK (quantite > 0)',
    'CHECK (prix_indicatif_unitaire IS NULL OR prix_indicatif_unitaire >= 0)',
    "CHECK (devise = 'MGA')",
  ];
  static const commandes = [
    "CHECK (statut IN ('en_preparation','en_attente_validation','validee','en_production','en_correction','livree','annulee'))",
  ];
  static const lignes = [
    'CHECK (quantite > 0)',
    'CHECK (prix_unitaire >= 0)',
  ];
  static const lignesAvecDevise = [
    'CHECK (quantite > 0)',
    'CHECK (prix_unitaire >= 0)',
    "CHECK (devise = 'MGA')",
  ];
  static const projets = [
    "CHECK (statut IN ('en_preparation','en_cours','en_correction','termine','annule'))",
  ];
  static const cahiersCharges = [
    'CHECK (version_document >= 1)',
    "CHECK (statut IN ('brouillon','a_valider','valide','remplace'))",
  ];
  static const taches = [
    "CHECK (statut IN ('a_faire','en_cours','bloquee','terminee','annulee'))",
    "CHECK (priorite IN ('basse','normale','haute','urgente'))",
  ];
  static const modelesMessages = [
    "CHECK (canal IN ('messenger','whatsapp','email','telephone','autre'))",
  ];
  static const echanges = [
    "CHECK (canal IN ('messenger','facebook','whatsapp','email','telephone','presentiel','autre'))",
    "CHECK (direction IN ('entrant','sortant','interne'))",
    "CHECK (statut_envoi IN ('brouillon','prete','copiee','envoi_manuel_confirme','envoi_integration_confirme','echec'))",
  ];
  static const devis = [
    'CHECK (revision >= 1)',
    "CHECK (statut IN ('brouillon','presente','modification_demandee','accepte','refuse','expire','remplace'))",
    'CHECK (total_ht >= 0)',
    "CHECK (devise = 'MGA')",
  ];
  static const factures = [
    "CHECK (statut IN ('brouillon','emise','partiellement_payee','payee','annulee'))",
    'CHECK (total >= 0)',
    "CHECK (devise = 'MGA')",
  ];
  static const paiements = [
    'CHECK (montant > 0)',
    "CHECK (moyen IN ('especes','mobile_money','virement','autre'))",
    "CHECK (statut IN ('en_attente','confirme','annule'))",
  ];
  static const depenses = [
    'CHECK (montant > 0)',
    "CHECK (moyen IN ('especes','mobile_money','virement','autre'))",
  ];
  static const piecesJointes = [
    "CHECK (statut_transfert IN ('local','a_transferer','transfert_en_cours','synchronise','echec'))",
    'CHECK (client_id IS NOT NULL OR demande_id IS NOT NULL OR commande_id IS NOT NULL OR projet_id IS NOT NULL)',
    'CHECK (taille_octets >= 0)',
  ];
  static const publicationsFacebook = [
    "CHECK (statut IN ('planifie','prete','publie_manuellement','annule'))",
  ];
  static const syncOutbox = [
    "CHECK (operation IN ('upsert','delete'))",
    "CHECK (statut IN ('pending','in_flight','synced','conflict','failed'))",
    'CHECK (tentatives >= 0)',
  ];
  static const syncConflicts = [
    "CHECK (statut IN ('a_resoudre','resolu_local','resolu_serveur','fusionne'))",
  ];
}

mixin CheckConstraints on Table {
  @override
  bool get isStrict => false;

  List<String> checksOf(List<String> checks) => checks;
}

class Clients extends Table {
  @override
  List<Set<Column>> get uniqueKeys => const [];

  TextColumn get id => text()();
  TextColumn get typeClient => text()();
  TextColumn get nomAffiche => text()();
  TextColumn get nomLegal => text().nullable()();
  TextColumn get telephonePrincipal => text().nullable()();
  TextColumn get emailPrincipal => text().nullable()();
  TextColumn get adresse => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get actif => boolean().withDefault(const Constant(true))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deletedAt => text().nullable()();



  @override
  List<String> get customConstraints => const [
        "CHECK (type_client IN ('particulier','entreprise'))",
        'CHECK (actif IN (0,1))',
        'CHECK (version >= 1)',
      ];

  @override
  Set<Column> get primaryKey => {id};

}

class Contacts extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text()();
  TextColumn get nom => text()();
  TextColumn get role => text().nullable()();
  TextColumn get telephone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get canalPrefere => text().nullable()();
  BoolColumn get principal => boolean().withDefault(const Constant(false))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deletedAt => text().nullable()();



  @override
  List<String> get customConstraints => const [
        "CHECK (canal_prefere IS NULL OR canal_prefere IN ('messenger','whatsapp','email','telephone','autre'))",
        'CHECK (principal IN (0,1))',
        'FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE RESTRICT',
      ];

  @override
  Set<Column> get primaryKey => {id};

}

class Services extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get nom => text()();
  TextColumn get description => text().nullable()();
  TextColumn get categorie => text()();
  TextColumn get uniteTarifaire => text()();
  BoolColumn get actif => boolean().withDefault(const Constant(true))();
  BoolColumn get necessiteCahierCharges =>
      boolean().withDefault(const Constant(false))();
  TextColumn get questionsQualificationJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deletedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Tarifs extends Table {
  TextColumn get id => text()();
  TextColumn get serviceId => text()();
  IntColumn get prixUnitaire => integer()();
  TextColumn get devise => text().withDefault(const Constant('MGA'))();
  TextColumn get dateDebutValidite => text()();
  TextColumn get dateFinValidite => text().nullable()();
  BoolColumn get actif => boolean().withDefault(const Constant(true))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deletedAt => text().nullable()();



  @override
  List<String> get customConstraints => const [
        'CHECK (prix_unitaire >= 0)',
        "CHECK (devise = 'MGA')",
        'CHECK (date_fin_validite IS NULL OR date_fin_validite >= date_debut_validite)',
        'FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE RESTRICT',
      ];

  @override
  Set<Column> get primaryKey => {id};

}

class Demandes extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text()();
  TextColumn get contactId => text().nullable()();
  TextColumn get canalOrigine => text()();
  TextColumn get messageInitial => text()();
  TextColumn get besoinResume => text().nullable()();
  TextColumn get statut => text().withDefault(const Constant('a_qualifier'))();
  TextColumn get dateLimiteSouhaitee => text().nullable()();
  IntColumn get budgetIndicatif => integer().nullable()();
  TextColumn get deviseBudget => text().withDefault(const Constant('MGA'))();
  TextColumn get motifPerte => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deletedAt => text().nullable()();



  @override
  List<String> get customConstraints => const [
        "CHECK (canal_origine IN ('messenger','facebook','whatsapp','email','telephone','presentiel','autre'))",
        "CHECK (statut IN ('a_qualifier','offre_presentee','en_attente_client','devis_a_preparer','gagnee','perdue'))",
        'CHECK (budget_indicatif IS NULL OR budget_indicatif >= 0)',
        "CHECK (devise_budget = 'MGA')",
        'FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE RESTRICT',
        'FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE RESTRICT',
      ];

  @override
  Set<Column> get primaryKey => {id};

}

class DemandePrestations extends Table {
  TextColumn get id => text()();
  TextColumn get demandeId => text()();
  TextColumn get serviceId => text()();
  // Quantité décimale exacte stockée en TEXT canonique (spéc. §3, correction C3)
  TextColumn get quantite => text().withDefault(const Constant('1'))();
  TextColumn get uniteSnapshot => text()();
  IntColumn get prixIndicatifUnitaire => integer().nullable()();
  TextColumn get devise => text().withDefault(const Constant('MGA'))();
  TextColumn get detailsJson => text().withDefault(const Constant('{}'))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deletedAt => text().nullable()();



  @override
  List<String> get customConstraints => const [
        'CHECK (quantite > 0)',
        'CHECK (prix_indicatif_unitaire IS NULL OR prix_indicatif_unitaire >= 0)',
        "CHECK (devise = 'MGA')",
        'FOREIGN KEY (demande_id) REFERENCES demandes(id) ON DELETE RESTRICT',
        'FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE RESTRICT',
      ];

  @override
  Set<Column> get primaryKey => {id};


  @override
  List<Set<Column>> get uniqueKeys => [
        {demandeId, serviceId},
      ];
}

class Commandes extends Table {
  TextColumn get id => text()();
  TextColumn get numero => text().unique()();
  TextColumn get demandeId => text().unique()();
  TextColumn get statut =>
      text().withDefault(const Constant('en_preparation'))();
  TextColumn get dateConfirmation => text().nullable()();
  TextColumn get dateDebutPrevue => text().nullable()();
  TextColumn get dateLimiteConfirmee => text().nullable()();
  TextColumn get instructions => text().nullable()();
  TextColumn get motifAnnulation => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deletedAt => text().nullable()();



  @override
  List<String> get customConstraints => const [
        "CHECK (statut IN ('en_preparation','en_attente_validation','validee','en_production','en_correction','livree','annulee'))",
        'FOREIGN KEY (demande_id) REFERENCES demandes(id) ON DELETE RESTRICT',
      ];

  @override
  Set<Column> get primaryKey => {id};

}

class LignesCommande extends Table {
  TextColumn get id => text()();
  TextColumn get commandeId => text()();
  TextColumn get serviceId => text().nullable()();
  TextColumn get description => text()();
  TextColumn get quantite => text()();
  TextColumn get uniteSnapshot => text()();
  IntColumn get prixUnitaire => integer()();
  TextColumn get devise => text().withDefault(const Constant('MGA'))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deletedAt => text().nullable()();



  @override
  List<String> get customConstraints => const [
        'CHECK (quantite > 0)',
        'CHECK (prix_unitaire >= 0)',
        "CHECK (devise = 'MGA')",
        'FOREIGN KEY (commande_id) REFERENCES commandes(id) ON DELETE RESTRICT',
        'FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE RESTRICT',
      ];

  @override
  Set<Column> get primaryKey => {id};

}

class Projets extends Table {
  TextColumn get id => text()();
  TextColumn get commandeId => text()();
  TextColumn get nom => text()();
  TextColumn get description => text().nullable()();
  TextColumn get statut =>
      text().withDefault(const Constant('en_preparation'))();
  TextColumn get dateLimite => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deletedAt => text().nullable()();



  @override
  List<String> get customConstraints => const [
        "CHECK (statut IN ('en_preparation','en_cours','en_correction','termine','annule'))",
        'FOREIGN KEY (commande_id) REFERENCES commandes(id) ON DELETE RESTRICT',
      ];

  @override
  Set<Column> get primaryKey => {id};

}

class CahiersCharges extends Table {
  TextColumn get id => text()();
  TextColumn get projetId => text()();
  IntColumn get versionDocument => integer().withDefault(const Constant(1))();
  TextColumn get contenuJson => text()();
  TextColumn get statut => text().withDefault(const Constant('brouillon'))();
  TextColumn get dateValidation => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deletedAt => text().nullable()();



  @override
  List<String> get customConstraints => const [
        'CHECK (version_document >= 1)',
        "CHECK (statut IN ('brouillon','a_valider','valide','remplace'))",
        'FOREIGN KEY (projet_id) REFERENCES projets(id) ON DELETE RESTRICT',
      ];

  @override
  Set<Column> get primaryKey => {id};


  @override
  List<Set<Column>> get uniqueKeys => [
        {projetId, versionDocument},
      ];
}

class Taches extends Table {
  TextColumn get id => text()();
  TextColumn get commandeId => text()();
  TextColumn get projetId => text().nullable()();
  TextColumn get titre => text()();
  TextColumn get description => text().nullable()();
  TextColumn get statut => text().withDefault(const Constant('a_faire'))();
  TextColumn get priorite => text().withDefault(const Constant('normale'))();
  TextColumn get echeance => text().nullable()();
  TextColumn get termineeAt => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deletedAt => text().nullable()();



  @override
  List<String> get customConstraints => const [
        "CHECK (statut IN ('a_faire','en_cours','bloquee','terminee','annulee'))",
        "CHECK (priorite IN ('basse','normale','haute','urgente'))",
        'FOREIGN KEY (commande_id) REFERENCES commandes(id) ON DELETE RESTRICT',
        'FOREIGN KEY (projet_id) REFERENCES projets(id) ON DELETE RESTRICT',
      ];

  @override
  Set<Column> get primaryKey => {id};

}

class ModelesMessages extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get nom => text()();
  TextColumn get objectif => text()();
  TextColumn get canal => text()();
  TextColumn get corpsTemplate => text()();
  TextColumn get variablesJson => text().withDefault(const Constant('[]'))();
  BoolColumn get actif => boolean().withDefault(const Constant(true))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deletedAt => text().nullable()();



  @override
  List<String> get customConstraints => const [
        "CHECK (canal IN ('messenger','whatsapp','email','telephone','autre'))",
      ];

  @override
  Set<Column> get primaryKey => {id};

}

class Echanges extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text()();
  TextColumn get demandeId => text().nullable()();
  TextColumn get commandeId => text().nullable()();
  TextColumn get modeleId =>
      text().nullable()();
  TextColumn get canal => text()();
  TextColumn get direction => text()();
  TextColumn get contenu => text()();
  TextColumn get statutEnvoi =>
      text().withDefault(const Constant('brouillon'))();
  TextColumn get datePreparation => text().nullable()();
  TextColumn get dateCopie => text().nullable()();
  TextColumn get dateEnvoiConfirme => text().nullable()();
  TextColumn get externalReference => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deletedAt => text().nullable()();



  @override
  List<String> get customConstraints => const [
        "CHECK (canal IN ('messenger','facebook','whatsapp','email','telephone','presentiel','autre'))",
        "CHECK (direction IN ('entrant','sortant','interne'))",
        "CHECK (statut_envoi IN ('brouillon','prete','copiee','envoi_manuel_confirme','envoi_integration_confirme','echec'))",
        'FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE RESTRICT',
        'FOREIGN KEY (demande_id) REFERENCES demandes(id) ON DELETE RESTRICT',
        'FOREIGN KEY (commande_id) REFERENCES commandes(id) ON DELETE RESTRICT',
        'FOREIGN KEY (modele_id) REFERENCES modeles_messages(id) ON DELETE RESTRICT',
      ];

  @override
  Set<Column> get primaryKey => {id};

}

@DataClassName('Devis')
class DevisTable extends Table {
  @override
  String? get tableName => 'devis';

  TextColumn get id => text()();
  TextColumn get numero => text().unique()();
  TextColumn get demandeId => text()();
  TextColumn get commandeId => text().nullable()();
  IntColumn get revision => integer().withDefault(const Constant(1))();
  TextColumn get statut => text().withDefault(const Constant('brouillon'))();
  TextColumn get dateEmission => text().nullable()();
  TextColumn get dateValidite => text().nullable()();
  TextColumn get conditions => text().nullable()();
  IntColumn get totalHt => integer().withDefault(const Constant(0))();
  TextColumn get devise => text().withDefault(const Constant('MGA'))();
  TextColumn get accepteAt => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deletedAt => text().nullable()();



  @override
  List<String> get customConstraints => const [
        'CHECK (revision >= 1)',
        "CHECK (statut IN ('brouillon','presente','modification_demandee','accepte','refuse','expire','remplace'))",
        'CHECK (total_ht >= 0)',
        "CHECK (devise = 'MGA')",
        'FOREIGN KEY (demande_id) REFERENCES demandes(id) ON DELETE RESTRICT',
        'FOREIGN KEY (commande_id) REFERENCES commandes(id) ON DELETE RESTRICT',
      ];

  @override
  Set<Column> get primaryKey => {id};


  @override
  List<Set<Column>> get uniqueKeys => [
        {demandeId, revision},
      ];
}

@DataClassName('LignesDevis')
class LignesDevisTable extends Table {
  @override
  String? get tableName => 'lignes_devis';

  TextColumn get id => text()();
  TextColumn get devisId => text()();
  TextColumn get serviceId => text().nullable()();
  TextColumn get description => text()();
  TextColumn get quantite => text()();
  TextColumn get uniteSnapshot => text()();
  IntColumn get prixUnitaire => integer()();
  IntColumn get montantLigne => integer()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deletedAt => text().nullable()();



  @override
  List<String> get customConstraints => const [
        'CHECK (quantite > 0)',
        'CHECK (prix_unitaire >= 0)',
        'CHECK (montant_ligne >= 0)',
        'FOREIGN KEY (devis_id) REFERENCES devis(id) ON DELETE RESTRICT',
        'FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE RESTRICT',
      ];

  @override
  Set<Column> get primaryKey => {id};

}

class Factures extends Table {
  TextColumn get id => text()();
  TextColumn get numero => text().unique()();
  TextColumn get commandeId => text().unique()();
  TextColumn get statut => text().withDefault(const Constant('brouillon'))();
  TextColumn get dateEmission => text().nullable()();
  TextColumn get dateEcheance => text().nullable()();
  IntColumn get total => integer().withDefault(const Constant(0))();
  TextColumn get devise => text().withDefault(const Constant('MGA'))();
  TextColumn get conditions => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deletedAt => text().nullable()();



  @override
  List<String> get customConstraints => const [
        "CHECK (statut IN ('brouillon','emise','partiellement_payee','payee','annulee'))",
        'CHECK (total >= 0)',
        "CHECK (devise = 'MGA')",
        'FOREIGN KEY (commande_id) REFERENCES commandes(id) ON DELETE RESTRICT',
      ];

  @override
  Set<Column> get primaryKey => {id};

}

class LignesFacture extends Table {
  TextColumn get id => text()();
  TextColumn get factureId => text()();
  TextColumn get description => text()();
  TextColumn get quantite => text()();
  TextColumn get uniteSnapshot => text()();
  IntColumn get prixUnitaire => integer()();
  IntColumn get montantLigne => integer()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deletedAt => text().nullable()();



  @override
  List<String> get customConstraints => const [
        'CHECK (quantite > 0)',
        'CHECK (prix_unitaire >= 0)',
        'CHECK (montant_ligne >= 0)',
        'FOREIGN KEY (facture_id) REFERENCES factures(id) ON DELETE RESTRICT',
      ];

  @override
  Set<Column> get primaryKey => {id};

}

class Paiements extends Table {
  TextColumn get id => text()();
  TextColumn get factureId => text()();
  IntColumn get montant => integer()();
  TextColumn get devise => text().withDefault(const Constant('MGA'))();
  TextColumn get datePaiement => text()();
  TextColumn get moyen => text()();
  TextColumn get reference => text().nullable()();
  TextColumn get statut => text().withDefault(const Constant('confirme'))();
  TextColumn get notes => text().nullable()();
  TextColumn get idempotencyKey => text().nullable().unique()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deletedAt => text().nullable()();



  @override
  List<String> get customConstraints => const [
        'CHECK (montant > 0)',
        "CHECK (moyen IN ('especes','mobile_money','virement','autre'))",
        "CHECK (statut IN ('en_attente','confirme','annule'))",
        'FOREIGN KEY (facture_id) REFERENCES factures(id) ON DELETE RESTRICT',
      ];

  @override
  Set<Column> get primaryKey => {id};

}

class Depenses extends Table {
  TextColumn get id => text()();
  TextColumn get dateDepense => text()();
  TextColumn get categorie => text()();
  TextColumn get description => text()();
  IntColumn get montant => integer()();
  TextColumn get devise => text().withDefault(const Constant('MGA'))();
  TextColumn get moyen => text()();
  TextColumn get reference => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deletedAt => text().nullable()();



  @override
  List<String> get customConstraints => const [
        'CHECK (montant > 0)',
        "CHECK (moyen IN ('especes','mobile_money','virement','autre'))",
      ];

  @override
  Set<Column> get primaryKey => {id};

}

class PiecesJointes extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text().nullable()();
  TextColumn get demandeId => text().nullable()();
  TextColumn get commandeId => text().nullable()();
  TextColumn get projetId => text().nullable()();
  TextColumn get nomFichier => text()();
  TextColumn get mimeType => text()();
  IntColumn get tailleOctets => integer()();
  TextColumn get sha256 => text()();
  TextColumn get cheminLocal => text().nullable()();
  TextColumn get cleStockageDistant => text().nullable()();
  TextColumn get statutTransfert =>
      text().withDefault(const Constant('local'))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deletedAt => text().nullable()();



  @override
  List<String> get customConstraints => const [
        "CHECK (statut_transfert IN ('local','a_transferer','transfert_en_cours','synchronise','echec'))",
        'CHECK (client_id IS NOT NULL OR demande_id IS NOT NULL OR commande_id IS NOT NULL OR projet_id IS NOT NULL)',
        'CHECK (taille_octets >= 0)',
        'FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE RESTRICT',
        'FOREIGN KEY (demande_id) REFERENCES demandes(id) ON DELETE RESTRICT',
        'FOREIGN KEY (commande_id) REFERENCES commandes(id) ON DELETE RESTRICT',
        'FOREIGN KEY (projet_id) REFERENCES projets(id) ON DELETE RESTRICT',
      ];

  @override
  Set<Column> get primaryKey => {id};

}

class JournalActions extends Table {
  TextColumn get id => text()();
  TextColumn get entiteType => text()();
  TextColumn get entiteId => text()();
  TextColumn get action => text()();
  TextColumn get avantJson => text().nullable()();
  TextColumn get apresJson => text().nullable()();
  TextColumn get motif => text().nullable()();
  TextColumn get appareilId => text()();
  TextColumn get acteurId => text().nullable()();
  TextColumn get dateAction => text()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deletedAt => text().nullable()();



  @override
  List<String> get customConstraints => const [];

  @override
  Set<Column> get primaryKey => {id};
}

class Appareils extends Table {
  TextColumn get id => text()();
  TextColumn get nom => text()();
  TextColumn get plateforme => text()();
  TextColumn get dernierSyncAt => text().nullable()();
  BoolColumn get actif => boolean().withDefault(const Constant(true))();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();



  @override
  List<String> get customConstraints => const [
        "CHECK (plateforme IN ('android','windows'))",
      ];

  @override
  Set<Column> get primaryKey => {id};
}

class PublicationsFacebook extends Table {
  TextColumn get id => text()();
  TextColumn get clientId => text().nullable()();
  TextColumn get titre => text()();
  TextColumn get contenu => text()();
  TextColumn get datePlanifiee => text()();
  TextColumn get statut => text().withDefault(const Constant('planifie'))();
  TextColumn get canal => text().withDefault(const Constant('facebook'))();
  TextColumn get publieAt => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get deletedAt => text().nullable()();



  @override
  List<String> get customConstraints => const [
        "CHECK (statut IN ('planifie','prete','publie_manuellement','annule'))",
        'FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE RESTRICT',
      ];

  @override
  Set<Column> get primaryKey => {id};

}

class SyncOutbox extends Table {
  TextColumn get id => text()();
  TextColumn get appareilId => text()();
  TextColumn get entiteType => text()();
  TextColumn get entiteId => text()();
  TextColumn get operation => text()();
  TextColumn get payloadJson => text()();
  IntColumn get baseVersion => integer().nullable()();
  TextColumn get idempotencyKey => text().unique()();
  TextColumn get statut => text().withDefault(const Constant('pending'))();
  IntColumn get tentatives => integer().withDefault(const Constant(0))();
  TextColumn get prochaineTentativeAt => text().nullable()();
  TextColumn get derniereErreur => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();



  @override
  List<String> get customConstraints => const [
        "CHECK (operation IN ('upsert','delete'))",
        "CHECK (statut IN ('pending','in_flight','synced','conflict','failed'))",
        'CHECK (tentatives >= 0)',
        'FOREIGN KEY (appareil_id) REFERENCES appareils(id) ON DELETE RESTRICT',
      ];

  @override
  Set<Column> get primaryKey => {id};

}

class SyncState extends Table {
  TextColumn get appareilId => text()();
  TextColumn get dernierCurseur => text().withDefault(const Constant('0'))();
  TextColumn get dernierSyncReussiAt => text().nullable()();
  TextColumn get derniereErreur => text().nullable()();
  TextColumn get updatedAt => text()();



  @override
  List<String> get customConstraints => const [
        'FOREIGN KEY (appareil_id) REFERENCES appareils(id) ON DELETE RESTRICT',
      ];

  @override
  Set<Column> get primaryKey => {appareilId};
}

class SyncConflicts extends Table {
  TextColumn get id => text()();
  TextColumn get appareilId => text()();
  TextColumn get entiteType => text()();
  TextColumn get entiteId => text()();
  IntColumn get versionLocale => integer()();
  IntColumn get versionServeur => integer()();
  TextColumn get localJson => text()();
  TextColumn get serveurJson => text()();
  TextColumn get statut => text().withDefault(const Constant('a_resoudre'))();
  TextColumn get resolutionJson => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();



  @override
  List<String> get customConstraints => const [
        "CHECK (statut IN ('a_resoudre','resolu_local','resolu_serveur','fusionne'))",
        'FOREIGN KEY (appareil_id) REFERENCES appareils(id) ON DELETE RESTRICT',
      ];

  @override
  Set<Column> get primaryKey => {id};

}


class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();



  @override
  List<String> get customConstraints => const [];

  @override
  Set<Column> get primaryKey => {key};
}
