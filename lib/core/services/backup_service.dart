/// Sauvegarde locale : export / restauration JSON de toute la base.
///
/// - Export : fichier JSON horodaté, partageable via le partage natif.
/// - Restauration : réservée à l'administration, avec confirmation et
///   purge préalable (les FK sont désactivées pendant l'import).
/// - Synchronisation cloud : viendra se brancher sur le même format
///   (voir docs/12-feuille-de-route.md).
library;

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';
import '../database/app_database.dart';
import '../errors/app_exception.dart';

class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

  /// Exporte toutes les tables dans un fichier JSON et renvoie le chemin.
  Future<String> exportToJson() async {
    final tables = _db.allSchemaEntities.whereType<TableInfo>().toList();
    final export = <String, dynamic>{
      'app': 'msn-manager-mobile',
      'schemaVersion': AppConstants.databaseSchemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'tables': <String, dynamic>{},
    };
    final tablesJson = export['tables'] as Map<String, dynamic>;
    for (final table in tables) {
      final name = table.actualTableName;
      final rows = await _db.customSelect('SELECT * FROM "$name"').get();
      tablesJson[name] = rows.map((r) => r.data).toList();
    }

    final dir = await backupDirectory();
    final stamp = DateTime.now();
    final stampStr = '${stamp.year}${stamp.month.toString().padLeft(2, '0')}'
        '${stamp.day.toString().padLeft(2, '0')}_'
        '${stamp.hour.toString().padLeft(2, '0')}'
        '${stamp.minute.toString().padLeft(2, '0')}';
    final file = File('${dir.path}/backup_msn_$stampStr.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(export));
    return file.path;
  }

  /// Restaure une sauvegarde (purge préalable). Réservé à l'administrateur.
  Future<void> restoreFromJson(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      throw const AppException('Fichier de sauvegarde introuvable.');
    }
    final dynamic decoded;
    try {
      decoded = jsonDecode(file.readAsStringSync());
    } catch (_) {
      throw const AppException('Fichier de sauvegarde illisible.');
    }
    if (decoded is! Map<String, dynamic> || !decoded.containsKey('tables')) {
      throw const AppException('Format de sauvegarde inconnu.');
    }
    final tables = decoded['tables'] as Map<String, dynamic>;

    await _db.transaction(() async {
      await _db.customStatement('PRAGMA foreign_keys = OFF');
      // Purge de toutes les tables existantes.
      for (final table in _db.allSchemaEntities.whereType<TableInfo>()) {
        await _db.customStatement('DELETE FROM "${table.actualTableName}"');
      }
      // Réinjection.
      for (final entry in tables.entries) {
        final name = entry.key;
        final rows = entry.value;
        if (rows is! List) continue;
        for (final dynamic rawRow in rows) {
          if (rawRow is! Map<String, dynamic>) continue;
          final cols = rawRow.keys.toList();
          final colSql = cols.map((c) => '"$c"').join(', ');
          final placeholders = List.filled(cols.length, '?').join(', ');
          final variables =
              cols.map((c) => Variable(_normalize(rawRow[c]))).toList();
          await _db.customInsert(
            'INSERT INTO "$name" ($colSql) VALUES ($placeholders)',
            variables: variables,
          );
        }
      }
      await _db.customStatement('PRAGMA foreign_keys = ON');
    });
  }

  /// Les valeurs brutes SQLite sont déjà du bon type ; on normalise
  /// uniquement les booléens provenant de JSON.
  Object? _normalize(Object? value) {
    if (value is bool) return value ? 1 : 0;
    return value;
  }

  static Future<Directory> backupDirectory() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/msn_manager/backups');
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Dossier des fichiers générés (PDF, images) organisés par référence :
  /// msn_manager/documents/{REFERENCE}/DOCUMENTS/…
  static Future<Directory> generatedDirectory(String reference,
      {String subfolder = 'DOCUMENTS'}) async {
    final base = await getApplicationDocumentsDirectory();
    final dir =
        Directory('${base.path}/msn_manager/documents/$reference/$subfolder');
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}
