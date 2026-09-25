/// Constantes globales de l'application MSN Manager Mobile.
library;

class AppConstants {
  AppConstants._();

  static const String appName = 'MSN Manager';
  static const String companyLegalName = 'MSN — Multi-Services Numériques';
  static const String appVersion = '1.0.0';
  static const int databaseSchemaVersion = 3;

  // Contact par défaut (modifiable dans les paramètres / sauvegarde).
  static const String defaultCompanyPhone = '+261 34 00 000 00';
  static const String defaultCompanyEmail = 'contact@msn.mg';

  /// Année courante utilisée par la numérotation (recalculée dynamiquement
  /// par [NumberingService], cette valeur ne sert qu'aux tests).
  static const List<String> referencePrefixes = ['REQ', 'DEV', 'CMD', 'FAC', 'PMT'];

  /// Dossiers de production standard d'une commande (miroir du côté PC).
  static const List<String> orderFolders = [
    'SOURCE',
    'TRAVAIL',
    'CORRECTIONS',
    'FINAL',
    'DOCUMENTS',
  ];

  /// Jours de validité par défaut d'un devis.
  static const int defaultQuoteValidityDays = 15;

  /// Taille des lots poussés par le moteur de synchronisation.
  static const int syncBatchSize = 50;

  /// Nombre maximum de tentatives avant mise en erreur définitive.
  static const int syncMaxAttempts = 5;

  // Clés de paramètres (table settings).
  static const String keySeeded = 'demo_seeded';
  static const String keyServerUrl = 'server_url';
  static const String keyLastSyncAt = 'last_sync_at';
  static const String keyLastUser = 'last_user';
  static const String keyCompanyName = 'company_name';
  static const String keyCompanyPhone = 'company_phone';
  static const String keyCompanyEmail = 'company_email';
  static const String keyDefaultAcomptePercent = 'default_acompte_percent';
}

/// Clés de règles métier configurables par service
/// (table business_rules — l'administrateur les modifie sans toucher au code).
class RuleKeys {
  RuleKeys._();

  static const String acompteObligatoire = 'acompte_obligatoire';
  static const String propositionsIncluses = 'propositions_incluses';
  static const String correctionsIncluses = 'corrections_incluses';
  static const String paiementFinalAvantLivraison = 'paiement_final_avant_livraison';
  static const String validationFinaleObligatoire = 'validation_finale_obligatoire';

  static const Map<String, String> labels = {
    acompteObligatoire: 'Acompte obligatoire',
    propositionsIncluses: 'Propositions incluses',
    correctionsIncluses: 'Corrections incluses',
    paiementFinalAvantLivraison: 'Paiement final avant livraison',
    validationFinaleObligatoire: 'Validation finale obligatoire',
  };

  static const Map<String, String> defaults = {
    acompteObligatoire: 'false',
    propositionsIncluses: '2',
    correctionsIncluses: '2',
    paiementFinalAvantLivraison: 'false',
    validationFinaleObligatoire: 'false',
  };
}
