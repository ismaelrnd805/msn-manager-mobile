/// Moteur de modèles de messages avec substitution automatique de variables.
///
/// Syntaxe : {{PRENOM}}, {{NOM_CLIENT}}, {{SERVICE}}, {{REFERENCE}},
/// {{MONTANT}}, {{DELAI}}, {{DATE}}, {{SOLDE}}, {{LIEN}}.
///
/// Les variables inconnues sont conservées telles quelles afin que
/// l'opérateur les voie et les corrige avant l'envoi.
library;

class TemplateEngine {
  TemplateEngine._();

  static final RegExp _variable = RegExp(r'\{\{\s*([A-Za-z_]+)\s*\}\}');

  /// Toutes les variables présentes dans un corps de modèle.
  static List<String> variablesIn(String corps) =>
      _variable.allMatches(corps).map((m) => m.group(1)!).toSet().toList();

  /// Rendu : remplace chaque {{VAR}} présente dans [values].
  static String render(
    String corps,
    Map<String, String> values, {
    bool keepUnknown = true,
  }) {
    return corps.replaceAllMapped(_variable, (match) {
      final key = match.group(1)!;
      final value = values[key];
      if (value == null || value.isEmpty) {
        return keepUnknown ? match.group(0)! : '';
      }
      return value;
    });
  }

  /// Construit le contexte standard à partir des données disponibles.
  /// Seuls les paramètres fournis alimentent le contexte.
  static Map<String, String> context({
    String? nomClientComplet,
    String? service,
    String? reference,
    String? montant,
    String? delai,
    String? date,
    String? solde,
    String? lien,
  }) {
    final nom = (nomClientComplet ?? '').trim();
    final prenom = nom.isEmpty ? '' : nom.split(RegExp(r'\s+')).first;
    return {
      if (nom.isNotEmpty) 'PRENOM': prenom,
      if (nom.isNotEmpty) 'NOM_CLIENT': nom,
      if (service != null && service.isNotEmpty) 'SERVICE': service,
      if (reference != null && reference.isNotEmpty) 'REFERENCE': reference,
      if (montant != null && montant.isNotEmpty) 'MONTANT': montant,
      if (delai != null && delai.isNotEmpty) 'DELAI': delai,
      if (date != null && date.isNotEmpty) 'DATE': date,
      if (solde != null && solde.isNotEmpty) 'SOLDE': solde,
      if (lien != null && lien.isNotEmpty) 'LIEN': lien,
    };
  }

  /// Liste documentée des variables disponibles pour l'éditeur de modèles.
  static const List<String> variablesDocumentees = [
    'PRENOM',
    'NOM_CLIENT',
    'SERVICE',
    'REFERENCE',
    'MONTANT',
    'DELAI',
    'DATE',
    'SOLDE',
    'LIEN',
  ];
}
