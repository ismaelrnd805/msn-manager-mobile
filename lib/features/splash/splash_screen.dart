/// Écran de démarrage : attend la fin de l'initialisation (base locale,
/// contenus par défaut, restauration de session persistante, services)
/// puis redirige vers /login ou vers le DERNIER ÉCRAN consulté — la
/// session persistante permet de retrouver exactement où l'on était.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/providers/services_providers.dart';
import '../../core/theme/msn_theme.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  /// Préfixes de routes valides : protège contre la restauration d'une
  /// route supprimée dans une future version.
  static const List<String> _routePrefixes = [
    '/dashboard', '/requests', '/orders', '/clients', '/more', '/catalog',
    '/quotes', '/invoices', '/payments', '/communication', '/documents',
    '/tasks', '/sync', '/settings',
  ];

  Future<String> _destination(WidgetRef ref) async {
    final session = ref.read(sessionProvider);
    if (session == null) return '/login';
    try {
      final last = await ref.read(sessionProvider.notifier).lastRoute();
      if (last != null &&
          last.isNotEmpty &&
          _routePrefixes.any((p) => last.startsWith(p))) {
        return last;
      }
    } catch (_) {}
    return '/dashboard';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startup = ref.watch(appStartupProvider);

    ref.listen(appStartupProvider, (prev, next) async {
      if (next.hasValue) {
        final destination = await _destination(ref);
        if (context.mounted) context.go(destination);
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
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
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
                  color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
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
