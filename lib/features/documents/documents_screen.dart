/// Hub des documents générés — les PDF/images produits par l'app
/// sont enregistrés hors ligne et partageables à tout moment.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/services_providers.dart';
import '../../core/services/backup_service.dart';
import '../../core/theme/msn_theme.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/feedback.dart';

/// Écran simple et honnête : liste des fichiers du dossier documents
/// de l'application, avec partage. Les nouveaux documents générés
/// (devis, factures, fiches) y apparaissent automatiquement.
class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  List<File> _files = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final dir = await BackupService.generatedDirectory('MSN');
      if (dir.existsSync()) {
        final list = dir
            .listSync()
            .whereType<File>()
            .where((f) =>
                f.path.endsWith('.pdf') || f.path.endsWith('.png'))
            .toList()
          ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
        _files = list;
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents générés'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _loading = true);
              _load();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _files.isEmpty
              ? const EmptyState(
                  icon: Icons.folder_open,
                  title: 'Aucun document généré',
                  message:
                      'Les PDF et images créés depuis les devis, factures et '
                      'fiches services apparaîtront ici.',
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _files.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final f = _files[index];
                      final isPdf = f.path.endsWith('.pdf');
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            isPdf
                                ? Icons.picture_as_pdf
                                : Icons.image,
                            color: isPdf ? MsnColors.danger : MsnColors.accent,
                          ),
                          title: Text(
                            f.uri.pathSegments.last,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                          subtitle: Text(
                            '${Formatters.dateTime(f.lastModifiedSync())} · '
                            '${(f.lengthSync() / 1024).round()} Ko',
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.share, size: 18),
                            onPressed: () => ref
                                .read(shareServiceProvider)
                                .shareFile(f.path),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
