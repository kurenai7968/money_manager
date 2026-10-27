import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_bloc.dart';
import 'package:money_manager/database/shared_preferences/shared_preference_store.dart';
import 'package:money_manager/database/sqlite/app_database.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/repositories/account_repository.dart';
import 'package:money_manager/repositories/app_setting_repository.dart';
import 'package:money_manager/repositories/category_repository.dart';
import 'package:money_manager/repositories/transaction_repository.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({
    super.key,
    required this.child,
    this.accounts,
    this.categories,
    this.transactions,
    this.settings,
  });

  final Widget child;
  final AccountRepository? accounts;
  final CategoryRepository? categories;
  final TransactionRepository? transactions;
  final AppSettingRepository? settings;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppSettingRepository>(
          create: (_) =>
              settings ??
              AppSettingRepositoryImpl(
                store: SharedPreferenceManager.instance.store,
              ),
        ),
        RepositoryProvider<AccountRepository>(
          create: (_) =>
              accounts ?? SqliteAccountRepository(AppDatabase.instance),
        ),
        RepositoryProvider<CategoryRepository>(
          create: (_) =>
              categories ?? SqliteCategoryRepository(AppDatabase.instance),
        ),
        RepositoryProvider<TransactionRepository>(
          create: (_) =>
              transactions ?? SqliteTransactionRepository(AppDatabase.instance),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AppSettingBloc(
              appSettingRepository: context.read<AppSettingRepository>(),
            ),
          ),
          BlocProvider(create: (context) => AccountsBloc(context.read())),
          BlocProvider(create: (context) => TransactionsBloc(context.read())),
          BlocProvider(
            create: (context) =>
                CategoriesBloc(context.read(), transactions: context.read()),
          ),
        ],
        child: child,
      ),
    );
  }
}
