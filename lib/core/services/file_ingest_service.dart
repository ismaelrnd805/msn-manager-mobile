/// Ingestion de fichiers : sélection (fichiers clients, images de
/// catalogue), copie locale (offline), enregistrement en base, ouverture
/// et suppression.
///
/// v4 :
/// - sélection MULTIPLE (plusieurs fichiers en une opération) ;
/// - ingestion des images de catalogue (dossier dédié) ;
/// - ouverture réelle : dans l'application quand possible (aperçu),
///   sinon via l'application Android appropriée (open_filex).
library;

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';
import '../domain/enums.dart';
import '../errors/app_exception.dart';

class FileIngestService {
  FileIngestService(this._db);

  final AppDatabase _db;

  /// Chemin des documents applicatif (résolu une seule fois par session).
  Future<String> _docsPath() async {
    _cachedDocsPath ??= (await getApplicationDocumentsDirectory()).path;
    return _cachedDocsPath!;
  }

  static String? _cachedDocsPath;

  /// Ouvre le sélecteur de fichiers (MULTI) et copie chaque fichier choisi
  /// dans l'arborescence locale. Renvoie les entrées créées (liste vide
  /// si annulé).
  Future<List<OrderFile>> pickAndAttach({
    required String? orderId,
    required String? requestId,
    required DossierFichier dossier,
    String? note,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: false,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return const [];

    final created = <OrderFile>[];
    final ref = orderId ?? requestId ?? 'MSN';
    final destDir = Directory(
        '${await _docsPath()}'
        '/msn_manager/documents/$ref/${dossier.label}');
    if (!destDir.existsSync()) {
      await destDir.create(recursive: true);
    }
    for (final picked in result.files) {
      if (picked.path == null) {
        throw const AppException('Fichier inaccessible.');
      }
      final source = File(picked.path!);
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final destPath =
          p.join(destDir.path, '${stamp}_${p.basename(source.path)}');
      await source.copy(destPath);

      final row = OrderFile(
        id: 'file_${DateTime.now().microsecondsSinceEpoch}_$stamp',
        orderId: orderId,
        requestId: requestId,
        dossier: dossier,
        nom: p.basename(source.path),
        cheminLocal: destPath,
        taille: await source.length(),
        mime: picked.extension,
        origine: 'mobile',
        note: note,
        createdAt: DateTime.now(),
      );
      await _db.into(_db.orderFiles).insert(row);
      created.add(row);
    }
    return created;
  }

  /// Sélectionne PLUSIEURS images de catalogue, les copie dans le dossier
  /// dédié et renvoie les lignes prêtes à être insérées (sans persister :
  /// l'écran admin valide nom/ordre avant enregistrement).
  Future<List<File>> pickCatalogImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: false,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return const [];
    final destDir =
        Directory('${await _docsPath()}/msn_manager/catalog_images');
    if (!destDir.existsSync()) {
      await destDir.create(recursive: true);
    }
    final copied = <File>[];
    for (final picked in result.files) {
      if (picked.path == null) continue;
      final source = File(picked.path!);
      final stamp = DateTime.now().microsecondsSinceEpoch;
      final destPath =
          p.join(destDir.path, 'catalog_${stamp}_${p.basename(source.path)}');
      await source.copy(destPath);
      copied.add(File(destPath));
    }
    return copied;
  }

  /// Enregistre une image de catalogue (ligne base) à partir du fichier
  /// copié localement.
  Future<CatalogImage> saveCatalogImage({
    required File imageFile,
    required String nom,
    String? note,
    int ordre = 0,
  }) async {
    final row = CatalogImage(
      id: 'cat_img_${DateTime.now().microsecondsSinceEpoch}',
      nom: nom,
      cheminLocal: imageFile.path,
      note: note,
      actif: true,
      ordre: ordre,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _db.into(_db.catalogImages).insert(row);
    return row;
  }

  /// Supprime un fichier (base + disque) après confirmation de l'UI.
  Future<void> deleteFile(OrderFile file) async {
    final path = file.cheminLocal;
    if (path != null) {
      final f = File(path);
      if (f.existsSync()) {
        await f.delete();
      }
    }
    await (_db.delete(_db.orderFiles)..where((t) => t.id.equals(file.id)))
        .go();
  }

  /// Supprime une image de catalogue (base + disque).
  Future<void> deleteCatalogImage(CatalogImage image) async {
    final path = image.cheminLocal;
    if (path != null) {
      final f = File(path);
      if (f.existsSync()) await f.delete();
    }
    await (_db.delete(_db.catalogImages)..where((t) => t.id.equals(image.id)))
        .go();
  }

  /// Le fichier peut-il être affiché directement dans l'application ?
  static bool canPreviewInApp(OrderFile file) {
    final ext = (file.mime ?? '').toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'txt', 'pdf']
        .contains(ext);
  }

  /// Ouvre le fichier :
  /// - images / TXT / PDF → l'écran d'aperçu in-app (retourné par l'UI) ;
  /// - tout le reste → l'application Android appropriée (open_filex).
  ///
  /// L'UI appelle [previewInApp] d'abord ; si le type n'est pas
  /// affichable, elle appelle [openExternally].
  Future<void> openExternally(OrderFile file) async {
    final path = file.cheminLocal;
    if (path == null) {
      throw const AppException(
          'Ce fichier n’a pas de copie locale (métadonnée uniquement).');
    }
    final f = File(path);
    if (!f.existsSync()) {
      throw const AppException('Fichier introuvable sur l’appareil.');
    }
    final result = await OpenFilex.open(path);
    if (result.type != ResultType.done) {
      throw AppException(
          'Aucune application ne peut ouvrir « ${file.nom} ».');
    }
  }
}
