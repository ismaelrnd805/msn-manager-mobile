/// Langue des textes destinés au CLIENT (français / malagasy).
///
/// Cette bascule est indépendante de la langue de l'interface (toujours
/// française) : elle pilote uniquement les textes, messages, PDF et
/// visuels envoyés au client. L'état est persisté dans la table settings
/// (`langue_client`) pour retrouver la préférence à chaque session.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import 'database_provider.dart';

enum ClientLangue { fr, mg }

extension ClientLangueX on ClientLangue {
  String get code => this == ClientLangue.fr ? 'fr' : 'mg';

  /// Libellé affiché sur la bascule.
  String get label => this == ClientLangue.fr ? 'Français' : 'Malagasy';

  static ClientLangue fromCode(String? code) =>
      code == 'mg' ? ClientLangue.mg : ClientLangue.fr;
}

/// Contrôleur de la langue client — chargé puis persisté à chaque bascule.
class ClientLangueNotifier extends AsyncNotifier<ClientLangue> {
  @override
  Future<ClientLangue> build() async {
    final dao = ref.watch(systemDaoProvider);
    final value = await dao.getValue(AppConstants.keyClientLanguage);
    return ClientLangueX.fromCode(value);
  }

  Future<void> setLangue(ClientLangue langue) async {
    state = AsyncData(langue);
    final dao = ref.read(systemDaoProvider);
    await dao.setValue(AppConstants.keyClientLanguage, langue.code);
  }
}

final clientLangueProvider =
    AsyncNotifierProvider<ClientLangueNotifier, ClientLangue>(
        ClientLangueNotifier.new);
