import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_bloc.dart';
import 'package:money_manager/database/shared_preferences/shared_preference_store.dart';
import 'package:money_manager/database/sqlite/app_database.dart';
import 'package:money_manager/repositories/account_repository.dart';
import 'package:money_manager/repositories/app_setting_repository.dart';
import 'package:money_manager/repositories/category_repository.dart';
import 'package:money_manager/repositories/transaction_repository.dart';
import 'package:money_manager/services/ledger_service.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppSettingRepository>(
          create: (_) => AppSettingRepositoryImpl(
            store: SharedPreferenceManager.instance.store,
          ),
        ),
        RepositoryProvider<AccountRepository>(
          create: (_) => AccountRepositoryImpl(database: AppDatabase.instance),
        ),
        RepositoryProvider<CategoryRepository>(
          create: (_) => CategoryRepositoryImpl(database: AppDatabase.instance),
        ),
        RepositoryProvider<TransactionRepository>(
          create: (_) =>
              TransactionRepositoryImpl(database: AppDatabase.instance),
        ),
        RepositoryProvider<LedgerService>(
          create: (context) => LedgerServiceImpl(
            accounts: context.read(),
            categories: context.read(),
            transactions: context.read(),
          ),
        ),
      ],
      child: BlocProvider(
        create: (context) => AppSettingBloc(
          appSettingRepository: context.read<AppSettingRepository>(),
        ),
        child: child,
      ),
    );
  }
}
