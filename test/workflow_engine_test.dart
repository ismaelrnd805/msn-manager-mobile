/// Tests du moteur de workflow : progression « Où suis-je ? ».
import 'package:flutter_test/flutter_test.dart';

import 'package:msn_manager_mobile/core/domain/workflow_engine.dart';

void main() {
  group('WorkflowEngine.progression', () {
    test('démarre à la première étape', () {
      final p = WorkflowEngine.progression([false, false, false]);
      expect(p.etapeCourante, 0);
      expect(p.terminee, isFalse);
      expect(p.avancement, 0);
    });

    test('avance au fur et à mesure', () {
      final p = WorkflowEngine.progression([true, true, false]);
      expect(p.etapeCourante, 2);
      expect(p.terminee, isFalse);
      expect(p.avancement, closeTo(2 / 3, 0.001));
    });

    test('détecte la fin du workflow', () {
      final p = WorkflowEngine.progression([true, true, true]);
      expect(p.terminee, isTrue);
      expect(p.etapeCourante, 2); // dernière étape
      expect(p.avancement, 1);
      expect(p.labelAvancement, '100%');
    });

    test('gère une liste vide', () {
      final p = WorkflowEngine.progression([]);
      expect(p.terminee, isTrue);
      expect(p.avancement, 0);
    });

    test('workflow logo complet de démonstration (13 étapes)', () {
      final steps = List.filled(13, false);
      steps[0] = true; // Réception
      steps[1] = true; // Qualification
      final p = WorkflowEngine.progression(steps);
      expect(p.etapeCourante, 2); // Devis
      expect(p.totalEtapes, 13);
    });
  });

  group('ActionCatalog', () {
    test('classe les codes d\u2019actions par type', () {
      expect(
        ActionCatalog.typeOf(ActionCatalog.messageTarif),
        ActionType.message,
      );
      expect(
        ActionCatalog.typeOf(ActionCatalog.demanderAcompte),
        ActionType.messagePaiement,
      );
      expect(
        ActionCatalog.typeOf(ActionCatalog.enregistrerAcompte),
        ActionType.paiement,
      );
      expect(
        ActionCatalog.typeOf(ActionCatalog.recevoirFichiers),
        ActionType.fichiers,
      );
      expect(
        ActionCatalog.typeOf(ActionCatalog.produire),
        ActionType.production,
      );
      expect(
        ActionCatalog.typeOf(ActionCatalog.valider),
        ActionType.validation,
      );
    });

    test('chaque code a un libellé français', () {
      final codes = [
        ActionCatalog.messageAccueil,
        ActionCatalog.messageTarif,
        ActionCatalog.messageDevis,
        ActionCatalog.demanderAcompte,
        ActionCatalog.enregistrerAcompte,
        ActionCatalog.demanderFichiers,
        ActionCatalog.recevoirFichiers,
        ActionCatalog.produire,
        ActionCatalog.proposerLivraison,
        ActionCatalog.demanderValidation,
        ActionCatalog.valider,
        ActionCatalog.appliquerCorrections,
        ActionCatalog.livrer,
        ActionCatalog.demanderSolde,
        ActionCatalog.enregistrerPaiement,
        ActionCatalog.archiver,
        ActionCatalog.transferePc,
        ActionCatalog.controle,
        ActionCatalog.analyse,
      ];
      for (final code in codes) {
        expect(ActionCatalog.labels.containsKey(code), isTrue,
            reason: 'Libellé manquant pour $code');
      }
    });
  });
}
