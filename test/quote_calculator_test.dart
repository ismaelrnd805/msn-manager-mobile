/// Tests du calculateur de devis et factures — la logique financière
/// doit être parfaite (montants entiers en Ariary).
import 'package:flutter_test/flutter_test.dart';

import 'package:msn_manager_mobile/core/domain/quote_calculator.dart';

void main() {
  group('QuoteCalculator.devis', () {
    test('calcule le sous-total, le total et le solde correctement', () {
      final totals = QuoteCalculator.devis(
        lignes: [
          const DocumentLine(
              designation: 'Logo', quantite: 1, prixUnitaire: 150000),
          const DocumentLine(
              designation: 'Saisie', quantite: 10, prixUnitaire: 700),
        ],
      );
      expect(totals.sousTotal, 157000);
      expect(totals.reduction, 0);
      expect(totals.total, 157000);
      expect(totals.acompte, 0);
      expect(totals.solde, 157000);
    });

    test('applique la réduction et l\u2019acompte', () {
      final totals = QuoteCalculator.devis(
        lignes: [
          const DocumentLine(
              designation: 'Logo', quantite: 1, prixUnitaire: 150000),
        ],
        reduction: 20000,
        acompte: 60000,
      );
      expect(totals.total, 130000);
      expect(totals.acompte, 60000);
      expect(totals.solde, 70000);
    });

    test('plafonne la réduction au sous-total (jamais négatif)', () {
      final totals = QuoteCalculator.devis(
        lignes: [
          const DocumentLine(
              designation: 'CV', quantite: 1, prixUnitaire: 10000),
        ],
        reduction: 50000,
      );
      expect(totals.reduction, 10000);
      expect(totals.total, 0);
      expect(totals.solde, 0);
    });

    test('plafonne l\u2019acompte au total', () {
      final totals = QuoteCalculator.devis(
        lignes: [
          const DocumentLine(
              designation: 'Affiche', quantite: 2, prixUnitaire: 45000),
        ],
        acompte: 200000,
      );
      expect(totals.acompte, 90000);
      expect(totals.solde, 0);
      expect(totals.estSolde, isTrue);
    });

    test('gère les quantités décimales (arrondi correct)', () {
      final totals = QuoteCalculator.devis(
        lignes: [
          const DocumentLine(
              designation: 'Saisie', quantite: 2.5, prixUnitaire: 700),
        ],
      );
      expect(totals.sousTotal, 1750);
    });
  });

  group('QuoteCalculator.facture', () {
    test('le solde diminue à chaque paiement', () {
      final lignes = [
        const DocumentLine(
            designation: 'Site web', quantite: 1, prixUnitaire: 450000),
      ];
      final step1 = QuoteCalculator.facture(
          lignes: lignes, paiementsRecus: const [200000]);
      expect(step1.solde, 250000);
      expect(step1.estSolde, isFalse);

      final step2 = QuoteCalculator.facture(
          lignes: lignes, paiementsRecus: const [200000, 250000]);
      expect(step2.solde, 0);
      expect(step2.estSolde, isTrue);
    });

    test('acompteSuggéré calcule le pourcentage', () {
      expect(QuoteCalculator.acompteSuggere(150000, 40), 60000);
      expect(QuoteCalculator.acompteSuggere(150000, 0), 0);
      expect(QuoteCalculator.acompteSuggere(0, 40), 0);
    });
  });
}
