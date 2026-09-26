/// Règles métier configurables par service et moteur de vérification.
///
/// L'administrateur définit les règles (table `business_rules`) sans modifier
/// le code. Le moteur bloque une étape de workflow tant qu'une règle
/// obligatoire n'est pas satisfaite, sauf EXCEPTION AUTORISÉE (raison,
/// utilisateur, date — enregistrées dans `rule_exceptions`).
library;

import '../constants/app_constants.dart';
import '../utils/formatters.dart';

/// Règles d'un service (clé → valeur texte) parsées en accès typés.
class RuleSet {
  const RuleSet(this._values);

  final Map<String, String> _values;

  static RuleSet fromRows(Map<String, String> rows) => RuleSet(rows);

  bool get acompteObligatoire =>
      _values[RuleKeys.acompteObligatoire]?.toLowerCase() == 'true';

  int get propositionsIncluses =>
      int.tryParse(_values[RuleKeys.propositionsIncluses] ?? '') ?? 2;

  int get correctionsIncluses =>
      int.tryParse(_values[RuleKeys.correctionsIncluses] ?? '') ?? 2;

  bool get paiementFinalAvantLivraison =>
      _values[RuleKeys.paiementFinalAvantLivraison]?.toLowerCase() == 'true';

  bool get validationFinaleObligatoire =>
      _values[RuleKeys.validationFinaleObligatoire]?.toLowerCase() == 'true';

  bool get isEmpty => _values.isEmpty;
}

/// Contexte d'exécution passé au moteur lors d'une transition d'étape.
class RuleContext {
  const RuleContext({
    required this.nomEtape,
    this.totalPaye = 0,
    this.totalCommande = 0,
    this.devisAccepte = false,
    this.validationClient = false,
    this.nbFichiers = 0,
    this.conditionsAcceptees = false,
    this.briefComplet = false,
  });

  final String nomEtape;
  final int totalPaye; // somme encaissée pour cette commande
  final int totalCommande; // montant total convenu
  final bool devisAccepte;
  final bool validationClient;
  final int nbFichiers;
  final bool conditionsAcceptees;
  final bool briefComplet;
}

/// Violation détectée : l'étape ne peut pas être validée telle quelle.
class RuleViolation {
  const RuleViolation(this.cle, this.message);

  final String cle;
  final String message;
}

class BusinessRuleEngine {
  BusinessRuleEngine._();

  /// Vérifie si l'étape courante peut être validée.
  ///
  /// L'appariement se fait sur des mots-clés du nom de l'étape, ce qui
  /// reste robuste même si l'administrateur renomme légèrement les étapes.
  static List<RuleViolation> verifier(RuleSet rules, RuleContext ctx) {
    if (rules.isEmpty) return const [];
    final violations = <RuleViolation>[];
    final etape = ctx.nomEtape.toLowerCase();

    final etapeAcompte = etape.contains('acompte');
    final etapeProduction = etape.contains('production') || etape.contains('brief');
    final etapeLivraison = etape.contains('livraison') || etape.contains('livr');

    // 1. Acompte obligatoire : aucune progression (acompte / production)
    //    tant qu'aucun paiement n'a été enregistré.
    if (rules.acompteObligatoire && (etapeAcompte || etapeProduction)) {
      if (ctx.totalPaye <= 0) {
        violations.add(const RuleViolation(
          RuleKeys.acompteObligatoire,
          'L’acompte est obligatoire avant de continuer. Enregistrez le '
          'paiement de l’acompte ou créez une exception autorisée.',
        ));
      }
    }

    // 2. Production : le brief doit être complet.
    if (etapeProduction && !ctx.briefComplet) {
      violations.add(const RuleViolation(
        'brief_complet',
        'Le brief n’est pas complet. Complétez la qualification avant la '
        'production.',
      ));
    }

    // 3. Production : un devis accepté doit être rattaché à la commande.
    if (etapeProduction && ctx.totalCommande > 0 && !ctx.devisAccepte) {
      violations.add(const RuleViolation(
        'devis_accepte',
        'Aucun devis accepté n’est rattaché à cette commande.',
      ));
    }

    // 4. Validation finale obligatoire avant livraison.
    if (rules.validationFinaleObligatoire && etapeLivraison && !ctx.validationClient) {
      violations.add(const RuleViolation(
        RuleKeys.validationFinaleObligatoire,
        'La validation finale du client est obligatoire avant la livraison.',
      ));
    }

    // 5. Livraison IMPOSSIBLE sans encaissement complet (règle MSN).
    //    Exception autorisée possible en cas exceptionnel (raison, admin,
    //    date — enregistrées dans `rule_exceptions` et le journal).
    if (rules.paiementFinalAvantLivraison &&
        etapeLivraison &&
        ctx.totalCommande > 0 &&
        ctx.totalPaye < ctx.totalCommande) {
      final reste = ctx.totalCommande - ctx.totalPaye;
      violations.add(RuleViolation(
        RuleKeys.paiementFinalAvantLivraison,
        'La livraison ne peut pas être validée sans encaissement complet : '
            'il reste ${Formatters.ar(reste)} à encaisser. Enregistrez le '
            'paiement final, ou acceptez une exception en cas exceptionnel.',
      ));
    }

    return violations;
  }

  /// Une violation peut toujours être surmontée par une EXCEPTION AUTORISÉE
  /// (raison + utilisateur + date), tracée dans le journal d'activité.
  static bool exceptionPossible(List<RuleViolation> violations) =>
      violations.isNotEmpty;
}
