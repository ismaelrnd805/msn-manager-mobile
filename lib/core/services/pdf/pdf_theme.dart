/// Chart graphique des documents PDF MSN (en-tête, pied de page, styles).
///
/// v4 — refonte de la mise en page pour la lisibilité MOBILE :
/// - logo posé sur un fond blanc (plus d'image « collée » au fond coloré) ;
/// - textes agrandis (base 10.5–12 pt, cellules de tableaux 10.5 pt) ;
/// - espacements et interlignes généreux ;
/// - pagination « Page X / Y » en pied de page.
///
/// Le logo est chargé depuis assets/logo/msn_logo.png ; le remplacer ne
/// nécessite aucune modification de ce code.
library;

import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class MsnPdfTheme {
  MsnPdfTheme._();

  static const PdfColor primary = PdfColor.fromInt(0xFF0B4FA8);
  static const PdfColor primaryDark = PdfColor.fromInt(0xFF083B7F);
  static const PdfColor accent = PdfColor.fromInt(0xFF00B8D4);
  static const PdfColor lightBg = PdfColor.fromInt(0xFFF2F6FC);
  static const PdfColor textDark = PdfColor.fromInt(0xFF16222F);
  static const PdfColor textMuted = PdfColor.fromInt(0xFF5B6B7C);
  static const PdfColor success = PdfColor.fromInt(0xFF2E7D32);

  /// Marges de page standard (lisibilité smartphone, A5 inclus).
  static const pw.EdgeInsets pageMargin = pw.EdgeInsets.fromLTRB(28, 24, 28, 28);

  /// Taille de texte de base des documents.
  static const double baseFontSize = 11;

  static Uint8List? _logoCache;

  /// Logo MSN mis en cache pour tous les documents.
  static Future<Uint8List?> logoBytes() async {
    _logoCache ??= await _tryLoad('assets/logo/msn_logo.png');
    return _logoCache;
  }

  static Future<Uint8List?> _tryLoad(String path) async {
    try {
      return await rootBundle.load(path).then((d) => d.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }

  /// Logo posé sur un fond BLANC avec coins arrondis et liseré : lisible
  /// sur n'importe quel fond d'en-tête (exigence fond blanc).
  static pw.Widget logoWidget(Uint8List? logo, {double size = 56}) {
    return pw.Container(
      width: size,
      height: size,
      padding: const pw.EdgeInsets.all(4),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
      ),
      child: logo == null
          ? pw.Center(
              child: pw.Text('MSN',
                  style: pw.TextStyle(
                      color: primary,
                      fontSize: size * 0.26,
                      fontWeight: pw.FontWeight.bold)),
            )
          : pw.ClipRRect(
              horizontalRadius: 8,
              verticalRadius: 8,
              child: pw.Image(pw.MemoryImage(logo), fit: pw.BoxFit.contain),
            ),
    );
  }

  /// En-tête standard : logo + raison sociale + titre du document.
  /// Le logo doit être préchargé via [logoBytes] avant la construction
  /// du document (les callbacks de page de pdf sont synchrones).
  static pw.Widget header(
    String title,
    String subtitle, {
    required Uint8List? logo,
    required String companyName,
    required String contact,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 16),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: primary, width: 2)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Container(margin: const pw.EdgeInsets.only(right: 14), child: logoWidget(logo)),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(companyName,
                    style: const pw.TextStyle(
                        fontSize: 12.5,
                        color: textMuted,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 3),
                pw.Text(title,
                    style: const pw.TextStyle(
                        fontSize: 22,
                        color: textDark,
                        fontWeight: pw.FontWeight.bold)),
                if (subtitle.isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 3),
                    child: pw.Text(subtitle,
                        style: const pw.TextStyle(
                            fontSize: 11, color: textMuted)),
                  ),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              for (final ligne in contact.split(' | '))
                pw.Text(ligne,
                    style: const pw.TextStyle(
                        fontSize: 9.5, color: textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  /// Pied de page : mention + numéro de page.
  static pw.Widget footer(pw.Context context, String companyName) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border:
            pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Document généré par MSN Manager — $companyName',
              style: const pw.TextStyle(fontSize: 8.5, color: textMuted)),
          pw.Text(
              'Page ${context.pageNumber} / ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8.5, color: textMuted)),
        ],
      ),
    );
  }

  /// Titre de section (espacé, lisible).
  static pw.Widget sectionTitle(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
      child: pw.Text(text.toUpperCase(),
          style: const pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: primaryDark,
              letterSpacing: 0.6)),
    );
  }

  /// Bloc « encadré » réutilisable (référence, totaux, conditions…).
  static pw.Widget box({
    required String title,
    required List<(String, String)> rows,
    PdfColor? color,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: color ?? lightBg,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style: const pw.TextStyle(
                  fontSize: 11.5,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryDark)),
          pw.SizedBox(height: 8),
          ...rows.map((r) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(r.$1,
                        style: const pw.TextStyle(
                            fontSize: baseFontSize, color: textMuted)),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: pw.Text(r.$2,
                          textAlign: pw.TextAlign.right,
                          style: const pw.TextStyle(
                              fontSize: baseFontSize,
                              fontWeight: pw.FontWeight.bold,
                              color: textDark)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// Bloc CONDITIONS : une ligne par condition, aérée (lisibilité mobile).
  static pw.Widget conditions(List<String> lignes) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: lightBg,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('CONDITIONS',
              style: const pw.TextStyle(
                  fontSize: 11.5,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryDark)),
          pw.SizedBox(height: 6),
          for (final l in lignes)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 5),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('• ',
                      style: const pw.TextStyle(
                          fontSize: baseFontSize, color: primary)),
                  pw.Expanded(
                    child: pw.Text(l,
                        style: const pw.TextStyle(
                            fontSize: baseFontSize,
                            color: textDark,
                            lineSpacing: 3)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Tableau des lignes d'un devis/facture : en-tête coloré, cellules
  /// aérées, tailles lisibles.
  static pw.Widget itemsTable({
    required List<(String, String, String)> rows, // désignation, qté, total
    required List<String> headers,
  }) {
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows.map((r) => [r.$1, r.$2, r.$3]).toList(),
      headerStyle: const pw.TextStyle(
          fontSize: 10.5,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: primary),
      cellStyle: const pw.TextStyle(fontSize: baseFontSize, color: textDark),
      cellAlignment: pw.Alignment.centerLeft,
      headerAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.symmetric(vertical: 7, horizontal: 8),
      columnWidths: {
        0: const pw.FlexColumnWidth(5),
        1: const pw.FlexColumnWidth(2),
        headers.length - 1: const pw.FlexColumnWidth(3),
      },
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey50),
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
    );
  }

  /// Bandeau de statut coloré (ex. « DEVIS », « FACTURE PAYÉE »).
  static pw.Widget badge(String text, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Text(
        text.toUpperCase(),
        style: const pw.TextStyle(
            color: PdfColors.white,
            fontSize: 10,
            fontWeight: pw.FontWeight.bold),
      ),
    );
  }
}
