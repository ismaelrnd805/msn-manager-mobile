/// Checklist « Prêt pour production » avant transfert d'une commande
/// vers le PC (section 20 du cahier des charges).
///
/// Les 9 vérifications obligatoires sont calculées ici de façon pure :
/// l'interface affiche la checklist en temps réel et n'active le bouton
/// TRANSFÉRER AU PC que si tout est vert.
library;

class TransferCheckItem {
  const TransferCheckItem(this.label, this.ok, [this.detail]);

  final String label;
  final bool ok;
  final String? detail;
}

/// Données d'entrée agrégées par l'écran commande.
class TransferContext {
  const TransferContext({
    required this.clientIdentifie,
    required this.serviceDefini,
    required this.briefTermine,
    required this.devisAccepte,
    required this.conditionsAcceptees,
    required this.acompteRequis,
    required this.acomptePaye,
    required this.deadlineDefinie,
    required this.nbFichiers,
    required this.workflowSelectionne,
  });

  final bool clientIdentifie;
  final bool serviceDefini;
  final bool briefTermine;
  final bool devisAccepte;
  final bool conditionsAcceptees;
  final int acompteRequis;
  final int acomptePaye;
  final bool deadlineDefinie;
  final int nbFichiers;
  final bool workflowSelectionne;
}

class TransferChecklist {
  TransferChecklist._();

  static List<TransferCheckItem> verifier(TransferContext ctx) {
    final acompteOk =
        ctx.acompteRequis <= 0 || ctx.acomptePaye >= ctx.acompteRequis;
    return [
      TransferCheckItem(
        'Client identifié',
        ctx.clientIdentifie,
        ctx.clientIdentifie ? null : 'Associez un client à la commande',
      ),
      TransferCheckItem(
        'Service défini',
        ctx.serviceDefini,
        ctx.serviceDefini ? null : 'Sélectionnez le service du catalogue',
      ),
      TransferCheckItem(
        'Brief terminé',
        ctx.briefTermine,
        ctx.briefTermine ? null : 'Terminez la qualification',
      ),
      TransferCheckItem(
        'Devis accepté',
        ctx.devisAccepte,
        ctx.devisAccepte ? null : 'Créez le devis et marquez-le comme accepté',
      ),
      TransferCheckItem(
        'Conditions acceptées',
        ctx.conditionsAcceptees,
        ctx.conditionsAcceptees ? null : 'Faites accepter les conditions au client',
      ),
      TransferCheckItem(
        'Acompte enregistré si nécessaire',
        acompteOk,
        acompteOk
            ? null
            : 'Acompte requis : ${ctx.acompteRequis} Ar — payé : ${ctx.acomptePaye} Ar',
      ),
      TransferCheckItem(
        'Deadline définie',
        ctx.deadlineDefinie,
        ctx.deadlineDefinie ? null : 'Fixez la date de livraison',
      ),
      TransferCheckItem(
        'Fichiers disponibles',
        ctx.nbFichiers > 0,
        ctx.nbFichiers > 0
            ? '${ctx.nbFichiers} fichier(s) joint(s)'
            : 'Joignez au moins un fichier (brief, logo, consignes…)',
      ),
      TransferCheckItem(
        'Workflow sélectionné',
        ctx.workflowSelectionne,
        ctx.workflowSelectionne ? null : 'Choisissez le workflow du service',
      ),
    ];
  }

  static bool pretPourTransfert(List<TransferCheckItem> items) =>
      items.isNotEmpty && items.every((i) => i.ok);
}
