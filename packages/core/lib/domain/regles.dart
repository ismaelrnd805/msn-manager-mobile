// Règles métier du domaine — miroir Dart des règles serveur (spéc. §4.2, §6, §9).
// Montants : entiers Ariary (jamais de flottant). Quantités : décimal exact en chaîne.
library;

/// Transitions autorisées par machine à états (identiques au serveur App\Domain\Statuts).
class Statuts {
  static const demande = {
    'a_qualifier': ['offre_presentee', 'devis_a_preparer', 'perdue'],
    'offre_presentee': ['en_attente_client', 'devis_a_preparer', 'perdue'],
    'en_attente_client': ['devis_a_preparer', 'perdue', 'offre_presentee'],
    'devis_a_preparer': ['gagnee', 'perdue', 'offre_presentee'],
    'gagnee': <String>[],
    'perdue': <String>[],
  };

  static const devis = {
    'brouillon': ['presente'],
    'presente': ['modification_demandee', 'accepte', 'refuse', 'expire'],
    'modification_demandee': ['remplace'],
    'accepte': <String>[],
    'refuse': <String>[],
    'expire': <String>[],
    'remplace': <String>[],
  };

  static const commande = {
    'en_preparation': ['en_attente_validation', 'validee', 'annulee'],
    'en_attente_validation': ['validee', 'annulee'],
    'validee': ['en_production', 'annulee'],
    'en_production': ['en_correction', 'livree', 'annulee'],
    'en_correction': ['en_production', 'livree'],
    'livree': <String>[],
    'annulee': <String>[],
  };

  static const facture = {
    'brouillon': ['emise', 'annulee'],
    'emise': ['partiellement_payee', 'payee', 'annulee'],
    'partiellement_payee': ['payee'],
    'payee': <String>[],
    'annulee': <String>[],
  };

  static const echange = {
    'brouillon': ['prete', 'echec'],
    'prete': ['copiee', 'envoi_manuel_confirme', 'envoi_integration_confirme', 'echec'],
    'copiee': ['envoi_manuel_confirme', 'echec'],
    'envoi_manuel_confirme': <String>[],
    'envoi_integration_confirme': <String>[],
    'echec': ['prete'],
  };

  static const projet = {
    'en_preparation': ['en_cours', 'annule'],
    'en_cours': ['en_correction', 'termine', 'annule'],
    'en_correction': ['en_cours', 'termine'],
    'termine': <String>[],
    'annule': <String>[],
  };

  static const publicationFacebook = {
    'planifie': ['prete', 'annule'],
    'prete': ['publie_manuellement', 'annule'],
    'publie_manuellement': <String>[],
    'annule': <String>[],
  };

  static bool transitionAutorisee(String domaine, String de, String vers) {
    final map = switch (domaine) {
      'demande' => demande,
      'devis' => devis,
      'commande' => commande,
      'facture' => facture,
      'echange' => echange,
      'projet' => projet,
      'publication_facebook' => publicationFacebook,
      _ => throw ArgumentError('Domaine inconnu : $domaine'),
    };
    return (map[de] ?? const <String>[]).contains(vers);
  }
}

/// Quantité décimale exacte : canonisation et produit monétaire entier (spéc. §10.B10).
class Quantite {
  final String canonique;

  Quantite._(this.canonique);

