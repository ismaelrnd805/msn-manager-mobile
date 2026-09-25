# 09 — Formats de présentation (message / image / PDF)

Un même contenu client (fiche service, catalogue, devis, facture) est présenté sous **trois formats** cohérents : texte copiable, image PNG rastérisée, PDF professionnel.

## 1. Les trois formats

| Format | Génération | Usage |
|---|---|---|
| MESSAGE | Texte rendu par `TemplateEngine` (modèles `message_templates`), affiché copiable (`shared/widgets/copy_message_card.dart`) et partagé par `ShareService.shareText` | Collé dans Messenger/WhatsApp/SMS |
| IMAGE | Rastérisation de la 1re page du PDF : `Printing.raster(pdfBytes, dpi: 150).toList()` puis `page.toPng()` (`PdfService.rasterizeFirstPage`) | Envoi direct en photo dans les messageries |
| PDF | Package `pdf` (`pw.Document`), mise en page `core/services/pdf/pdf_theme.dart` (en-tête logo, pied, tableaux, boîtes) | Document officiel (devis, facture, catalogue) |

## 2. Cohérence des données entre formats

Les trois formats partagent la **même source** : la base locale et les calculateurs purs.

- Les totaux d'un PDF sont calculés par `QuoteCalculator.devis(...)` / `QuoteCalculator.facture(...)` à partir des lignes en base (`quote_items`, `invoice_items`) — le même calcul que l'écran et les messages `{{MONTANT}}` / `{{SOLDE}}`.
- L'image est une rastérisation du PDF lui-même : contenu strictement identique.
- Les infos société (nom, téléphone, email) viennent des clés `settings` (`company_name`, `company_phone`, `company_email`) via `PdfService.companyInfo()` : changer le téléphone met à jour tous les documents suivants.

En-tête de `pdf_service.dart` : « Les trois formats (message / image / PDF) partagent les mêmes données : si le tarif change, tout se met à jour automatiquement. »

## 3. Où vit le code

```
lib/core/services/pdf/
  pdf_service.dart   # PdfService : serviceSheet, catalog, quote, invoice,
                     # rasterizeFirstPage, _save, companyInfo
  pdf_theme.dart     # MsnPdfTheme : header, footer, badge, box, couleurs,
                     # logoBytes (assets/logo/msn_logo.png)
lib/core/services/share_service.dart   # ShareService.shareText / shareFile
lib/shared/widgets/copy_message_card.dart  # carte « copier le message »
```

Points techniques :
- Sortie écrite sous `<documents>/msn_manager/documents/{REFERENCE}/DOCUMENTS/<nom>.pdf` via `BackupService.generatedDirectory(reference)` ; l'écran `/documents` liste ce dossier.
- Noms de fichiers sluggifiés sans accents (`_slug`) : `fiche_creation_de_logo.pdf`, `devis_DEV-2026-0001.pdf`, `facture_FAC-2026-0001.pdf`, `catalogue_msn.pdf`.
- Le partage fichier passe par `share_plus` (`Share.shareXFiles`) : l'opérateur choisit l'application cible (Messenger, WhatsApp, email…). Aucun envoi n'est effectué par l'app elle-même.
- Format A4, marges 32, tableaux `pw.TableHelper.fromTextArray` stylés avec `MsnPdfTheme.primary` (#0B4FA8).

## 4. Ajouter un nouveau document (méthode)

Suivre le motif de `PdfService.quote` :

```dart
Future<File> bonDeCommande({required Order order, required Client client}) async {
  final info = await companyInfo();                  // infos société (settings)
  final logo = await MsnPdfTheme.logoBytes();
  final doc = pw.Document();

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (ctx) => MsnPdfTheme.header('Bon de commande ${order.reference}', '',
          logo: logo, companyName: info.nom, contact: info.contactLine),
      footer: (ctx) => MsnPdfTheme.footer(ctx, info.nom),
      build: (ctx) => [
        pw.Text(client.nom),                          // contenu métier
        // MsnPdfTheme.box(...), pw.TableHelper.fromTextArray(...)…
      ],
    ),
  );
  return _save(doc, 'bon_${order.reference}');        // écriture + chemin
}
```

Règles :
1. Lire **toutes** les données depuis la base (aucun paramètre UI) : les trois formats restent alignés.
2. Réutiliser les totaux de `QuoteCalculator` au lieu de recalculer localement.
3. Retourner le `File` produit (l'écran déclenche ensuite `ShareService.shareFile` et, si besoin, `rasterizeFirstPage` pour la variante image).

## 5. Ajouter un nouveau format

Un format = une transformation du même contenu :
- format texte : écrire un (ou réutiliser un) modèle de message et le rendre avec `TemplateEngine.render` ;
- format image : générer d'abord le PDF puis passer par `rasterizeFirstPage` (le DPI 150 est un bon compromis poids/lisibilité pour WhatsApp) ;
- tout nouveau canal de sortie (impression directe `Printing.layoutPdf`, envoi email…) s'ajoute dans `ShareService` ou un service voisin, sans toucher à la construction des documents.

Les fichiers générés restent locaux et fonctionnent hors connexion ; leur listing (`/documents`) et leur partage ne dépendent d'aucun service distant.
