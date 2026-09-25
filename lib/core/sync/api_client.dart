/// Client REST versionné vers le backend NestJS (/api/v1).
///
/// Aucun serveur n'est requis pour faire fonctionner l'application :
/// tant que l'URL du serveur n'est pas configurée (paramètres), le moteur
/// de synchronisation reste en mode local et les données ne quittent
/// jamais le téléphone.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../errors/app_exception.dart';
import 'api_contracts.dart';

class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.deviceId,
    http.Client? client,
    this.authToken,
  }) : _client = client ?? http.Client();

  /// Ex. http://192.168.1.20:3000 — sans / final.
  final String baseUrl;
  final String deviceId;
  final String? authToken;

  final http.Client _client;

  static const String apiVersion = '/api/v1';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

  Uri _uri(String path, [Map<String, String>? query]) {
    final qs = query == null || query.isEmpty ? '' : '?${Uri(queryParameters: query).query}';
    return Uri.parse('$baseUrl$apiVersion$path$qs');
  }

  /// Authentification (préparée pour l'intégration serveur).
  /// POST /auth/login → { accessToken, refreshToken }
  Future<({String accessToken, String refreshToken})> login(
      String username, String password) async {
    final response = await _guard(
      () => _client.post(
        _uri('/auth/login'),
        headers: _headers,
        body: jsonEncode({'username': username, 'password': password}),
      ),
    );
    return (
      accessToken: response['accessToken'] as String,
      refreshToken: response['refreshToken'] as String,
    );
  }

  /// Pousse un lot de changements locaux.
  /// POST /sync/batch → { accepted: [...], conflicts: [...] }
  Future<PushBatchResult> pushBatch(List<SyncPayload> batch) async {
    final response = await _guard(
      () => _client.post(
        _uri('/sync/batch'),
        headers: _headers,
        body: jsonEncode({
          'deviceId': deviceId,
          'changes': batch.map((c) => c.toJson()).toList(),
        }),
      ),
    );
    return PushBatchResult(
      acceptedIds: (response['accepted'] as List? ?? []).cast<String>(),
      conflictIds: (response['conflicts'] as List? ?? []).cast<String>(),
    );
  }

  /// Récupère les changements serveur postérieurs à [since].
  /// GET /sync/changes?since=… → { changes: [...] }
  Future<List<RemoteChange>> fetchChanges(DateTime since) async {
    final response = await _guard(
      () => _client.get(
        _uri('/sync/changes', {'since': since.toIso8601String()}),
        headers: _headers,
      ),
    );
    final list = response['changes'] as List? ?? [];
    return list
        .map((e) => RemoteChange(
              entite: e['entite'] as String,
              entityId: e['entityId'] as String,
              payload: (e['payload'] as Map).cast<String, dynamic>(),
              serverUpdatedAt: DateTime.parse(e['updatedAt'] as String),
              version: (e['version'] as num?)?.toInt() ?? 0,
            ))
        .toList();
  }

  /// Ping de disponibilité du serveur.
  Future<bool> ping() async {
    try {
      final r = await _client
          .get(_uri('/health'))
          .timeout(const Duration(seconds: 5));
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> _guard(
      Future<http.Response> Function() call) async {
    late http.Response response;
    try {
      response = await call().timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const NetworkException('Le serveur ne répond pas (délai dépassé).');
    } on SocketException {
      throw const NetworkException('Impossible de joindre le serveur.');
    } catch (e) {
      throw NetworkException('Erreur réseau : $e');
    }
    if (response.statusCode >= 400) {
      throw NetworkException(
          'Erreur serveur (${response.statusCode}) : ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  void close() => _client.close();
}
