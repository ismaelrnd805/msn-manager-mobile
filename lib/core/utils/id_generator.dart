/// Génération et formatage des références documentaires :
/// REQ-2026-0001, DEV-2026-0001, CMD-2026-0042, FAC-2026-0001, PMT-2026-0001.
///
/// Les compteurs sont persistés dans la table `settings` par [NumberingService] ;
/// ce module contient la partie pure (testable sans base de données).
library;

class IdGenerator {
  IdGenerator._();

  /// Clé de compteur pour un préfixe et une année donnés.
  static String counterKey(String prefix, int year) => 'counter_${prefix}_$year';

  /// Formate une référence complète : formatReference('REQ', 2026, 1) -> REQ-2026-0001.
  static String formatReference(String prefix, int year, int sequence) {
    return '${prefix.toUpperCase()}-$year-${sequence.toString().padLeft(4, '0')}';
  }

  /// Extrait l'année d'une référence existante (null si format inconnu).
  static int? yearOf(String reference) {
    final parts = reference.split('-');
    if (parts.length != 3) return null;
    return int.tryParse(parts[1]);
  }
}
