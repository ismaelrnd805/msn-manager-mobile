// Base de données Drift locale (spec §5, §6.2) : migrations versionnées,
// PRAGMA foreign_keys = ON et journal_mode = WAL à l'ouverture.
import 'package:drift/drift.dart';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:uuid/uuid.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  AppMeta,
  Clients,
  Contacts,
  Services,
  Tarifs,
  Demandes,
  DemandePrestations,
  Commandes,
  LignesCommande,
  Projets,
  CahiersCharges,
  Taches,
  ModelesMessages,
  Echanges,
  DevisTable,
  LignesDevisTable,
  Factures,
  LignesFacture,
  Paiements,
  Depenses,
  PiecesJointes,
  JournalActions,
  Appareils,
  PublicationsFacebook,
  SyncOutbox,
  SyncState,
  SyncConflicts,
])
class MsnDatabase extends _$MsnDatabase {
  MsnDatabase(super.e);

  /// Accesseurs courts (le nom de classe de table porte le suffixe Table).
  $DevisTableTable get devis => devisTable;
  $LignesDevisTableTable get lignesDevis => lignesDevisTable;

  /// Ouvre la base native SQLite sur un fichier.
  factory MsnDatabase.ouvre(String chemin) {
    return MsnDatabase(NativeDatabase(File(chemin), setup: (raw) {
      raw.execute('PRAGMA foreign_keys = ON');
      raw.execute('PRAGMA journal_mode = WAL');
    }));
  }

  /// Base en mémoire (tests).
  factory MsnDatabase.enMemoire() {
    return MsnDatabase(NativeDatabase.memory(setup: (raw) {
      raw.execute('PRAGMA foreign_keys = ON');
    }));
  }

  /// ID de l'appareil local (spéc. §3 : un device_id UUID créé par installation).
  /// Alimenté par [initAppareilLocal] ; 'local-device' tant qu'initialisé.
  String appareilIdLocal = 'local-device';

  // Version 1 = schéma initial complet (spec §6.1). Ne jamais modifier une
  // migration déployée : toute évolution crée une migration 2, 3, etc.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await customStatement(
              "INSERT OR IGNORE INTO app_meta(key, value) VALUES ('schema_version', '1')");
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // from 0/1 → to : les migrations futures s'enchaînent ici.
          if (from < 1) {
            await m.createAll();
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement('PRAGMA journal_mode = WAL');
        },
      );

  /// Initialise (une seule fois par installation) l'UUID d'appareil local,
  /// conservé dans app_meta et rejoué après réinstallation des données.
  Future<String> initAppareilLocal(
      {String? nom, String plateforme = 'android'}) async {
    final horodatage = DateTime.now().toUtc().toIso8601String();
    final existant = await customSelect(
      'SELECT value FROM app_meta WHERE "key" = ?',
      variables: [Variable('device_id')],
    ).getSingleOrNull();
    var id = existant?.data['value'] as String?;
    if (id == null) {
      id = const Uuid().v4();
      await customStatement('INSERT INTO app_meta("key", value) VALUES (?, ?)', [
        'device_id',
        id,
      ]);
    }
    await customStatement(
      'INSERT INTO appareils(id, nom, plateforme, actif, created_at, updated_at) '
      'VALUES (?, ?, ?, 1, ?, ?) '
      'ON CONFLICT(id) DO UPDATE SET nom = excluded.nom, plateforme = excluded.plateforme',
      [
        id,
        nom ?? 'Appareil local',
        plateforme,
        horodatage,
        horodatage,
      ],
    );
    appareilIdLocal = id;
    return id;
  }
}
