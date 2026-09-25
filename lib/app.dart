/// Racine applicative : démarrage contrôlé (base locale, seed, services)
/// puis navigation. Toute erreur de démarrage est affichée clairement
/// au lieu d'un écran vide.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/seed/demo_data.dart';
import 'core/providers/database_provider.dart';
import 'core/providers/services_providers.dart';
import 'core/router/app_router.dart';
import 'core/sync/sync_provider.dart';
import 'core/theme/msn_theme.dart';

/// Démarrage : ouvre la base, insère les données de démo au premier
/// lancement, initialise les notifications et lance un cycle de sync.
final appStartupProvider = FutureProvider<void>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  await DemoData.seedIfNeeded(db);

  final notifications = ref.read(notificationServiceProvider);
  await notifications.init();

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
