/// Aperçu et ouverture des fichiers — images, TXT et PDF s'affichent
/// directement dans l'application ; tout autre type s'ouvre avec
/// l'application Android appropriée. Actions : partager, ouvrir
/// à l'externe, suppression.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/services_providers.dart';
import '../../core/theme/msn_theme.dart';
import '../../shared/widgets/feedback.dart';

class FileViewerScreen extends ConsumerWidget {
  const FileViewerScreen({super.key, required this.file});

  final OrderFile file;

  bool get _isImage => ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp']
      .contains((file.mime ?? '').toLowerCase());

  bool get _isTxt => (file.mime ?? '').toLowerCase() == 'txt';

  bool get _isPdf => (file.mime ?? '').toLowerCase() == 'pdf';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = file.cheminLocal;
    final exists = path != null && File(path).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: Text(file.nom, style: const TextStyle(fontSize: 16)),
        actions: [
          if (exists && !_isImage && !_isTxt && !_isPdf)
            IconButton(
              icon: const Icon(Icons.open_in_new),
              tooltip: 'Ouvrir avec une application externe',
              onPressed: () => _openExternally(context, ref),
            ),
          if (exists)
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Partager',
              onPressed: () async {
                await ref
                    .read(shareServiceProvider)
                    .shareFile(path, subject: file.nom);
              },
            ),
        ],
      ),
      body: !exists
          ? const Center(
              child: Text('Fichier introuvable sur l\'appareil.',
                  style: TextStyle(color: MsnColors.textSecondary)))
          : _body(context, ref, path),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, String path) {
    if (_isImage) {
      return InteractiveViewer(
        maxScale: 6,
        child: Center(child: Image.file(File(path))),
      );
    }
    if (_isPdf) {
      return PdfPreview(
        build: (format) => File(path).readAsBytesSync(),
        pdfFileName: file.nom,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
      );
    }
    if (_isTxt) {
      return FutureBuilder<String>(
        future: File(path).readAsString(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              snapshot.data!,
              style: const TextStyle(
                  fontSize: 14.5, height: 1.5, fontFamilyFallback: ['monospace']),
            ),
          );
        },
      );
    }
    // Type non affichable dans l'app : proposition d'ouverture externe.
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.description_outlined,
                size: 56, color: MsnColors.textSecondary),
            const SizedBox(height: 14),
            Text(file.nom,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 6),
            Text(
              'Ce type de fichier ne peut pas être affiché ici. '
              'Ouvrez-le avec une application du téléphone ou partagez-le.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12.5,
                  color: MsnColors.textSecondary.withValues(alpha: 0.9)),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _openExternally(context, ref),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('OUVRIR AVEC UNE APPLICATION'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openExternally(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(fileIngestServiceProvider).openExternally(file);
    } catch (e) {
      if (context.mounted) {
        showMsnSnack(context, e.toString(), error: true);
      }
    }
  }
}
