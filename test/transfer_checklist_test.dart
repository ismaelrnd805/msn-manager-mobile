/// Tests de la checklist TRANSFERT PC (section 20) : les 9 vérifications.
library;
import 'package:flutter_test/flutter_test.dart';

import 'package:msn_manager_mobile/core/domain/transfer_checklist.dart';

void main() {
  const complet = TransferContext(
    clientIdentifie: true,
    serviceDefini: true,
    briefTermine: true,
    devisAccepte: true,
    conditionsAcceptees: true,
    acompteRequis: 60000,
    acomptePaye: 60000,
    deadlineDefinie: true,
    nbFichiers: 2,
    workflowSelectionne: true,
  );

  test('une commande complète passe les 9 vérifications', () {
    final items = TransferChecklist.verifier(complet);
    expect(items.length, 9);
    expect(TransferChecklist.pretPourTransfert(items), isTrue);
  });

  test('acompte manquant bloque le transfert', () {
    final items = TransferChecklist.verifier(
      const TransferContext(
        clientIdentifie: true,
        serviceDefini: true,
        briefTermine: true,
        devisAccepte: true,
        conditionsAcceptees: true,
        acompteRequis: 60000,
        acomptePaye: 0,
        deadlineDefinie: true,
        nbFichiers: 2,
        workflowSelectionne: true,
      ),
    );
    expect(TransferChecklist.pretPourTransfert(items), isFalse);
    expect(
      items.any((i) => !i.ok && i.label.contains('Acompte')),
      isTrue,
    );
  });

  test('aucun fichier disponible bloque le transfert', () {
    final items = TransferChecklist.verifier(const TransferContext(
      clientIdentifie: true,
      serviceDefini: true,
      briefTermine: true,
      devisAccepte: true,
      conditionsAcceptees: true,
      acompteRequis: 0,
      acomptePaye: 0,
      deadlineDefinie: true,
      nbFichiers: 0,
      workflowSelectionne: true,
    ));
    expect(TransferChecklist.pretPourTransfert(items), isFalse);
  });

  test('un acompte non requis laisse passer sans paiement', () {
    final items = TransferChecklist.verifier(const TransferContext(
      clientIdentifie: true,
      serviceDefini: true,
      briefTermine: true,
      devisAccepte: true,
      conditionsAcceptees: true,
      acompteRequis: 0,
      acomptePaye: 0,
      deadlineDefinie: true,
      nbFichiers: 1,
      workflowSelectionne: true,
    ));
    expect(TransferChecklist.pretPourTransfert(items), isTrue);
  });

  test('chaque blocage a un détail explicatif pour l\u2019opérateur', () {
    final items = TransferChecklist.verifier(const TransferContext(
      clientIdentifie: true,
      serviceDefini: false,
      briefTermine: false,
      devisAccepte: false,
      conditionsAcceptees: false,
      acompteRequis: 0,
      acomptePaye: 0,
      deadlineDefinie: false,
      nbFichiers: 0,
      workflowSelectionne: false,
    ));
    final blocked = items.where((i) => !i.ok).toList();
    expect(blocked.length, greaterThan(5));
    for (final item in blocked) {
      expect(item.detail, isNotNull,
          reason: 'Le blocage « ${item.label} » doit être expliqué');
    }
  });
}
