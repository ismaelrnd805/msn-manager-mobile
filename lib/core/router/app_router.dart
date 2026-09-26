/// Navigation globale (go_router) — 5 onglets + routes de détail.
///
/// Garde de session : toute route exige une session active sauf /login.
/// Les routes d'administration sont en plus protégées par le rôle.
///
/// v4 — animations : toutes les pages secondaires s'ouvrent avec une
/// transition cohérente (fondu + glissement vertical léger). Le dernier
/// écran consulté est mémorisé (session persistante) pour restaurer la
/// navigation au redémarrage de l'application.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../database/app_database.dart';
import '../domain/enums.dart';
import '../providers/services_providers.dart';
import '../../features/communication/communication_providers.dart';

import '../../features/auth/login_screen.dart';
import '../../features/catalog/catalog_screen.dart';
import '../../features/catalog/service_detail_screen.dart';
import '../../features/catalog/service_edit_screen.dart';
import '../../features/clients/client_detail_screen.dart';
import '../../features/clients/client_edit_screen.dart';
import '../../features/clients/clients_screen.dart';
import '../../features/communication/message_composer_screen.dart';
import '../../features/communication/templates_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/documents/documents_screen.dart';
import '../../features/invoices/invoice_detail_screen.dart';
import '../../features/invoices/invoices_screen.dart';
import '../../features/more/more_screen.dart';
import '../../features/orders/order_detail_screen.dart';
import '../../features/orders/orders_screen.dart';
import '../../features/payments/payment_form_screen.dart';
import '../../features/payments/payments_screen.dart';
import '../../features/quotes/quote_detail_screen.dart';
import '../../features/quotes/quote_edit_screen.dart';
import '../../features/quotes/quotes_screen.dart';
import '../../features/requests/request_form_screen.dart';
import '../../features/requests/qualification_screen.dart' as qual;
import '../../features/requests/request_detail_screen.dart';
import '../../features/requests/requests_screen.dart';
import '../../features/documents/file_viewer_screen.dart';
import '../../features/settings/admin_qualification_screen.dart';
import '../../features/settings/admin_templates_screen.dart';
import '../../features/settings/admin_conditions_screen.dart';
import '../../features/settings/admin_catalog_images_screen.dart';
import '../../features/settings/admin_dictionary_screen.dart';
import '../../features/settings/admin_process_screen.dart';
import '../../features/settings/admin_workflows_screen.dart';
import '../../features/settings/journal_screen.dart';
import '../../features/settings/modules_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/trash_screen.dart';
import '../../features/settings/users_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/sync/sync_screen.dart';
import '../../features/tasks/tasks_screen.dart';

/// Passe les changements de session au routeur (re-evaluation du redirect).
class _SessionListenable extends ChangeNotifier {
  _SessionListenable(Ref ref) {
    ref.listen(sessionProvider, (_, __) => notifyListeners());
  }
}

