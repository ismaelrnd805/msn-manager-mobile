// Test de fumée Flutter : l'application se construit et affiche l'accueil.
// La base Drift est remplacée par une base EN MÉMOIRE (aucun canal plateforme).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:msn_core/data/app_database.dart';
import 'package:msn_ui/msn_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("l'application démarre et affiche l'écran d'accueil",
      (WidgetTester tester) async {
    final db = MsnDatabase.enMemoire();
    final conteneur = ProviderContainer(
      overrides: [
        baseDeDonneesProvider.overrideWith((ref) async => db),
      ],
    );
    addTearDown(conteneur.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: conteneur,
      child: const MsnApp(),
    ));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // L'écran d'accueil est affiché (route initiale du routeur GoRouter).
    expect(find.text('Accueil'), findsOneWidget);
  });
}
