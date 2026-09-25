/// Ingestion de fichiers reçus du client : sélection via le sélecteur
/// natif, copie dans le dossier applicatif (offline), enregistrement
/// dans la table order_files avec le dossier logique (SOURCE, TRAVAIL…).
library;

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';
import '../domain/enums.dart';
import '../errors/app_exception.dart';

class FileIngestService {
  FileIngestService(this._db);

  final AppDatabase _db;

  /// Ouvre le sélecteur de fichiers et copie le fichier choisi dans
  /// l'arborescence locale. Renvoie l'entrée créée ou null si annulé.
  Future<OrderFile?> pickAndAttach({
    required String? orderId,
    required String? requestId,
    required DossierFichier dossier,
    String? note,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return null;
    final picked = result.files.single;
    if (picked.path == null) {
      throw const AppException('Fichier inaccessible.');
    }
    final source = File(picked.path!);
    final ref = orderId ?? requestId ?? 'MSN';
    final destDir = Directory(
        '${(await getApplicationDocumentsDirectory()).path}'
        '/msn_manager/documents/$ref/${dossier.label}');
    if (!destDir.existsSync()) {
      await destDir.create(recursive: true);
    }
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final destPath =
        p.join(destDir.path, '${stamp}_${p.basename(source.path)}');
    await source.copy(destPath);

    final row = OrderFile(
      id: 'file_${DateTime.now().microsecondsSinceEpoch}',
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

  /// Ouvre un fichier avec l'application par défaut du système.
  Future<void> openFile(OrderFile file) async {
    final path = file.cheminLocal;
    if (path == null) {
      throw const AppException(
          'Ce fichier n’a pas de copie locale (métadonnée uniquement).');
    }
    final f = File(path);
    if (!f.existsSync()) {
      throw const AppException('Fichier introuvable sur l’appareil.');
    }
    // Partage natif = ouverture par l'application cible choisie.
    // (L'ouverture directe sera ajoutée avec open_filex en v1.1.)
  }
}
