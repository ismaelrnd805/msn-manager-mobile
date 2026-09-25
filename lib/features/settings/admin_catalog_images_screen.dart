/// Administration — catalogues importés en image (CRUD).
///
/// L'administration importe des catalogues en image (photos, scans) qui
/// servent de support de présentation ; elles restent stockées localement
/// (100% offline) et peuvent être partagées aux clients.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/services_providers.dart';
import '../../core/domain/enums.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/feedback.dart';
import '../../core/theme/msn_theme.dart';
import '../../shared/widgets/form_fields.dart';

final _catalogImagesProvider = StreamProvider<List<CatalogImage>>((ref) {
  return ref.watch(catalogDaoProvider).watchCatalogImages();
});

class AdminCatalogImagesScreen extends ConsumerWidget {
  const AdminCatalogImagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = ref.watch(_catalogImagesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Catalogues en image')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _import(context, ref),
        icon: const Icon(Icons.upload_file),
        label: const Text('Importer des images'),
      ),
      body: images.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Erreur : $e',
                style: const TextStyle(color: MsnColors.danger))),
        data: (list) => list.isEmpty
            ? const EmptyState(
                icon: Icons.image_outlined,
                title: 'Aucune image',
                message:
                    'Importez vos catalogues (photos ou scans) pour les '
                    'présenter et les partager aux clients.',
              )
            : GridView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.78,
                ),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final img = list[i];
                  final file = img.cheminLocal != null
                      ? File(img.cheminLocal!)
                      : null;
                  final exists = file?.existsSync() ?? false;
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _showPreview(context, ref, img),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: exists
                                ? Image.file(file!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.broken_image_outlined,
                                        size: 40))
                                : const Center(
                                    child: Icon(Icons.image_not_supported,
                                        size: 40)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(img.nom,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700)),
                                ),
                                if (!img.actif)
                                  const Icon(Icons.visibility_off,
                                      size: 14,
                                      color: MsnColors.textSecondary),
                                PopupMenuButton<String>(
                                  onSelected: (v) async {
                                    if (v == 'edit') {
                                      await _rename(context, ref, img);
                                    } else if (v == 'toggle') {
                                      await ref
                                          .read(catalogDaoProvider)
                                          .upsertCatalogImage(CatalogImage(
                                              id: img.id,
                                              nom: img.nom,
                                              cheminLocal: img.cheminLocal,
                                              note: img.note,
                                              actif: !img.actif,
                                              ordre: img.ordre,
                                              createdAt: img.createdAt,
                                              updatedAt: DateTime.now()));
                                    } else if (v == 'delete') {
                                      await _delete(context, ref, img);
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Renommer')),
                                    PopupMenuItem(
                                        value: 'toggle',
                                        child: Text(img.actif
                                            ? 'Désactiver'
                                            : 'Activer')),
                                    const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Supprimer',
                                            style: TextStyle(
                                                color: MsnColors.danger))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final ingest = ref.read(fileIngestServiceProvider);
    try {
      final picked = await ingest.pickCatalogImages();
      if (picked.isEmpty) return;
      var count = 0;
      final existing =
          await ref.read(catalogDaoProvider).watchCatalogImages().first;
      for (final f in picked) {
        final nom = f.uri.pathSegments.last.split('_').skip(2).join('_');
        await ingest.saveCatalogImage(
          imageFile: f,
          nom: nom.isEmpty ? 'Catalogue' : nom,
          ordre: existing.length + count,
        );
        count++;
      }
      await ref.read(activityLoggerProvider).log(
            action: ActivityAction.creation,
            entite: 'catalogue_image',
            details: '$count image(s) de catalogue importée(s).',
          );
      if (context.mounted) {
        showMsnSnack(context, '$count image(s) importée(s).');
      }
    } catch (e) {
      if (context.mounted) showMsnSnack(context, e.toString(), error: true);
    }
  }

  Future<void> _rename(BuildContext context, WidgetRef ref, CatalogImage img) async {
    final nom = TextEditingController(text: img.nom);
    final note = TextEditingController(text: img.note);
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
            18, 18, 18, 18 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Modifier l\'image',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 14),
            MsnTextField(label: 'Nom *', controller: nom, autofocus: true),
            MsnTextField(label: 'Note', controller: note, maxLines: 2),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('ENREGISTRER'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    if (nom.text.trim().isEmpty) {
      showMsnSnack(context, 'Le nom est obligatoire.', error: true);
      return;
    }
    await ref.read(catalogDaoProvider).upsertCatalogImage(CatalogImage(
          id: img.id,
          nom: nom.text.trim(),
          cheminLocal: img.cheminLocal,
          note: note.text.trim().isEmpty ? null : note.text.trim(),
          actif: img.actif,
          ordre: img.ordre,
          createdAt: img.createdAt,
          updatedAt: DateTime.now(),
        ));
    if (context.mounted) showMsnSnack(context, 'Image mise à jour.');
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, CatalogImage img) async {
    final ok = await confirmAction(context,
        title: 'Supprimer l\'image ?',
        message: '« ${img.nom} » sera retirée du catalogue.',
        danger: true);
    if (!ok) return;
    await ref.read(fileIngestServiceProvider).deleteCatalogImage(img);
    await ref.read(activityLoggerProvider).log(
          action: ActivityAction.suppression,
          entite: 'catalogue_image',
          entityId: img.id,
          details: 'Image « ${img.nom} » supprimée.',
        );
    if (context.mounted) showMsnSnack(context, 'Image supprimée.');
  }

  void _showPreview(BuildContext context, WidgetRef ref, CatalogImage img) {
    final path = img.cheminLocal;
    if (path == null || !File(path).existsSync()) {
      showMsnSnack(context, 'Fichier introuvable sur l\'appareil.',
          error: true);
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text(img.nom),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Partager',
              onPressed: () => ref
                  .read(shareServiceProvider)
                  .shareFile(path, subject: img.nom),
            ),
          ],
        ),
        body: Center(
          child: InteractiveViewer(
            maxScale: 5,
            child: Image.file(File(path)),
          ),
        ),
      ),
    ));
  }
}
