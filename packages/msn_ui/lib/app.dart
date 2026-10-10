// Application : shell adaptatif (NavigationRail desktop / NavigationBar mobile),
// navigation GoRouter, thème Material 3 en français.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'plateforme.dart' show isMobile;
import 'state/providers.dart';
import 'ui/screens/accueil.dart';
import 'ui/screens/catalogue.dart';
import 'ui/screens/clients.dart';
import 'ui/screens/commandes.dart';
import 'ui/screens/communications.dart';
import 'ui/screens/demandes.dart';
import 'ui/screens/devis.dart';
import 'ui/screens/facebook_planning.dart';
import 'ui/screens/finances.dart';
import 'ui/screens/journal_audit.dart';
import 'ui/screens/parametres.dart';
import 'ui/screens/taches.dart';

/// Éléments de navigation (libellés français, ordre métier).
class _Destination {
  const _Destination(this.route, this.libelle, this.icone, this.iconeActive);
  final String route;
  final String libelle;
  final IconData icone;
  final IconData iconeActive;
}

const _destinations = <_Destination>[
  _Destination('/accueil', 'Accueil', Icons.dashboard_outlined, Icons.dashboard),
  _Destination('/clients', 'Clients', Icons.people_outline, Icons.people),
  _Destination('/demandes', 'Demandes', Icons.inbox_outlined, Icons.inbox),
  _Destination('/devis', 'Devis', Icons.request_quote_outlined, Icons.request_quote),
  _Destination('/commandes', 'Commandes', Icons.work_outline, Icons.work),
  _Destination('/taches', 'Tâches', Icons.checklist_outlined, Icons.checklist),
  _Destination('/finances', 'Finances', Icons.payments_outlined, Icons.payments),
  _Destination('/communications', 'Messages', Icons.chat_bubble_outline, Icons.chat_bubble),
  _Destination('/catalogue', 'Catalogue', Icons.menu_book_outlined, Icons.menu_book),
  _Destination('/facebook', 'Facebook', Icons.facebook_outlined, Icons.facebook),
  _Destination('/journal', 'Journal', Icons.history_outlined, Icons.history),
  _Destination('/parametres', 'Paramètres', Icons.settings_outlined, Icons.settings),
];

final _routeur = GoRouter(
  initialLocation: '/accueil',
  routes: [
    for (final d in _destinations)
      GoRoute(
        path: d.route,
        builder: (context, state) => _ecranPour(d.route),
      ),
  ],
);

Widget _ecranPour(String route) => switch (route) {
      '/accueil' => const AccueilEcran(),
      '/clients' => const ClientsEcran(),
      '/demandes' => const DemandesEcran(),
      '/devis' => const DevisEcran(),
      '/commandes' => const CommandesEcran(),
      '/taches' => const TachesEcran(),
      '/finances' => const FinancesEcran(),
      '/communications' => const CommunicationsEcran(),
      '/catalogue' => const CatalogueEcran(),
      '/facebook' => const FacebookPlanningEcran(),
      '/journal' => const JournalAuditEcran(),
      '/parametres' => const ParametresEcran(),
      _ => const Scaffold(body: Center(child: Text('Page inconnue'))),
    };

class MsnApp extends ConsumerStatefulWidget {
  const MsnApp({super.key});

  @override
  ConsumerState<MsnApp> createState() => _MsnAppState();
}

class _MsnAppState extends ConsumerState<MsnApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Synchronisation au lancement (spec §8.6)
    Future.microtask(() => synchroniser(ref));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Synchronisation au retour au premier plan (spec §8.6)
    if (state == AppLifecycleState.resumed) {
      synchroniser(ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MSN Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B5D3B), // vert profond, imprimante/services
          brightness: Brightness.light,
        ),
        fontFamilyFallback: const ['Roboto', 'Segoe UI', 'Noto Sans'],
        cardTheme: const CardThemeData(elevation: 0.5),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B5D3B),
          brightness: Brightness.dark,
        ),
      ),
      routerConfig: _routeur,
    );
  }
}

/// Shell adaptatif : rail à gauche sur desktop, barre en bas sur mobile.
class ShellNavigation extends ConsumerWidget {
  const ShellNavigation({required this.enfant, required this.route, super.key});

  final Widget enfant;
  final String route;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index =
        _destinations.indexWhere((d) => route.startsWith(d.route)).clamp(0, _destinations.length - 1);
    final etatSync = ref.watch(etatSyncProvider);

    final contenu = Row(
      children: [
        if (!isMobile) _rail(context, ref, index, etatSync),
        Expanded(
          child: Column(
            children: [
              if (isMobile) _enteteMobile(context, ref, etatSync),
              Expanded(child: enfant),
            ],
          ),
        ),
      ],
    );

    return Scaffold(
      body: contenu,
      bottomNavigationBar: isMobile
          ? NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (i) => context.go(_destinations[i].route),
              destinations: [
                for (final d in _destinations.take(5))
                  NavigationDestination(
                    icon: Icon(d.icone),
                    selectedIcon: Icon(d.iconeActive),
                    label: d.libelle,
                  ),
              ],
            )
          : null,
    );
  }

  Widget _rail(BuildContext context, WidgetRef ref, int index, AsyncValue<Map<String, dynamic>> etatSync) {
    return NavigationRail(
      selectedIndex: index,
      onDestinationSelected: (i) => context.go(_destinations[i].route),
      extended: MediaQuery.of(context).size.width >= 1400,
      minExtendedWidth: 200,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text('MSN',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            // Pastille d'état de synchronisation
            etatSync.when(
              data: (e) => Tooltip(
                message:
                    'En attente : ${e['operations_en_attente']} · Conflits : ${e['conflits_non_resolus']}',
                child: Badge(
                  isLabelVisible: ((e['operations_en_attente'] as int) +
                          (e['conflits_non_resolus'] as int)) >
                      0,
                  child: const Icon(Icons.sync),
                ),
              ),
              loading: () => const SizedBox(
                  width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
              error: (_, __) => const Icon(Icons.sync_problem, color: Colors.orange),
            ),
          ],
        ),
      ),
      destinations: [
        for (final d in _destinations)
          NavigationRailDestination(
            icon: Icon(d.icone),
            selectedIcon: Icon(d.iconeActive),
            label: Text(d.libelle),
          ),
      ],
    );
  }

  Widget _enteteMobile(BuildContext context, WidgetRef ref, AsyncValue<Map<String, dynamic>> etatSync) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Text('MSN Manager',
                style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            etatSync.when(
              data: (e) => IconButton(
                tooltip: 'Synchroniser (${e['operations_en_attente']} en attente)',
                icon: const Icon(Icons.sync),
                onPressed: () => synchroniser(ref),
              ),
              loading: () => const SizedBox(width: 24, height: 24),
              error: (_, __) => const Icon(Icons.sync_problem),
            ),
          ],
        ),
      ),
    );
  }
}
