// Point d'entrée MSN Manager V1 — ANDROID uniquement.
// Toute la logique vit dans msn_core ; l'interface dans msn_ui.
// Les dossiers android/ et windows/ sont générés par `flutter create`
// lors de la CI (scripts/ci/android_prepare.sh) — voir docs/08-codemagic.md.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:msn_ui/msn_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final conteneur = ProviderContainer();
  await conteneur.read(bootstrapProvider.future);

  runApp(UncontrolledProviderScope(
    container: conteneur,
    child: const MsnApp(),
  ));
}
