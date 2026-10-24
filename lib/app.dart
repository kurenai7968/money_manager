import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_bloc.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_event.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_state.dart';
import 'package:money_manager/database/shared_preferences/settings_store.dart';
import 'package:money_manager/database/sqlite/app_database.dart';
import 'package:money_manager/models/app_setting.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/models/category_defaults.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_event.dart';
import 'package:money_manager/repositories/category_repository.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_event.dart';
import 'package:money_manager/repositories/account_repository.dart';
import 'package:money_manager/repositories/transaction_repository.dart';
import 'package:money_manager/routes/app_router.dart';
import 'package:money_manager/themes/app_themes.dart';

class MoneyManagerApp extends StatefulWidget {
  const MoneyManagerApp({
    this.database,
    this.accounts,
    this.categories,
    this.transactions,
    this.settings,
    super.key,
  });

  final AppDatabase? database;
  final AccountRepository? accounts;
  final CategoryRepository? categories;
  final TransactionRepository? transactions;
  final SettingsStore? settings;

  @override
  State<MoneyManagerApp> createState() => _MoneyManagerAppState();
}

class _MoneyManagerAppState extends State<MoneyManagerApp> {
  late final _router = createAppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AccountRepository>(
          create: (_) =>
              widget.accounts ?? SqliteAccountRepository(widget.database!),
        ),
        RepositoryProvider<CategoryRepository>(
          create: (_) =>
              widget.categories ?? SqliteCategoryRepository(widget.database!),
        ),
        RepositoryProvider<TransactionRepository>(
          create: (_) =>
              widget.transactions ??
              SqliteTransactionRepository(widget.database!),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                AppSettingBloc(widget.settings ?? SettingsStore.memory())
                  ..add(const AppSettingStarted()),
          ),
          BlocProvider(create: (context) => AccountsBloc(context.read())),
          BlocProvider(create: (context) => TransactionsBloc(context.read())),
          BlocProvider(
            create: (context) =>
                CategoriesBloc(context.read(), transactions: context.read()),
          ),
        ],
        child: BlocBuilder<AppSettingBloc, AppSettingState>(
          builder: (context, settings) {
            final language = settings.setting.languageCode;
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              onGenerateTitle: (context) => AppLocalizations.of(context).home,
              routerConfig: _router,
              theme: AppThemes.light,
              darkTheme: AppThemes.dark,
              themeMode: switch (settings.setting.themeChoice) {
                AppThemeChoice.light => ThemeMode.light,
                AppThemeChoice.dark => ThemeMode.dark,
                AppThemeChoice.system => ThemeMode.system,
              },
              locale: _localeFor(language),
              localeResolutionCallback: _resolveLocale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) {
                return _LedgerBootstrap(
                  child: child ?? const SizedBox.shrink(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _LedgerBootstrap extends StatefulWidget {
  const _LedgerBootstrap({required this.child});

  final Widget child;

  @override
  State<_LedgerBootstrap> createState() => _LedgerBootstrapState();
}

class _LedgerBootstrapState extends State<_LedgerBootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<AccountsBloc>().add(const AccountsStarted());
      context.read<TransactionsBloc>().add(const TransactionsStarted());
      context.read<CategoriesBloc>().add(
        CategoriesStarted(defaultCategories()),
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

Locale? _localeFor(String? languageCode) {
  return switch (languageCode) {
    'en' => const Locale('en'),
    'zh' => const Locale('zh'),
    'zh_CN' => const Locale('zh', 'CN'),
    _ => null,
  };
}

Locale _resolveLocale(Locale? locale, Iterable<Locale> supported) {
  if (locale != null && locale.languageCode == 'zh') {
    final simplified =
        locale.scriptCode == 'Hans' ||
        locale.countryCode == 'CN' ||
        locale.countryCode == 'SG';
    return simplified ? const Locale('zh', 'CN') : const Locale('zh');
  }
  return const Locale('en');
}
