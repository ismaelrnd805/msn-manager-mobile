/// Générateur de documents PDF professionnels : fiche service, catalogue,
/// devis, facture. Les trois formats (message / image / PDF) partagent les
/// mêmes données : si le tarif change, tout se met à jour automatiquement.
///
/// Les fichiers sont stockés hors ligne sous
/// msn_manager/documents/{REFERENCE}/DOCUMENTS/ puis partagés via le
/// partage natif. La rasterisation du PDF produit le format « image ».
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../database/app_database.dart';
import '../../database/daos/catalog_dao.dart';
import '../../database/daos/system_dao.dart';
import '../../domain/quote_calculator.dart';
import '../../utils/formatters.dart';
import '../backup_service.dart';
import 'pdf_theme.dart';

/// Informations société affichées sur les documents.
class MsnCompanyInfo {
  const MsnCompanyInfo({
    required this.nom,
    required this.telephone,
    required this.email,
  });

  final String nom;
  final String telephone;
  final String email;

  String get contactLine => '$telephone | $email';
}

class PdfService {
  PdfService(this._db);

  final AppDatabase _db;

  Future<MsnCompanyInfo> companyInfo() async {
    final system = SystemDao(_db);
    final nom =
        await system.getValue('company_name') ?? 'MSN Multi-Services Numériques';
    final tel = await system.getValue('company_phone') ?? '';
    final email = await system.getValue('company_email') ?? '';
    return MsnCompanyInfo(nom: nom, telephone: tel, email: email);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Fiche service (présentation d'un service au client)
  // ─────────────────────────────────────────────────────────────────────────

  Future<File> serviceSheet(ServiceWithCategory swc) async {
    final info = await companyInfo();
    final logo = await MsnPdfTheme.logoBytes();
    final s = swc.service;
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => MsnPdfTheme.header('Fiche service', s.nom,
            logo: logo, companyName: info.nom, contact: info.contactLine),
        footer: (ctx) => MsnPdfTheme.footer(ctx, info.nom),
        build: (ctx) => [
          pw.SizedBox(height: 12),
          pw.Text(s.nom,
              style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: MsnPdfTheme.textDark)),
          pw.SizedBox(height: 6),
          MsnPdfTheme.badge(swc.categoryNom, MsnPdfTheme.accent),
          pw.SizedBox(height: 16),
          if (s.description != null && s.description!.isNotEmpty)
            pw.Text(s.description!,
                style: const pw.TextStyle(
                    fontSize: 11, color: MsnPdfTheme.textDark, lineSpacing: 4)),
          pw.SizedBox(height: 20),
          MsnPdfTheme.box(title: 'Tarification', rows: [
            ('Prix', '${Formatters.ar(s.prixBase)} / ${s.unite}'),
            ('Délai', s.delaiJours == null ? 'À convenir' : '${s.delaiJours} jours'),
          ]),
          pw.SizedBox(height: 12),
          MsnPdfTheme.box(title: 'Ce qui est inclus', rows: [
            ('Inclus', s.inclus ?? '—'),
            ('Exclusions', s.exclusions ?? '—'),
            ('Conditions', s.conditions ?? '—'),
          ]),
          pw.SizedBox(height: 24),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: MsnPdfTheme.primary,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Intéressé(e) par ce service ?',
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text(
                    'Contactez-nous au ${info.telephone} ou par email : ${info.email}',
                    style: const pw.TextStyle(
                        color: PdfColors.white, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
    return _save(doc, 'fiche_${_slug(s.nom)}');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Catalogue complet
  // ─────────────────────────────────────────────────────────────────────────

  Future<File> catalog(List<ServiceWithCategory> services) async {
    final info = await companyInfo();
    final logo = await MsnPdfTheme.logoBytes();
    final doc = pw.Document();

    // Groupement par catégorie.
    final grouped = <String, List<ServiceWithCategory>>{};
    for (final swc in services) {
      grouped.putIfAbsent(swc.categoryNom, () => []).add(swc);
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => MsnPdfTheme.header(
            'Catalogue des services', '',
            logo: logo, companyName: info.nom, contact: info.contactLine),
        footer: (ctx) => MsnPdfTheme.footer(ctx, info.nom),
        build: (ctx) => [
          pw.SizedBox(height: 10),
          pw.Text(
              'Voici l’ensemble de nos services. Pour tout projet personnalisé, '
              'contactez-nous : nous établissons un devis gratuit.',
              style: const pw.TextStyle(
                  fontSize: 10, color: MsnPdfTheme.textMuted)),
          pw.SizedBox(height: 14),
          for (final entry in grouped.entries) ...[
            pw.Text(entry.key,
                style: pw.TextStyle(
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                    color: MsnPdfTheme.primary)),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(
                  color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 9),
              headerDecoration: const pw.BoxDecoration(
                  color: MsnPdfTheme.primary),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignment: pw.Alignment.centerLeft,
              headers: ['Service', 'Prix', 'Unité', 'Délai'],
              data: entry.value
                  .map((swc) => [
                        swc.service.nom,
                        Formatters.ar(swc.service.prixBase),
                        swc.service.unite,
                        swc.service.delaiJours == null
                            ? '—'
                            : '${swc.service.delaiJours} j',
                      ])
                  .toList(),
            ),
            pw.SizedBox(height: 14),
          ],
        ],
      ),
    );
    return _save(doc, 'catalogue_msn');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Devis
  // ─────────────────────────────────────────────────────────────────────────

  Future<File> quote({
    required Quote quote,
    required Client client,
    required List<QuoteItem> items,
  }) async {
    final info = await companyInfo();
    final logo = await MsnPdfTheme.logoBytes();
    final doc = pw.Document();
    final totals = QuoteCalculator.devis(
      lignes: items
          .map((i) => DocumentLine(
                designation: i.designation,
                quantite: i.quantite,
                prixUnitaire: i.prixUnitaire,
              ))
          .toList(),
      reduction: quote.reduction,
      acompte: quote.acompte,
    );
    final validite =
        quote.dateEmission.add(Duration(days: quote.validiteJours));

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => MsnPdfTheme.header('Devis ${quote.reference}', '',
            logo: logo, companyName: info.nom, contact: info.contactLine),
        footer: (ctx) => MsnPdfTheme.footer(ctx, info.nom),
        build: (ctx) => [
          pw.SizedBox(height: 12),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: MsnPdfTheme.box(title: 'Client', rows: [
                  ('Nom', client.nom),
                  ('Téléphone', client.telephone ?? '—'),
                  ('Email', client.email ?? '—'),
                ]),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: MsnPdfTheme.box(title: 'Devis', rows: [
                  ('Référence', quote.reference),
                  ('Date', Formatters.date(quote.dateEmission)),
                  ('Valable jusqu’au', Formatters.date(validite)),
                  ('Délai',
                      quote.delaiJours == null ? 'À convenir' : '${quote.delaiJours} jours'),
                ]),
              ),
            ],
          ),
          pw.SizedBox(height: 18),
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: MsnPdfTheme.primary),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignment: pw.Alignment.centerLeft,
            headers: ['Désignation', 'Qté', 'Prix unitaire', 'Total'],
            data: [
              for (final i in items)
                [
                  i.designation,
                  Formatters.qty(i.quantite),
                  Formatters.ar(i.prixUnitaire),
                  Formatters.ar((i.quantite * i.prixUnitaire).round()),
                ],
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.SizedBox(
                width: 220,
                child: MsnPdfTheme.box(title: 'Totaux', rows: [
                  ('Sous-total', Formatters.ar(totals.sousTotal)),
                  if (totals.reduction > 0)
                    ('Réduction', '- ${Formatters.ar(totals.reduction)}'),
                  ('TOTAL', Formatters.ar(totals.total)),
                  ('Acompte à la commande', Formatters.ar(totals.acompte)),
                  ('Solde après acompte', Formatters.ar(totals.solde)),
                ]),
              ),
            ],
          ),
          if (quote.conditions != null && quote.conditions!.isNotEmpty) ...[
            pw.SizedBox(height: 14),
            MsnPdfTheme.box(title: 'Conditions', rows: [
              ('', quote.conditions!),
            ]),
          ],
        ],
      ),
    );
    return _save(doc, 'devis_${quote.reference}');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Facture
  // ─────────────────────────────────────────────────────────────────────────

  Future<File> invoice({
    required Invoice invoice,
    required Client client,
    required List<InvoiceItem> items,
    required List<Payment> paiements,
  }) async {
    final info = await companyInfo();
    final logo = await MsnPdfTheme.logoBytes();
    final doc = pw.Document();
    final totals = QuoteCalculator.facture(
      lignes: items
          .map((i) => DocumentLine(
                designation: i.designation,
                quantite: i.quantite,
                prixUnitaire: i.prixUnitaire,
              ))
          .toList(),
      reduction: invoice.reduction,
      paiementsRecus: paiements.map((p) => p.montant).toList(),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => MsnPdfTheme.header('Facture ${invoice.reference}', '',
            logo: logo, companyName: info.nom, contact: info.contactLine),
        footer: (ctx) => MsnPdfTheme.footer(ctx, info.nom),
        build: (ctx) => [
          pw.SizedBox(height: 12),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: MsnPdfTheme.box(title: 'Client', rows: [
                  ('Nom', client.nom),
                  ('Téléphone', client.telephone ?? '—'),
                  ('Email', client.email ?? '—'),
                ]),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: MsnPdfTheme.box(title: 'Facture', rows: [
                  ('Référence', invoice.reference),
                  ('Date', Formatters.date(invoice.dateEmission)),
                  ('Échéance', Formatters.date(invoice.dateEcheance)),
                  ('Statut', invoice.statut.label),
                ]),
              ),
            ],
          ),
          pw.SizedBox(height: 18),
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: MsnPdfTheme.primary),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignment: pw.Alignment.centerLeft,
            headers: ['Désignation', 'Qté', 'Prix unitaire', 'Total'],
            data: [
              for (final i in items)
                [
                  i.designation,
                  Formatters.qty(i.quantite),
                  Formatters.ar(i.prixUnitaire),
                  Formatters.ar((i.quantite * i.prixUnitaire).round()),
                ],
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.SizedBox(
                width: 220,
                child: MsnPdfTheme.box(title: 'Totaux', rows: [
                  ('Sous-total', Formatters.ar(totals.sousTotal)),
                  if (totals.reduction > 0)
                    ('Réduction', '- ${Formatters.ar(totals.reduction)}'),
                  ('TOTAL', Formatters.ar(totals.total)),
                  ('Payé', Formatters.ar(totals.paye)),
                  ('SOLDE', Formatters.ar(totals.solde)),
                ]),
              ),
            ],
          ),
          if (paiements.isNotEmpty) ...[
            pw.SizedBox(height: 14),
            pw.Text('Historique des paiements',
                style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: MsnPdfTheme.primaryDark)),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 8),
              headerDecoration: const pw.BoxDecoration(
                  color: MsnPdfTheme.primaryDark),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellAlignment: pw.Alignment.centerLeft,
              headers: ['Date', 'Méthode', 'Référence', 'Montant'],
              data: paiements
                  .map((p) => [
                        Formatters.date(p.datePaiement),
                        p.methode.label,
                        p.referenceExterne ?? '—',
                        Formatters.ar(p.montant),
                      ])
                  .toList(),
            ),
          ],
        ],
      ),
    );
    return _save(doc, 'facture_${invoice.reference}');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Format 2 — IMAGE (rasterisation de la première page du PDF)
  // ─────────────────────────────────────────────────────────────────────────

  /// Convertit la première page d'un PDF en PNG prêt à partager.
  Future<Uint8List?> rasterizeFirstPage(Uint8List pdfBytes) async {
    try {
      final pages = await Printing.raster(pdfBytes, dpi: 150).toList();
      if (pages.isEmpty) return null;
      return await pages.first.toPng();
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Utilitaires
  // ─────────────────────────────────────────────────────────────────────────

  Future<File> _save(pw.Document doc, String baseName) async {
    final bytes = await doc.save();
    final dir = await BackupService.generatedDirectory('MSN');
    final file = File('${dir.path}/$baseName.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }

  static String _slug(String input) {
    final s = input
        .toLowerCase()
        .replaceAll(RegExp(r'[àâä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[îï]'), 'i')
        .replaceAll(RegExp(r'[ôö]'), 'o')
        .replaceAll(RegExp(r'[ùûü]'), 'u')
        .replaceAll(RegExp(r'ç'), 'c')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    return s.length > 40 ? s.substring(0, 40) : s;
  }
}
