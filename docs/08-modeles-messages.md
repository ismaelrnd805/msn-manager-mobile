# 08 — Modèles de messages

Les modèles vivent dans la table `message_templates` (14 modèles de démo) et sont rendus par `TemplateEngine` (`lib/core/domain/template_engine.dart`), logique pure testée dans `test/template_engine_test.dart`.

## 1. Syntaxe des variables

`{{NOM_VARIABLE}}` (espaces tolérées : `{{ VAR }}`). Liste complète — `TemplateEngine.variablesDocumentees` :

| Variable | Contenu | Alimentée par |
|---|---|---|
| `{{PRENOM}}` | Premier mot du nom du client | `context(nomClientComplet: …)` |
| `{{NOM_CLIENT}}` | Nom complet du client | `context(nomClientComplet: …)` |
| `{{SERVICE}}` | Nom du service (`services.nom`) | écran compositeur |
| `{{REFERENCE}}` | Référence du document (REQ/DEV/CMD/FAC/PMT-année-séquence) | document courant |
| `{{MONTANT}}` | Montant formaté Ariary (`Formatters.ar`) | devis/facture/paiement |
| `{{DELAI}}` | Délai exprimé (jours ou date) | devis/service |
| `{{DATE}}` | Date du jour ou date contextuelle | compositeur |
| `{{SOLDE}}` | Reste à payer (`QuoteCalculator` : total - payé) | facture/devis |
| `{{LIEN}}` | Lien partagé (fichier, page) — optionnel | compositeur |

Le contexte est construit par `TemplateEngine.context(...)` : seul `nomClientComplet` est obligatoire, les paramètres absents ne créent pas de clé.

## 2. Les 14 catégories (`TemplateCategorie`, `core/domain/enums.dart`)

`accueil`, `demandeInfo` (Demande d'information), `presentationTarif`, `devis`, `confirmation`, `demandeAcompte`, `paiementRecu`, `demandeFichier`, `validation`, `correction`, `relance`, `livraison`, `solde`, `remerciement`.

Modèles de démo correspondants (`DemoData`) : `tpl_accueil` (ACCUEIL), `tpl_info` (DEMANDE_INFO), `tpl_tarif` (PRESENTATION_TARIF), `tpl_devis` (DEVIS), `tpl_confirmation` (CONFIRMATION), `tpl_acompte` (DEMANDE_ACOMPTE), `tpl_paiement_recu` (PAIEMENT_RECU), `tpl_fichiers` (DEMANDE_FICHIER), `tpl_validation` (DEMANDE_VALIDATION), `tpl_correction` (CORRECTION), `tpl_relance` (RELANCE), `tpl_livraison` (LIVRAISON), `tpl_solde` (DEMANDE_SOLDE), `tpl_remerciement` (REMERCIEMENT). Chaque ligne porte aussi un `code` unique, un `titre`, un `corps`, `actif` et un `ordre`.

## 3. Créer / modifier un modèle (via l'app, admin)

1. Se connecter en admin (`AppPermissions.canEditTemplates`).
2. **Administration > Modèles de messages** (route `/settings/templates`, `AdminTemplatesScreen`) ou **Plus > Modèles de messages** (`/communication/templates`) pour la consultation/composition.
3. Créer : saisir titre, catégorie, corps ; les variables sont insérées telles quelles (`{{PRENOM}}`…).
4. Modifier/désactiver : le champ `actif` permet de retirer un modèle des listes sans le perdre ; `updatedAt` est rafraîchi à chaque édition.

Les modèles sont des données, pas du code : aucune recompilation n'est nécessaire et la modification est journalisée.

## 4. Rendu et variables manquantes

```dart
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
```

Comportement par défaut (`keepUnknown = true`) : une variable **manquante ou vide reste visible** sous forme `{{VAR}}`. L'opérateur la voit dans le compositeur avant l'envoi et la corrige à la main — aucune phrase tronquée du type « Bonjour , ». Les variables présentes dans le corps sont listables au préalable : `TemplateEngine.variablesIn(corps)`.

## 5. Exemple complet

Modèle `tpl_acompte` (catégorie « Demande d'acompte ») :

```
Bonjour {{PRENOM}}, pour démarrer votre commande {{REFERENCE}}, nous avons
besoin d'un acompte de {{MONTANT}}.

MVola : 034 00 000 00
Orange Money : 032 00 000 00
Airtel Money : 033 00 000 00

Dès réception, la production commence. Reste à payer après livraison : {{SOLDE}}.
```

Contexte fourni par l'écran de commande :

```dart
final values = TemplateEngine.context(
  nomClientComplet: 'Jean Rakoto',
  reference: 'CMD-2026-0001',
  montant: '60 000 Ar',
  solde: '90 000 Ar',
);
final message = TemplateEngine.render(corps, values);
```

Résultat envoyé :

```
Bonjour Jean, pour démarrer votre commande CMD-2026-0001, nous avons
besoin d'un acompte de 60 000 Ar.

MVola : 034 00 000 00
Orange Money : 032 00 000 00
Airtel Money : 033 00 000 00

Dès réception, la production commence. Reste à payer après livraison : 90 000 Ar.
```

Si `{{LIEN}}` avait figuré dans le corps sans être fournie, elle serait apparue littéralement `{{LIEN}}` dans le message — à corriger avant envoi. Le message rendu est ensuite copiable (`CopyMessageCard`) ou partagé via `ShareService.shareText`.
