/// Racine applicative : démarrage contrôlé (base locale, seed, services)
/// puis navigation. Toute erreur de démarrage est affichée clairement
/// au lieu d'un écran vide.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/seed/default_content.dart';
import 'core/database/seed/demo_data.dart';
import 'core/providers/database_provider.dart';
import 'core/providers/services_providers.dart';
import 'core/router/app_router.dart';
import 'core/sync/sync_provider.dart';
import 'core/theme/msn_theme.dart';

/// Démarrage : ouvre la base, insère les données de démo au premier
/// lancement, garantit les contenus par défaut administrables,
/// restaure la session persistante, initialise les notifications et
/// lance un cycle de sync.
final appStartupProvider = FutureProvider<void>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  await DemoData.seedIfNeeded(db);
  // Contenus administrables garantis (conditions, dictionnaire FR/MG,
  // processus client, instructions d'étapes) — sans eux l'app ne peut
  // pas fonctionner correctement, ils ne dépendent pas du seed démo.
  await DefaultContent.ensureDefaults(db);

  // Restauration de la session persistante (secure storage) — AVANT
  // toute redirection du splash, pour retrouver le dernier écran.
  await ref.read(sessionProvider.notifier).restore();

  final notifications = ref.read(notificationServiceProvider);
  await notifications.init();
  // Demande de permission (Android 13+) : au premier besoin réel — les
  // rappels planifiés ci-dessous. Le refus ne bloque jamais l'application.
  await notifications.requestPermission();

  // Déclenche l'initialisation du contrôleur de synchronisation.
  ref.watch(syncControllerProvider);

  // Rappels échus pendant que l'app était fermée.
  try {
    await ref.read(reminderServiceProvider).flushDue();
  } catch (_) {
    // Les rappels ne doivent jamais bloquer le démarrage.
  }
});

class MsnApp extends ConsumerWidget {
  const MsnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'MSN Manager',
      debugShowCheckedModeBanner: false,
      theme: MsnTheme.light(),
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
