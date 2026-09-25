/// Navigation globale (go_router) — 5 onglets + routes de détail.
///
/// Garde de session : toute route exige une session active sauf /login.
/// Les routes d'administration sont en plus protégées par le rôle.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
import '../../features/invoices/invoice_new_screen.dart';
import '../../features/invoices/invoices_screen.dart';
import '../../features/more/more_screen.dart';
import '../../features/orders/order_detail_screen.dart';
import '../../features/orders/orders_screen.dart';
import '../../features/payments/payment_form_screen.dart';
import '../../features/payments/payments_screen.dart';
import '../../features/quotes/quote_detail_screen.dart';
import '../../features/quotes/quote_edit_screen.dart';
import '../../features/quotes/quotes_screen.dart';
import '../../features/requests/new_request_screen.dart';
import '../../features/requests/qualification_screen.dart' as qual;
import '../../features/requests/request_detail_screen.dart';
import '../../features/requests/requests_screen.dart';
import '../../features/settings/admin_qualification_screen.dart';
import '../../features/settings/admin_templates_screen.dart';
import '../../features/settings/journal_screen.dart';
import '../../features/settings/modules_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/trash_screen.dart';
import '../../features/settings/users_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/sync/sync_screen.dart';
import '../../features/tasks/tasks_screen.dart';
import '../auth/session.dart';

/// Passe les changements de session au routeur (re-evaluation du redirect).
class _SessionListenable extends ChangeNotifier {
  _SessionListenable(Ref ref) {
    ref.listen(sessionProvider, (_, __) => notifyListeners());
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final listenable = _SessionListenable(ref);
  ref.onDispose(listenable.dispose);

  return GoRouter(
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
        builder: (context, state) => const LoginScreen(),
      ),
      // ── Onglets principaux ───────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/dashboard',
                builder: (_, __) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/requests',
                builder: (_, __) => const RequestsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/orders', builder: (_, __) => const OrdersScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/clients', builder: (_, __) => const ClientsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/more', builder: (_, __) => const MoreScreen()),
          ]),
        ],
      ),
      // ── Demandes ─────────────────────────────────────────────────────────
      GoRoute(
          path: '/requests/new',
          builder: (_, __) => const NewRequestScreen()),
      GoRoute(
          path: '/requests/:id',
          builder: (_, state) => RequestDetailScreen(
              requestId: state.pathParameters['id']!)),
      GoRoute(
          path: '/requests/:id/qualify',
          builder: (_, state) => qual.QualificationScreen(
              requestId: state.pathParameters['id']!)),
      // ── Clients ──────────────────────────────────────────────────────────
      GoRoute(
          path: '/clients/new',
          builder: (_, __) => const ClientEditScreen()),
      GoRoute(
          path: '/clients/:id',
          builder: (_, state) =>
              ClientDetailScreen(clientId: state.pathParameters['id']!)),
      GoRoute(
          path: '/clients/:id/edit',
          builder: (_, state) =>
              ClientEditScreen(clientId: state.pathParameters['id'])),
      // ── Catalogue ────────────────────────────────────────────────────────
      GoRoute(
          path: '/catalog', builder: (_, __) => const CatalogScreen()),
      GoRoute(
          path: '/catalog/new',
          builder: (_, __) => const ServiceEditScreen()),
      GoRoute(
          path: '/catalog/:id',
          builder: (_, state) =>
              ServiceDetailScreen(serviceId: state.pathParameters['id']!)),
      GoRoute(
          path: '/catalog/:id/edit',
          builder: (_, state) =>
              ServiceEditScreen(serviceId: state.pathParameters['id'])),
      // ── Devis ────────────────────────────────────────────────────────────
      GoRoute(
          path: '/quotes', builder: (_, __) => const QuotesScreen()),
      GoRoute(
          path: '/quotes/new',
          builder: (_, state) => QuoteEditScreen(
            requestId: state.uri.queryParameters['requestId'],
            clientId: state.uri.queryParameters['clientId'],
          )),
      GoRoute(
          path: '/quotes/:id',
          builder: (_, state) =>
              QuoteDetailScreen(quoteId: state.pathParameters['id']!)),
      GoRoute(
          path: '/quotes/:id/edit',
          builder: (_, state) =>
              QuoteEditScreen(quoteId: state.pathParameters['id'])),
      // ── Factures ─────────────────────────────────────────────────────────
      GoRoute(
          path: '/invoices', builder: (_, __) => const InvoicesScreen()),
      GoRoute(
          path: '/invoices/new',
          builder: (_, state) => InvoiceNewScreen(
            orderId: state.uri.queryParameters['orderId'],
            quoteId: state.uri.queryParameters['quoteId'],
            clientId: state.uri.queryParameters['clientId'],
          )),
      GoRoute(
          path: '/invoices/:id',
          builder: (_, state) =>
              InvoiceDetailScreen(invoiceId: state.pathParameters['id']!)),
      // ── Paiements ────────────────────────────────────────────────────────
      GoRoute(
          path: '/payments', builder: (_, __) => const PaymentsScreen()),
      GoRoute(
          path: '/payments/new',
          builder: (_, state) => PaymentFormScreen(
              invoiceId: state.uri.queryParameters['invoiceId'],
              orderId: state.uri.queryParameters['orderId'])),
      // ── Commandes ────────────────────────────────────────────────────────
      GoRoute(
          path: '/orders/:id',
          builder: (_, state) =>
              OrderDetailScreen(orderId: state.pathParameters['id']!)),
      // ── Communication ────────────────────────────────────────────────────
      GoRoute(
          path: '/communication/templates',
          builder: (_, __) => const TemplatesScreen()),
      GoRoute(
          path: '/communication/composer',
          builder: (_, state) {
            final args = state.extra is ComposerArgs
                ? state.extra as ComposerArgs
                : null;
            return MessageComposerScreen(args: args);
          }),
      // ── Modules support ──────────────────────────────────────────────────
      GoRoute(
          path: '/documents', builder: (_, __) => const DocumentsScreen()),
      GoRoute(path: '/tasks', builder: (_, __) => const TasksScreen()),
      GoRoute(path: '/sync', builder: (_, __) => const SyncScreen()),
      // ── Administration ───────────────────────────────────────────────────
      GoRoute(
          path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(
          path: '/settings/modules',
          builder: (_, __) => const ModulesScreen()),
      GoRoute(
          path: '/settings/templates',
          builder: (_, __) => const AdminTemplatesScreen()),
      GoRoute(
          path: '/settings/qualification',
          builder: (_, __) => const AdminQualificationScreen()),
      GoRoute(
          path: '/settings/users',
          builder: (_, __) => const UsersScreen()),
      GoRoute(
          path: '/settings/journal',
          builder: (_, __) => const JournalScreen()),
      GoRoute(
          path: '/settings/trash',
          builder: (_, __) => const TrashScreen()),
    ],
  );
});
