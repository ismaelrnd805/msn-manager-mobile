/// Traducteur français → malagasy fondé sur le dictionnaire administrable.
///
/// Principe : les termes du dictionnaire (les plus longs d'abord) sont
/// remplacés dans le texte. Les mots inconnus restent en français — le
/// dictionnaire se complète progressivement depuis l'administration.
library;

import '../database/app_database.dart';

class DictionaryTranslator {
  DictionaryTranslator._();

  /// Traduit [texte] en remplaçant chaque terme du dictionnaire actif.
  ///
  /// [entries] est chargé par l'appelant (templatesDao.activeDictionary()).
  /// Le remplacement est insensible à la casse pour le terme français ;
  /// la casse de départ (majuscule initiale) est conservée quand possible.
  static String translate(String texte, List<DictionaryEntry> entries) {
    if (texte.isEmpty || entries.isEmpty) return texte;
    var result = texte;
    // Les termes les plus longs d'abord (évite « devis » avant
    // « devis détaillé »).
    final sorted = [...entries]
      ..sort((a, b) => b.termeFr.length.compareTo(a.termeFr.length));
    for (final e in sorted) {
      final fr = e.termeFr.trim();
      if (fr.isEmpty) continue;
      result = result.replaceAllMapped(
        RegExp(RegExp.escape(fr), caseSensitive: false),
        (match) => _preserveCase(match.group(0)!, e.traductionMg),
      );
    }
    return result;
  }

  /// Conserve la majuscule initiale si le texte source en avait une.
  static String _preserveCase(String source, String replacement) {
    if (source.isEmpty) return source;
    if (source[0] == source[0].toUpperCase() &&
        source[0] != source[0].toLowerCase()) {
      return replacement[0].toUpperCase() + replacement.substring(1);
    }
    return replacement;
  }

  /// Taux de couverture estimé : proportion de mots du texte trouvés
  /// dans le dictionnaire (0.0 → 1.0). Utilisé pour afficher un indicateur
  /// de qualité de traduction à l'opérateur.
  static double coverage(String texte, List<DictionaryEntry> entries) {
    final words = texte
        .toLowerCase()
        .replaceAll(RegExp(r'[^\wàâäéèêëîïôöùûüçñ\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2)
        .toSet();
    if (words.isEmpty) return 1;
    final knownFr = entries.map((e) => e.termeFr.toLowerCase()).toSet();
    var hits = 0;
    for (final w in words) {
      if (knownFr.any((k) => k.contains(w) || w.contains(k))) hits++;
    }
    return hits / words.length;
  }
}
