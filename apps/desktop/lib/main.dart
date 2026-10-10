// Point d'entrée MSN Manager V1 — WINDOWS uniquement.
// Toute la logique vit dans msn_core ; l'interface dans msn_ui.
// Le dossier windows/ (runner CMake/C++) est généré par `flutter create`
// lors de la CI (scripts/ci/windows_prepare.ps1) — voir docs/08-codemagic.md.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_size/window_size.dart';

import 'package:msn_ui/msn_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fenêtre dimensionnée (adaptatif, pas d'écran étiré)
  setWindowMinSize(const Size(1024, 640));
  setWindowInitialSize(const Size(1280, 800));

  final conteneur = ProviderContainer();
  await conteneur.read(bootstrapProvider.future);

  runApp(UncontrolledProviderScope(
    container: conteneur,
    child: const MsnApp(),
  ));
}
