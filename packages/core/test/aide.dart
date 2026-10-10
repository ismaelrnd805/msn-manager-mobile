// Bibliothèque de test : ouvre sqlite3 natif depuis la bibliothèque disponible
// sur la machine courante — Linux de développement, macOS de Codemagic
// (libsqlite3.dylib système, toujours présente) ou Windows (sqlite3.dll).
// MSN_SQLITE_LIB, s'il est défini, prime sur tous les candidats.
import 'dart:ffi';
import 'dart:io';

import 'package:sqlite3/open.dart';

import 'package:msn_core/data/app_database.dart';

bool _configure = false;

void configureSqlite() {
  if (_configure) return;

  final env = Platform.environment['MSN_SQLITE_LIB'] ?? '';
  final candidats = <String>[
    if (env.isNotEmpty) env,
    if (Platform.isMacOS) ...[
      // Bibliothèque système de macOS : présente sur TOUTE machine macOS
      // (c'est elle qui dépannait le premier build Codemagic réel).
      '/usr/lib/libsqlite3.dylib',
      'libsqlite3.dylib',
    ] else if (Platform.isWindows) ...[
      // Windows : la DLL provisionnée par la CI (MSN_SQLITE_LIB) ou une DLL
      // résolvable via le chemin de recherche standard de LoadLibrary.
      'sqlite3.dll',
    ] else ...[
      // Linux : chemins standards des distributions (amd64, arm64, générique).
      '/usr/lib/x86_64-linux-gnu/libsqlite3.so.0',
      '/usr/lib/aarch64-linux-gnu/libsqlite3.so.0',
      '/usr/lib/libsqlite3.so.0',
      'libsqlite3.so.0',
    ],
  ];

  Object? derniereErreur;
  for (final chemin in candidats) {
    try {
      // On teste l'ouverture RÉELLE (pas seulement l'existence du fichier) :
      // DynamicLibrary.open réussit aussi pour les noms résolvables par
      // dlopen/LoadLibrary via les chemins de recherche du système.
      final lib = DynamicLibrary.open(chemin);
      open.overrideForAll(() => lib);
      _configure = true;
      return;
    } catch (e) {
      derniereErreur = e;
    }
  }
  throw StateError(
      'SQLite natif introuvable sur cette machine. Candidats essayés : '
      '${candidats.join(", ")}. Définissez MSN_SQLITE_LIB avec le chemin '
      'complet de la bibliothèque. Dernière erreur : $derniereErreur');
}

/// Base en mémoire initialisée avec un appareil local.
Future<MsnDatabase> baseTest({String plateforme = 'android'}) async {
  configureSqlite();
  final db = MsnDatabase.enMemoire();
  await db.customStatement('PRAGMA foreign_keys = ON');
  await db.initAppareilLocal(nom: 'Test', plateforme: plateforme);
  return db;
}
