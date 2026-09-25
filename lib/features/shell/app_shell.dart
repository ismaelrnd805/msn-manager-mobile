/// Shell de navigation — 5 onglets : Accueil, Demandes, Commandes,
/// Clients, Plus. Priorité à l'usage téléphonique (section 28).
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/msn_theme.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        height: 62,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: MsnColors.primary),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox, color: MsnColors.primary),
            label: 'Demandes',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work, color: MsnColors.primary),
            label: 'Commandes',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: MsnColors.primary),
            label: 'Clients',
          ),
          NavigationDestination(
            icon: Icon(Icons.apps_outlined),
            selectedIcon: Icon(Icons.apps, color: MsnColors.primary),
            label: 'Plus',
          ),
        ],
      ),
    );
  }
}
