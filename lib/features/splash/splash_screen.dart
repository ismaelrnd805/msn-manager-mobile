/// Écran de démarrage : attend la fin de l'initialisation (base locale,
/// seed, services) puis laisse le router rediriger vers /login ou
/// /dashboard selon la session.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/providers/services_providers.dart';
import '../../core/theme/msn_theme.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startup = ref.watch(appStartupProvider);

    ref.listen(appStartupProvider, (prev, next) {
      if (next.hasValue) {
        final session = ref.read(sessionProvider);
        context.go(session == null ? '/login' : '/dashboard');
      }
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [MsnColors.primary, MsnColors.primaryDark],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Image.asset(
                'assets/logo/msn_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Text('MSN',
                      style: TextStyle(
                          color: MsnColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 22)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'MSN Manager',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Multi-Services Numériques',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.8), fontSize: 13),
            ),
            const SizedBox(height: 40),
            if (startup.isLoading)
              const CircularProgressIndicator(color: MsnColors.accent)
            else if (startup.hasError)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Erreur de démarrage : ${startup.error}',
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
