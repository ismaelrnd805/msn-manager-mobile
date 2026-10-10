// Providers Riverpod : base locale, API, moteur de synchronisation, réglages.
// La configuration serveur (URL + identifiants) vit dans SharedPreferences —
// AUCUN secret n'est embarqué dans le binaire (spéc. §10).
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:msn_core/data/app_database.dart';
import 'package:msn_core/data/outbox.dart';
import 'package:msn_core/sync/engine.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../plateforme.dart' show plateformeCourante;

/// Bootstrap : ouvre la base, initialise l'appareil local.
final bootstrapProvider = FutureProvider<void>((ref) async {
  final db = await ref.watch(baseDeDonneesProvider.future);
  final prefs = await SharedPreferences.getInstance();
  await db.initAppareilLocal(
    nom: prefs.getString('appareil_nom') ?? 'MSN ($plateformeCourante)',
    plateforme: plateformeCourante,
  );
});

/// Base Drift ouverte sur un fichier persistant du répertoire applicatif.
/// Android interdit les chemins relatifs (CWD = '/') : on résout toujours
/// via path_provider, sauf si l'utilisateur a défini db_chemin explicitement.
final baseDeDonneesProvider = FutureProvider<MsnDatabase>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  var chemin = prefs.getString('db_chemin');
  if (chemin == null || chemin.isEmpty) {
    final dossier = await getApplicationDocumentsDirectory();
    chemin = '${dossier.path}/msn_manager.db';
  }
  final db = MsnDatabase.ouvre(chemin);
  ref.onDispose(db.close);
  return db;
});

/// Configuration serveur (URL de l'API v1).
final urlServeurProvider =
    StateProvider<String>((ref) => 'http://127.0.0.1:8000/api/v1');

/// Jeton d'accès en mémoire (jamais persisté en clair).
final jetonProvider = StateProvider<String?>((ref) => null);

/// ID d'appareil déclaré côté serveur.
final appareilIdProvider = StateProvider<String?>((ref) => null);

/// Client HTTP partagé.
final apiHttpProvider = Provider<http.Client>((ref) => http.Client());

/// Implémentation concrète d'[ApiPort] vers le serveur Laravel.
class ApiLaravel implements ApiPort {
  ApiLaravel(this._ref);

  final Ref _ref;

  String get _base => _ref.read(urlServeurProvider);
  String? get _jeton => _ref.read(jetonProvider);

  Map<String, String> get _entetes => {
        'Content-Type': 'application/json',
        if (_jeton != null) 'Authorization': 'Bearer $_jeton',
        if (_ref.read(appareilIdProvider) != null)
          'X-Device-Id': _ref.read(appareilIdProvider)!,
      };

  @override
  Future<Map<String, dynamic>> push(List<Map<String, dynamic>> operations) async {
    try {
      final reponse = await _ref.read(apiHttpProvider).post(
            Uri.parse('$_base/sync/push'),
            headers: _entetes,
            body: jsonEncode({'operations': operations}),
          );
      return jsonDecode(reponse.body) as Map<String, dynamic>;
    } catch (e) {
      throw ApiInatteignable(e);
    }
  }

  @override
  Future<Map<String, dynamic>> pull(String curseur, int limite) async {
    try {
      final reponse = await _ref.read(apiHttpProvider).get(
            Uri.parse('$_base/sync/pull?cursor=$curseur&limit=$limite'),
            headers: _entetes,
          );
      return jsonDecode(reponse.body) as Map<String, dynamic>;
    } catch (e) {
      throw ApiInatteignable(e);
    }
  }
}

/// Port API injecté par Riverpod.
final apiPortProvider = Provider<ApiPort>((ref) => ApiLaravel(ref));

/// Moteur de synchronisation (un cycle à la fois).
final syncMoteurProvider = FutureProvider<SyncEngine>((ref) async {
  final db = await ref.watch(baseDeDonneesProvider.future);
  return SyncEngine(db, ref.watch(apiPortProvider));
});

/// État de synchronisation observable (spec §9 : l'utilisateur sait toujours).
final etatSyncProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final moteur = await ref.watch(syncMoteurProvider.future);
  return moteur.etat();
});

/// Déclenche un cycle de synchronisation complet (au lancement, au retour au
/// premier plan, après modification et à la demande — spec §8.6).
/// [ref] est un [WidgetRef] : tous les appelants sont des widgets consommateurs.
Future<SyncResultat?> synchroniser(WidgetRef ref) async {
  try {
    final moteur = await ref.read(syncMoteurProvider.future);
    final resultat = await moteur.synchronise();
    ref.invalidate(etatSyncProvider);
    return resultat;
  } catch (_) {
    return null;
  }
}
