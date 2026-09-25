/// Shell de navigation — 5 onglets : Accueil, Demandes, Commandes,
/// Clients, Plus. Priorité à l'usage téléphonique (section 28).
///
/// v4 — actions rapides PERMANENTES : un bouton flottant, ancré au-dessus
/// de la barre de navigation inférieure (accessible au pouce), ouvre le
/// volet des actions rapides depuis n'importe quel écran de l'application.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/msn_theme.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      floatingActionButton: FloatingActionButton(
        heroTag: 'msn_quick_actions',
        tooltip: 'Actions rapides',
        child: const Icon(Icons.add, size: 26),
        onPressed: () => _showQuickActions(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 0, 0, 12),
                child: Text('Actions rapides',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800)),
              ),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.05,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  _QuickAction(
                    icon: Icons.post_add,
                    label: 'Nouvelle\ndemande',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      context.push('/requests/new');
                    },
                  ),
                  _QuickAction(
                    icon: Icons.person_add_alt_1_outlined,
                    label: 'Nouveau\nclient',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      context.push('/clients/new');
                    },
                  ),
                  _QuickAction(
                    icon: Icons.request_quote_outlined,
                    label: 'Nouveau\ndevis',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      context.push('/quotes/new');
                    },
                  ),
                  _QuickAction(
                    icon: Icons.receipt_long_outlined,
                    label: 'Nouvelle\nfacture',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      context.push('/invoices/new');
                    },
                  ),
                  _QuickAction(
                    icon: Icons.payments_outlined,
                    label: 'Nouveau\npaiement',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      context.push('/payments/new');
                    },
                  ),
                  _QuickAction(
                    icon: Icons.task_outlined,
                    label: 'Nouvelle\ntâche',
                    onTap: () {
                      Navigator.pop(sheetContext);
                      context.push('/tasks');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: MsnColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MsnColors.border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: MsnColors.primary),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11.5, height: 1.15)),
          ],
        ),
      ),
    );
  }
}
