// Bibliothèque de test : ouvre sqlite3 natif depuis le chemin système disponible
// (l'environnement de CI n'a pas libsqlite3 dans le chemin par défaut).
import 'dart:ffi';
import 'dart:io';

import 'package:sqlite3/open.dart';

import 'package:msn_core/data/app_database.dart';

bool _configure = false;

void configureSqlite() {
  if (_configure) return;
  final candidats = <String>[
    Platform.environment['MSN_SQLITE_LIB'] ?? '',
    '/usr/lib/x86_64-linux-gnu/libsqlite3.so.0',
    '/home/z/tools/php-root/usr/lib/x86_64-linux-gnu/libsqlite3.so.0',
  ].where((c) => c.isNotEmpty).toList();

  for (final chemin in candidats) {
    if (File(chemin).existsSync()) {
      open.overrideFor(OperatingSystem.linux, () => DynamicLibrary.open(chemin));
      _configure = true;
      return;
    }
  }
  throw StateError('libsqlite3.so.0 introuvable : définissez MSN_SQLITE_LIB');
}

/// Base en mémoire initialisée avec un appareil local.
Future<MsnDatabase> baseTest({String plateforme = 'android'}) async {
  configureSqlite();
  final db = MsnDatabase.enMemoire();
  await db.customStatement('PRAGMA foreign_keys = ON');
  await db.initAppareilLocal(nom: 'Test', plateforme: plateforme);
  return db;
}
