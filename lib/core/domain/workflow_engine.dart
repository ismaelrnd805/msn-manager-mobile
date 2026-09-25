/// Moteur de workflow : progression d'une commande à travers les étapes
/// d'un modèle de workflow, avec catalogues d'« actions prêtes ».
///
/// Les modèles de workflows (étapes + actions) sont stockés en base et
/// modifiables par l'administrateur ; ce module contient la logique pure :
/// - déterminer où en est la commande (« Où suis-je ? ») ;
/// - lister les actions prêtes à l'étape courante (« Qu'est-ce qui est prêt ? ») ;
/// - valider les transitions (blocage par règles métier possible).
library;

/// Une étape d'un modèle de workflow.
class WorkflowBlueprintStep {
  const WorkflowBlueprintStep({required this.nom, this.actions = const []});

  final String nom;
  final List<String> actions; // codes d'actions prêtes (voir ActionCatalog)
}

/// Catalogue des types d'actions qu'une étape peut contenir.
///
/// Chaque code correspond à une action réelle de l'interface :
/// MESSAGE_* ouvre le compositeur, PDF_* génère un document,
/// PAIEMENT_* ouvre le formulaire de paiement, etc.
class ActionCatalog {
  ActionCatalog._();

  static const String messageAccueil = 'MESSAGE_ACCUEIL';
  static const String messageTarif = 'MESSAGE_TARIF';
  static const String messageDevis = 'MESSAGE_DEVIS';
  static const String demanderAcompte = 'DEMANDER_ACOMPTE';
  static const String enregistrerAcompte = 'ENREGISTRER_ACOMPTE';
  static const String demanderFichiers = 'DEMANDER_FICHIERS';
  static const String recevoirFichiers = 'RECEVOIR_FICHIERS';
  static const String produire = 'PRODUIRE';
  static const String proposerLivraison = 'PROPOSER_LIVRAISON';
  static const String demanderValidation = 'DEMANDER_VALIDATION';
  static const String valider = 'VALIDER';
  static const String appliquerCorrections = 'APPLIQUER_CORRECTIONS';
  static const String livrer = 'LIVRER';
  static const String demanderSolde = 'DEMANDER_SOLDE';
  static const String enregistrerPaiement = 'ENREGISTRER_PAIEMENT';
  static const String archiver = 'ARCHIVER';
  static const String transferePc = 'TRANSFERE_PC';
  static const String controle = 'CONTROLE';
  static const String analyse = 'ANALYSE';

  /// Libellés affichés dans l'interface.
  static const Map<String, String> labels = {
    messageAccueil: 'Message d’accueil',
    messageTarif: 'Présenter le tarif',
    messageDevis: 'Envoyer le devis',
    demanderAcompte: 'Demander l’acompte',
    enregistrerAcompte: 'Enregistrer l’acompte',
    demanderFichiers: 'Demander les fichiers',
    recevoirFichiers: 'Réceptionner les fichiers',
    produire: 'Production (PC)',
    proposerLivraison: 'Proposer la livraison',
    demanderValidation: 'Demander la validation',
    valider: 'Valider (client)',
    appliquerCorrections: 'Appliquer les corrections',
    livrer: 'Livrer',
    demanderSolde: 'Demander le solde',
    enregistrerPaiement: 'Enregistrer le paiement final',
    archiver: 'Archiver',
    transferePc: 'Transférer au PC',
    controle: 'Contrôle qualité',
    analyse: 'Analyse de la demande',
  };

  /// Type d'action, utilisé pour choisir l'icône et le comportement.
  static ActionType typeOf(String code) {
    if (code.startsWith('MESSAGE_')) return ActionType.message;
    if (code.startsWith('DEMANDER_ACOMPTE') || code.startsWith('DEMANDER_SOLDE')) {
      return ActionType.messagePaiement;
    }
    if (code.startsWith('ENREGISTRER')) return ActionType.paiement;
    if (code.startsWith('RECEVOIR_FICHIERS') || code.startsWith('DEMANDER_FICHIERS')) {
      return ActionType.fichiers;
    }
    if (code == produire || code == transferePc) return ActionType.production;
    if (code == valider || code == demanderValidation || code == controle) {
      return ActionType.validation;
    }
    return ActionType.tache;
  }
}

enum ActionType { message, messagePaiement, paiement, fichiers, production, validation, tache }

/// Résultat d'évaluation de la progression d'une instance de workflow.
class WorkflowProgress {
  const WorkflowProgress({
    required this.totalEtapes,
    required this.etapeCourante,
    required this.terminee,
    required this.avancement,
  });

  final int totalEtapes;
  final int etapeCourante; // index 0-based de l'étape en cours
  final bool terminee;
  final double avancement; // 0.0 → 1.0

  String get labelAvancement => '${(avancement * 100).round()}%';
}

class WorkflowEngine {
  WorkflowEngine._();

  /// Détermine l'état de progression à partir des états d'étapes
  /// (liste triée par ordre, statuts : en_attente / terminee / bloquee).
  static WorkflowProgress progression(List<bool> etapesTerminees) {
    final total = etapesTerminees.length;
    var courant = 0;
    while (courant < total && etapesTerminees[courant]) {
      courant++;
    }
    final terminee = courant >= total;
    return WorkflowProgress(
      totalEtapes: total,
      etapeCourante: terminee ? total - 1 : courant,
      terminee: terminee,
      avancement: total == 0 ? 0 : courant / total,
    );
  }

  /// Question métier « Que dois-je faire ? » : libellés des actions
  /// prêtes pour l'étape courante.
  static List<String> actionsPretes(WorkflowBlueprintStep etape) {
    return etape.actions;
  }
}
