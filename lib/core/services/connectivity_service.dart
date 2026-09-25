/// Service de connectivité — expose un flux booléen online/offline
/// (base de l'indicateur ONLINE / OFFLINE et du déclenchement auto du sync).
library;

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityService {
  ConnectivityService(this._connectivity);

  final Connectivity _connectivity;

  /// true si au moins une interface réseau est disponible.
  /// Note : la connectivité réseau n'implique pas un serveur joignable ;
  /// le moteur de synchronisation gère lui-même les erreurs d'appel.
  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return _hasNetwork(results);
  }

  Stream<bool> watchOnline() {
    return _connectivity.onConnectivityChanged
        .map(_hasNetwork)
        .distinct()
        .transform(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) => sink.add(data),
          ),
        );
  }

  bool _hasNetwork(List<ConnectivityResult> results) {
    return results.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet);
  }
}

/// Flux global online/offline consommé par l'UI et le contrôleur de sync.
final connectivityProvider = StreamProvider<bool>((ref) {
  final service = ConnectivityService(Connectivity());
  return service.watchOnline();
});
