import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/pages/pages.dart';
import 'package:money_manager/routes/app_routes.dart';
import 'package:money_manager/widgets/app_shell.dart';

class AppRouter {
  static final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  static GoRouter create() {
    return GoRouter(
      navigatorKey: _rootKey,
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
          parentNavigatorKey: _rootKey,
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
          parentNavigatorKey: _rootKey,
          builder: (context, state) => const AccountFormPage(),
        ),
        GoRoute(
          path: AppRoutes.accountEdit.path,
          parentNavigatorKey: _rootKey,
          builder: (context, state) =>
              AccountFormPage(accountId: state.pathParameters['id']),
        ),
        GoRoute(
          path: AppRoutes.accountDetail.path,
          parentNavigatorKey: _rootKey,
          builder: (context, state) =>
              AccountDetailPage(accountId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: AppRoutes.categories.path,
          parentNavigatorKey: _rootKey,
          builder: (context, state) => const CategoriesPage(),
        ),
        GoRoute(
          path: AppRoutes.categoryNew.path,
          parentNavigatorKey: _rootKey,
          builder: (context, state) => const CategoryFormPage(),
        ),
        GoRoute(
          path: AppRoutes.categoryEdit.path,
          parentNavigatorKey: _rootKey,
          builder: (context, state) =>
              CategoryFormPage(categoryId: state.pathParameters['id']),
        ),
      ],
    );
  }
}
