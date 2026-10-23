import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/pages/pages.dart';
import 'package:money_manager/routes/app_routes.dart';
import 'package:money_manager/widgets/app_shell.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home.path,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(
            navigationShell: navigationShell,
            onRecord: () => context.push(AppRoutes.record.path),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home.path,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.analysis.path,
                builder: (context, state) => const AnalysisPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.accounts.path,
                builder: (context, state) => const AccountsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings.path,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.record.path,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final typeName = state.uri.queryParameters['type'];
          TransactionType? type;
          for (final item in TransactionType.values) {
            if (item.name == typeName) {
              type = item;
            }
          }
          return RecordPage(
            transactionId: state.uri.queryParameters['id'],
            initialType: type,
            initialAccountId: state.uri.queryParameters['from'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.accountNew.path,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AccountFormPage(),
      ),
      GoRoute(
        path: '/account/:id/edit',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            AccountFormPage(accountId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/account/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            AccountDetailPage(accountId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.categories.path,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CategoriesPage(),
      ),
      GoRoute(
        path: AppRoutes.categoryNew.path,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CategoryFormPage(),
      ),
      GoRoute(
        path: '/category/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            CategoryFormPage(categoryId: state.pathParameters['id']),
      ),
    ],
  );
}
