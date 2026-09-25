/// Calculs purs des devis et factures — aucune dépendance Flutter/Drift :
/// logique métier centralisée et 100% testable.
///
/// Les montants sont des entiers (l'Ariary n'a pas de sous-unité en pratique),
/// ce qui élimine les erreurs d'arrondi des flottants.
library;

/// Ligne d'un devis ou d'une facture.
class DocumentLine {
  const DocumentLine({
    required this.designation,
    required this.quantite,
    required this.prixUnitaire,
  });

  final String designation;
  final double quantite;
  final int prixUnitaire; // en Ar / unité

  int get totalLigne => (quantite * prixUnitaire).round();
}

/// Totaux calculés d'un document commercial.
class DocumentTotals {
  const DocumentTotals({
    required this.sousTotal,
    required this.reduction,
    required this.total,
    required this.acompte,
    required this.solde,
    required this.paye,
  });

  final int sousTotal; // somme des lignes
  final int reduction; // remise appliquée (jamais > sousTotal)
  final int total; // sousTotal - reduction
  final int acompte; // acompte demandé (pour un devis)
  final int solde; // reste à payer
  final int paye; // sommes déjà encaissées (facture)

  bool get estSolde => solde <= 0;
}

class QuoteCalculator {
  QuoteCalculator._();

  /// Totaux d'un **devis** : sous-total, réduction plafonnée, total,
  /// acompte demandé et solde attendu avant production.
  static DocumentTotals devis({
    required List<DocumentLine> lignes,
    int reduction = 0,
    int acompte = 0,
  }) {
    final sousTotal = lignes.fold<int>(0, (s, l) => s + l.totalLigne);
    final reductionEffective = reduction.clamp(0, sousTotal);
    final total = sousTotal - reductionEffective;
    final acompteEffective = acompte.clamp(0, total);
    return DocumentTotals(
      sousTotal: sousTotal,
      reduction: reductionEffective,
      total: total,
      acompte: acompteEffective,
      solde: total - acompteEffective,
      paye: 0,
    );
  }

  /// Totaux d'une **facture** : le solde diminue à mesure que les
  /// paiements sont enregistrés (statut « payée » quand solde <= 0).
  static DocumentTotals facture({
    required List<DocumentLine> lignes,
    int reduction = 0,
    List<int> paiementsRecus = const [],
  }) {
    final paye = paiementsRecus.fold<int>(0, (s, p) => s + p);
    final sousTotal = lignes.fold<int>(0, (s, l) => s + l.totalLigne);
    final reductionEffective = reduction.clamp(0, sousTotal);
    final total = sousTotal - reductionEffective;
    return DocumentTotals(
      sousTotal: sousTotal,
      reduction: reductionEffective,
      total: total,
      acompte: 0,
      solde: total - paye,
      paye: paye,
    );
  }

  /// Acompte suggéré à partir d'un pourcentage (utilisé par les règles
  /// métier et le formulaire de devis).
  static int acompteSuggere(int total, int pourcentage) {
    if (pourcentage <= 0 || total <= 0) return 0;
    return ((total * pourcentage) / 100).round();
  }
}
