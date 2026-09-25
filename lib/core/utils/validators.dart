/// Validation des entrées utilisateur (formulaires).
library;

class Validators {
  Validators._();

  static String? required(String? value, {String label = 'Ce champ'}) {
    if (value == null || value.trim().isEmpty) {
      return '$label est obligatoire';
    }
    return null;
  }

  /// Téléphone malgache tolérant : +261 34 12 345 67 / 0341234567...
  static String? phone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null; // optionnel par défaut
    final digits = v.replaceAll(RegExp(r'[\s\-\.]'), '');
    final ok = RegExp(r'^(\+?261|0)(3[0-9]|20)\d{7,8}$').hasMatch(digits);
    if (!ok) return 'Numéro invalide (ex. 034 12 345 67)';
    return null;
  }

  static String? montant(String? value, {bool obligatoire = false}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      return obligatoire ? 'Montant obligatoire' : null;
    }
    final parsed = int.tryParse(v.replaceAll(RegExp(r'[\s\.]'), ''));
    if (parsed == null) return 'Montant invalide';
    if (parsed < 0) return 'Le montant doit être positif';
    return null;
  }

  static int? parseMontant(String? value) {
    if (value == null) return null;
    final v = value.trim().replaceAll(RegExp(r'[\s\.]'), '');
    if (v.isEmpty) return null;
    return int.tryParse(v);
  }
}
