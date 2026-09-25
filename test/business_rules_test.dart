/// Tests du moteur de règles métier (section 23) : blocages et exceptions.
import 'package:flutter_test/flutter_test.dart';

import 'package:msn_manager_mobile/core/constants/app_constants.dart';
import 'package:msn_manager_mobile/core/domain/business_rules.dart';

void main() {
  final rulesLogo = RuleSet.fromRows({
    RuleKeys.acompteObligatoire: 'true',
    RuleKeys.propositionsIncluses: '2',
    RuleKeys.correctionsIncluses: '2',
    RuleKeys.paiementFinalAvantLivraison: 'true',
    RuleKeys.validationFinaleObligatoire: 'true',
  });

  test('aucune violation sans règles', () {
    final violations = BusinessRuleEngine.verifier(
      const RuleSet({}),
      const RuleContext(nomEtape: 'Acompte'),
    );
    expect(violations, isEmpty);
  });

  test('bloque l\u2019étape Acompte sans paiement', () {
    final violations = BusinessRuleEngine.verifier(
      rulesLogo,
      const RuleContext(
        nomEtape: 'Acompte',
        totalPaye: 0,
        totalCommande: 150000,
      ),
    );
    expect(violations, isNotEmpty);
    expect(
      violations.any((v) => v.cle == RuleKeys.acompteObligatoire),
      isTrue,
    );
  });

  test('laisse passer quand l\u2019acompte est payé', () {
    final violations = BusinessRuleEngine.verifier(
      rulesLogo,
      const RuleContext(
        nomEtape: 'Acompte',
        totalPaye: 60000,
        totalCommande: 150000,
      ),
    );
    expect(
      violations.any((v) => v.cle == RuleKeys.acompteObligatoire),
      isFalse,
    );
  });

  test('bloque la production sans brief complet', () {
    final violations = BusinessRuleEngine.verifier(
      rulesLogo,
      const RuleContext(
        nomEtape: 'Production',
        totalPaye: 60000,
        totalCommande: 150000,
        devisAccepte: true,
        briefComplet: false,
      ),
    );
    expect(violations.any((v) => v.cle == 'brief_complet'), isTrue);
  });

  test('bloque la livraison sans validation finale', () {
    final violations = BusinessRuleEngine.verifier(
      rulesLogo,
      const RuleContext(
        nomEtape: 'Livraison',
        totalPaye: 150000,
        totalCommande: 150000,
        validationClient: false,
      ),
    );
    expect(
      violations.any((v) => v.cle == RuleKeys.validationFinaleObligatoire),
      isTrue,
    );
  });

  test('bloque la livraison si le paiement final manque', () {
    final violations = BusinessRuleEngine.verifier(
      rulesLogo,
      const RuleContext(
        nomEtape: 'Livraison',
        totalPaye: 60000,
        totalCommande: 150000,
        validationClient: true,
      ),
    );
    expect(
      violations.any((v) => v.cle == RuleKeys.paiementFinalAvantLivraison),
      isTrue,
    );
  });

  test('aucune violation sur un flux complet et conforme', () {
    final violations = BusinessRuleEngine.verifier(
      rulesLogo,
      const RuleContext(
        nomEtape: 'Livraison',
        totalPaye: 150000,
        totalCommande: 150000,
        validationClient: true,
        devisAccepte: true,
        briefComplet: true,
      ),
    );
    expect(violations, isEmpty);
  });

  test('une violation est surmontable par EXCEPTION AUTORISÉE', () {
    final violations = BusinessRuleEngine.verifier(
      rulesLogo,
      const RuleContext(nomEtape: 'Acompte', totalPaye: 0),
    );
    expect(BusinessRuleEngine.exceptionPossible(violations), isTrue);
  });
}