/// Transition de page standard MSN : fondu + glissement vers le haut.
/// Légère (280 ms) pour fluidifier sans ralentir la navigation.
CustomTransitionPage<void> msnPage({required Widget child, GoRouterState? state}) {
  return CustomTransitionPage<void>(
    key: state?.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
          parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.035),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final listenable = _SessionListenable(ref);
  ref.onDispose(listenable.dispose);

  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: listenable,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final location = state.matchedLocation;
      final isSplash = location == '/';
      final isLogin = location == '/login';

      if (isSplash) return null;

      final loggedIn = session != null;
      if (!loggedIn && !isLogin) return '/login';
      if (loggedIn && isLogin) return '/dashboard';

      // Administration réservée au rôle admin.
      final adminOnly = location.startsWith('/settings') &&
          location != '/settings';
      if (adminOnly && !(session?.isAdmin ?? false)) {
        return '/more';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            msnPage(child: const LoginScreen(), state: state),
      ),
      // ── Onglets principaux ───────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/dashboard',
                pageBuilder: (_, state) => msnPage(
                    child: const DashboardScreen(), state: state)),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/requests',
                pageBuilder: (_, state) =>
                    msnPage(child: const RequestsScreen(), state: state)),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/orders',
                pageBuilder: (_, state) =>
                    msnPage(child: const OrdersScreen(), state: state)),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/clients',
                pageBuilder: (_, state) =>
                    msnPage(child: const ClientsScreen(), state: state)),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/more',
                pageBuilder: (_, state) =>
                    msnPage(child: const MoreScreen(), state: state)),
          ]),
        ],
      ),
      // ── Demandes ─────────────────────────────────────────────────────────
      GoRoute(
          path: '/requests/new',
          pageBuilder: (_, state) => msnPage(
              child: RequestFormScreen(
                  initialClientId: state.uri.queryParameters['clientId']),
              state: state)),
      GoRoute(
          path: '/requests/:id/edit',
          pageBuilder: (_, state) => msnPage(
              child: RequestFormScreen(
                  requestId: state.pathParameters['id']),
              state: state)),
      GoRoute(
          path: '/requests/:id',
          pageBuilder: (_, state) => msnPage(
              child: RequestDetailScreen(
                  requestId: state.pathParameters['id']!),
              state: state)),
      GoRoute(
          path: '/requests/:id/qualify',
          pageBuilder: (_, state) => msnPage(
              child: qual.QualificationScreen(
                  requestId: state.pathParameters['id']!),
              state: state)),
      // ── Clients ──────────────────────────────────────────────────────────
      GoRoute(
          path: '/clients/new',
          pageBuilder: (_, state) =>
              msnPage(child: const ClientEditScreen(), state: state)),
      GoRoute(
          path: '/clients/:id',
          pageBuilder: (_, state) => msnPage(
              child: ClientDetailScreen(
                  clientId: state.pathParameters['id']!),
              state: state)),
      GoRoute(
          path: '/clients/:id/edit',
          pageBuilder: (_, state) => msnPage(
              child: ClientEditScreen(
                  clientId: state.pathParameters['id']),
              state: state)),
      // ── Catalogue ────────────────────────────────────────────────────────
      GoRoute(
          path: '/catalog',
          pageBuilder: (_, state) =>
              msnPage(child: const CatalogScreen(), state: state)),
      GoRoute(
          path: '/catalog/new',
          pageBuilder: (_, state) =>
              msnPage(child: const ServiceEditScreen(), state: state)),
      GoRoute(
          path: '/catalog/:id',
          pageBuilder: (_, state) => msnPage(
              child: ServiceDetailScreen(
                  serviceId: state.pathParameters['id']!),
              state: state)),
      GoRoute(
          path: '/catalog/:id/edit',
          pageBuilder: (_, state) => msnPage(
              child: ServiceEditScreen(
                  serviceId: state.pathParameters['id']),
              state: state)),
      // ── Devis ────────────────────────────────────────────────────────────
      GoRoute(
          path: '/quotes',
          pageBuilder: (_, state) =>
              msnPage(child: const QuotesScreen(), state: state)),
      GoRoute(
          path: '/quotes/new',
          pageBuilder: (_, state) => msnPage(
            child: QuoteEditScreen(
              requestId: state.uri.queryParameters['requestId'],
              clientId: state.uri.queryParameters['clientId'],
            ),
            state: state,
          )),
      GoRoute(
          path: '/quotes/:id',
          pageBuilder: (_, state) => msnPage(
              child: QuoteDetailScreen(
                  quoteId: state.pathParameters['id']!),
              state: state)),
      GoRoute(
          path: '/quotes/:id/edit',
          pageBuilder: (_, state) => msnPage(
              child: QuoteEditScreen(
                  quoteId: state.pathParameters['id']),
              state: state)),
      // ── Factures ─────────────────────────────────────────────────────────
      GoRoute(
          path: '/invoices',
          pageBuilder: (_, state) =>
              msnPage(child: const InvoicesScreen(), state: state)),
      GoRoute(
          path: '/invoices/new',
          pageBuilder: (_, state) => msnPage(
            child: InvoiceNewScreen(
              orderId: state.uri.queryParameters['orderId'],
              quoteId: state.uri.queryParameters['quoteId'],
              clientId: state.uri.queryParameters['clientId'],
            ),
            state: state,
          )),
      GoRoute(
          path: '/invoices/:id',
          pageBuilder: (_, state) => msnPage(
              child: InvoiceDetailScreen(
                  invoiceId: state.pathParameters['id']!),
              state: state)),
      // ── Paiements ────────────────────────────────────────────────────────
      GoRoute(
          path: '/payments',
          pageBuilder: (_, state) =>
              msnPage(child: const PaymentsScreen(), state: state)),
      GoRoute(
          path: '/payments/new',
          pageBuilder: (_, state) => msnPage(
            child: PaymentFormScreen(
              invoiceId: state.uri.queryParameters['invoiceId'],
              orderId: state.uri.queryParameters['orderId'],
            ),
            state: state,
          )),
      // ── Commandes ────────────────────────────────────────────────────────
      GoRoute(
          path: '/orders/:id',
          pageBuilder: (_, state) => msnPage(
              child: OrderDetailScreen(
                  orderId: state.pathParameters['id']!),
              state: state)),
      // ── Communication ────────────────────────────────────────────────────
      GoRoute(
          path: '/communication/templates',
          pageBuilder: (_, state) =>
              msnPage(child: const TemplatesScreen(), state: state)),
      GoRoute(
          path: '/communication/composer',
          pageBuilder: (context, state) {
            final args = state.extra is ComposerArgs
                ? state.extra as ComposerArgs
                : null;
            return msnPage(
                child: MessageComposerScreen(args: args), state: state);
          }),
      // ── Fichiers (aperçu in-app : images, TXT, PDF) ──────────────────────
      GoRoute(
          path: '/files/view',
          pageBuilder: (context, state) {
            final file =
                state.extra is OrderFile ? state.extra as OrderFile : null;
            return msnPage(
                child: FileViewerScreen(
                    file: file ??
                        OrderFile(
                            id: '',
                            nom: 'fichier',
                            dossier: DossierFichier.documents,
                            origine: 'mobile',
                            createdAt: DateTime.now())),
                state: state);
          }),
      // ── Modules support ──────────────────────────────────────────────────
      GoRoute(
          path: '/documents',
          pageBuilder: (_, state) =>
              msnPage(child: const DocumentsScreen(), state: state)),
      GoRoute(
          path: '/tasks',
          pageBuilder: (_, state) =>
              msnPage(child: const TasksScreen(), state: state)),
      GoRoute(
          path: '/sync',
          pageBuilder: (_, state) =>
              msnPage(child: const SyncScreen(), state: state)),
      // ── Administration ───────────────────────────────────────────────────
      GoRoute(
          path: '/settings',
          pageBuilder: (_, state) =>
              msnPage(child: const SettingsScreen(), state: state)),
      GoRoute(
          path: '/settings/modules',
          pageBuilder: (_, state) =>
              msnPage(child: const ModulesScreen(), state: state)),
      GoRoute(
          path: '/settings/templates',
          pageBuilder: (_, state) =>
              msnPage(child: const AdminTemplatesScreen(), state: state)),
      GoRoute(
          path: '/settings/qualification',
          pageBuilder: (_, state) => msnPage(
              child: const AdminQualificationScreen(), state: state)),
      GoRoute(
          path: '/settings/users',
          pageBuilder: (_, state) =>
              msnPage(child: const UsersScreen(), state: state)),
      GoRoute(
          path: '/settings/journal',
          pageBuilder: (_, state) =>
              msnPage(child: const JournalScreen(), state: state)),
      GoRoute(
          path: '/settings/trash',
          pageBuilder: (_, state) =>
              msnPage(child: const TrashScreen(), state: state)),
      // ── Administration v4 : contenus administrables ──────────────────────
      GoRoute(
          path: '/settings/conditions',
          pageBuilder: (_, state) =>
              msnPage(child: const AdminConditionsScreen(), state: state)),
      GoRoute(
          path: '/settings/dictionary',
          pageBuilder: (_, state) =>
              msnPage(child: const AdminDictionaryScreen(), state: state)),
      GoRoute(
          path: '/settings/process',
          pageBuilder: (_, state) =>
              msnPage(child: const AdminProcessScreen(), state: state)),
      GoRoute(
          path: '/settings/catalog-images',
          pageBuilder: (_, state) => msnPage(
              child: const AdminCatalogImagesScreen(), state: state)),
      GoRoute(
          path: '/settings/workflows',
          pageBuilder: (_, state) =>
              msnPage(child: const AdminWorkflowsScreen(), state: state)),
    ],
  );

  // Mémorise le dernier écran consulté (restauration au démarrage).
  // Les routes /login et / sont ignorées côté session.saveLastRoute.
  router.routerDelegate.addListener(() {
    final location = router.routeInformationProvider.value.uri.toString();
    if (location.isNotEmpty && location != '/') {
      ref.read(sessionProvider.notifier).saveLastRoute(location);
    }
  });

  return router;
});
