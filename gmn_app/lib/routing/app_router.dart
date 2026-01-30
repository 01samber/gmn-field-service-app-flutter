import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/work_orders/screens/work_orders_screen.dart';
import '../features/work_orders/screens/work_order_detail_screen.dart';
import '../features/work_orders/screens/work_order_form_screen.dart';
import '../features/technicians/screens/technicians_screen.dart';
import '../features/technicians/screens/technician_detail_screen.dart';
import '../features/technicians/screens/technician_form_screen.dart';
import '../features/costs/screens/costs_screen.dart';
import '../features/proposals/screens/proposals_screen.dart';
import '../features/proposals/screens/proposal_form_screen.dart';
import '../features/calendar/screens/calendar_screen.dart';
import '../features/files/screens/files_screen.dart';
import '../features/commission/screens/commission_screen.dart';
import '../features/income_statement/screens/income_statement_screen.dart';
import '../layout/app_shell.dart';

// Route names
class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/';
  static const String workOrders = '/work-orders';
  static const String workOrderDetail = '/work-orders/:id';
  static const String workOrderCreate = '/work-orders/new';
  static const String workOrderEdit = '/work-orders/:id/edit';
  static const String technicians = '/technicians';
  static const String technicianDetail = '/technicians/:id';
  static const String technicianCreate = '/technicians/new';
  static const String technicianEdit = '/technicians/:id/edit';
  static const String costs = '/costs';
  static const String proposals = '/proposals';
  static const String proposalCreate = '/proposals/new';
  static const String proposalEdit = '/proposals/:id/edit';
  static const String calendar = '/calendar';
  static const String files = '/files';
  static const String commission = '/commission';
  static const String incomeStatement = '/income-statement';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.dashboard,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoginRoute = state.matchedLocation == AppRoutes.login;

      if (!isLoggedIn && !isLoginRoute) {
        return AppRoutes.login;
      }

      if (isLoggedIn && isLoginRoute) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      // Login Route (outside shell)
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Shell Route for main app navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          // Dashboard
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const DashboardScreen(),
            ),
          ),

          // Work Orders
          GoRoute(
            path: AppRoutes.workOrders,
            name: 'work-orders',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const WorkOrdersScreen(),
            ),
            routes: [
              GoRoute(
                path: 'new',
                name: 'work-order-create',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const WorkOrderFormScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'work-order-detail',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return WorkOrderDetailScreen(workOrderId: id);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'work-order-edit',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return WorkOrderFormScreen(workOrderId: id);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Technicians
          GoRoute(
            path: AppRoutes.technicians,
            name: 'technicians',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const TechniciansScreen(),
            ),
            routes: [
              GoRoute(
                path: 'new',
                name: 'technician-create',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const TechnicianFormScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'technician-detail',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return TechnicianDetailScreen(technicianId: id);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'technician-edit',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return TechnicianFormScreen(technicianId: id);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Costs
          GoRoute(
            path: AppRoutes.costs,
            name: 'costs',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const CostsScreen(),
            ),
          ),

          // Proposals
          GoRoute(
            path: AppRoutes.proposals,
            name: 'proposals',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ProposalsScreen(),
            ),
            routes: [
              GoRoute(
                path: 'new',
                name: 'proposal-create',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  return const ProposalFormScreen();
                },
              ),
              GoRoute(
                path: ':id/edit',
                name: 'proposal-edit',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ProposalFormScreen(id: id);
                },
              ),
            ],
          ),

          // Calendar
          GoRoute(
            path: AppRoutes.calendar,
            name: 'calendar',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const CalendarScreen(),
            ),
          ),

          // Files
          GoRoute(
            path: AppRoutes.files,
            name: 'files',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const FilesScreen(),
            ),
          ),

          // Commission
          GoRoute(
            path: AppRoutes.commission,
            name: 'commission',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const CommissionScreen(),
            ),
          ),

          // Income Statement
          GoRoute(
            path: AppRoutes.incomeStatement,
            name: 'income-statement',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const IncomeStatementScreen(),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.error?.message ?? 'Unknown error'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.dashboard),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
