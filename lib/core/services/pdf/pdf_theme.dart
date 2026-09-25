/// Chart graphique des documents PDF MSN (en-tête, pied de page, styles).
///
/// Le logo placeholder est chargé depuis assets/logo/msn_logo.png ;
/// il sera remplacé par le logo officiel sans modifier ce code.
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

  static Uint8List? _logoCache;

  /// Logo MSN (placeholder) mis en cache pour tous les documents.
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
      padding: const pw.EdgeInsets.only(bottom: 14),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: primary, width: 2)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (logo != null)
            pw.Container(
              width: 46,
              height: 46,
              margin: const pw.EdgeInsets.only(right: 12),
              child: pw.Image(pw.MemoryImage(logo)),
            )
          else
            pw.Container(
              width: 46,
              height: 46,
              alignment: pw.Alignment.center,
              decoration: const pw.BoxDecoration(
                color: primary,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Text(
                'MSN',
                style: const pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(companyName,
                    style: const pw.TextStyle(
                        fontSize: 12,
                        color: textMuted,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 2),
                pw.Text(title,
                    style: const pw.TextStyle(
                        fontSize: 20,
                        color: textDark,
                        fontWeight: pw.FontWeight.bold)),
                if (subtitle.isNotEmpty)
                  pw.Text(subtitle,
                      style: const pw.TextStyle(
                          fontSize: 10, color: textMuted)),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(contact.split(' | ').first,
                  style: const pw.TextStyle(fontSize: 9, color: textMuted)),
              if (contact.contains(' | '))
                pw.Text(contact.split(' | ').last,
                    style: const pw.TextStyle(fontSize: 9, color: textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  /// Pied de page : mention + numéro de page.
  static pw.Widget footer(pw.Context context, String companyName) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border:
            pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Document généré par MSN Manager — $companyName',
              style: const pw.TextStyle(fontSize: 8, color: textMuted)),
          pw.Text(
              'Page ${context.pageNumber} / ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: textMuted)),
        ],
      ),
    );
  }

  /// Bloc « encadré » réutilisable (référence, totaux, conditions…).
  static pw.Widget box({
    required String title,
    required List<(String, String)> rows,
    PdfColor? color,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: color ?? lightBg,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style: const pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryDark)),
          pw.SizedBox(height: 6),
          ...rows.map((r) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(r.$1,
                        style:
                            const pw.TextStyle(fontSize: 9, color: textMuted)),
                    pw.Text(r.$2,
                        style: const pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: textDark)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// Bandeau de statut coloré (EX: « DEVIS », « FACTURE PAYÉE »).
  static pw.Widget badge(String text, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        text.toUpperCase(),
        style: const pw.TextStyle(
            color: PdfColors.white,
            fontSize: 9,
            fontWeight: pw.FontWeight.bold),
      ),
    );
  }
}