  /// Analyse et canonise : '60' → '60', '2,50' → '2.5', '0.500' → '0.5'.
  /// Lève ArgumentError si non décimal exact (3 décimales max).
  factory Quantite.de(dynamic valeur) {
    var s = valeur.toString().trim().replaceAll(',', '.');
    if (!RegExp(r'^\d+(\.\d{1,3})?$').hasMatch(s)) {
      throw ArgumentError(
          'Quantité invalide : $valeur (décimale exacte requise, 3 chiffres max)');
    }
    if (double.parse(s) <= 0) {
      throw ArgumentError('Quantité nulle ou négative interdite : $valeur');
    }
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    }
    return Quantite._(s);
  }

  /// Montant = quantité × prix unitaire (entier MGA), arrondi documenté :
  /// arrondi bancaire sur la 3ᵉ décimale (half-up), toujours vers le pair le plus proche
  /// en cas de demi-unité exacte pour éviter le biais d'accumulation.
  int fois(int prixUnitaire) {
    if (!canonique.contains('.')) {
      return int.parse(canonique) * prixUnitaire;
    }
    final parties = canonique.split('.');
    final entier = BigInt.parse(parties[0]);
    final decimales = parties[1].padRight(3, '0').substring(0, 3);
    final milliemes = BigInt.parse(decimales); // 0..999
    // montant = (entier + millièmes/1000) × prix — arrondi half-up sur le millième
    final brut = (entier * BigInt.from(prixUnitaire)) * BigInt.from(1000) +
        milliemes * BigInt.from(prixUnitaire);
    final quotient = brut ~/ BigInt.from(1000);
    final reste = brut % BigInt.from(1000);
    final doubleReste = reste * BigInt.from(2);
    return (doubleReste >= BigInt.from(1000) ? quotient + BigInt.one : quotient)
        .toInt();
  }

  @override
  String toString() => canonique;
}

/// Libellés français des statuts (les valeurs techniques ne sont jamais affichées).
class LibellesStatuts {
  static const demande = {
    'a_qualifier': 'À qualifier',
    'offre_presentee': 'Offre présentée',
    'en_attente_client': 'En attente du client',
    'devis_a_preparer': 'Devis à préparer',
    'gagnee': 'Gagnée',
    'perdue': 'Perdue',
  };

  static const devis = {
    'brouillon': 'Brouillon',
    'presente': 'Présenté',
    'modification_demandee': 'Modification demandée',
    'accepte': 'Accepté',
    'refuse': 'Refusé',
    'expire': 'Expiré',
    'remplace': 'Remplacé',
  };

  static const commande = {
    'en_preparation': 'En préparation',
    'en_attente_validation': 'En attente de validation',
    'validee': 'Validée',
    'en_production': 'En production',
    'en_correction': 'En correction',
    'livree': 'Livrée',
    'annulee': 'Annulée',
  };

  static const facture = {
    'brouillon': 'Brouillon',
    'emise': 'Émise',
    'partiellement_payee': 'Partiellement payée',
    'payee': 'Payée',
    'annulee': 'Annulée',
  };

  static const echange = {
    'brouillon': 'Brouillon',
    'prete': 'Prêt à copier',
    'copiee': 'Copié',
    'envoi_manuel_confirme': 'Envoyé (confirmé)',
    'envoi_integration_confirme': 'Envoyé (intégration)',
    'echec': 'Échec',
  };

  static String demandeStatut(String code) => demande[code] ?? code;
  static String devisStatut(String code) => devis[code] ?? code;
  static String commandeStatut(String code) => commande[code] ?? code;
  static String factureStatut(String code) => facture[code] ?? code;
  static String echangeStatut(String code) => echange[code] ?? code;
}

/// Formateur de montants en Ariary (séparateurs d'espaces fines).
String formatMga(int montant) {
  final s = montant.abs().toString();
  final tampon = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    tampon.write(s[i]);
    final restant = s.length - i - 1;
    if (restant > 0 && restant % 3 == 0) tampon.write(' ');
  }
  return '${montant < 0 ? '-' : ''}${tampon.toString()} Ar';
}

/// Solde d'une facture : total − paiements confirmés uniquement (spec §6.H).
int soldeFacture({
  required int totalFacture,
  required List<Map<String, Object?>> paiements,
}) {
  final encaisse = paiements
      .where((p) => p['statut'] == 'confirme' && p['deleted_at'] == null)
      .fold<int>(0, (somme, p) => somme + (p['montant'] as int));
  return (totalFacture - encaisse) < 0 ? 0 : totalFacture - encaisse;
}

/// Statut financier calculé (jamais éditable librement) — spec §9 règle 12.
String statutFinancierCalcule(int total, List<Map<String, Object?>> paiements) {
  final encaisse = paiements
      .where((p) => p['statut'] == 'confirme' && p['deleted_at'] == null)
      .fold<int>(0, (somme, p) => somme + (p['montant'] as int));
  if (encaisse >= total && total > 0) return 'payee';
  if (encaisse > 0) return 'partiellement_payee';
  return 'emise';
}
