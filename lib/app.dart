import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/app_providers.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_bloc.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_state.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/l10n/locale_resolution.dart';
import 'package:money_manager/models/category_defaults.dart';
import 'package:money_manager/models/enums/app_appearance.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_event.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_event.dart';
import 'package:money_manager/repositories/account_repository.dart';
import 'package:money_manager/repositories/app_setting_repository.dart';
import 'package:money_manager/repositories/category_repository.dart';
import 'package:money_manager/repositories/transaction_repository.dart';
import 'package:money_manager/routes/app_router.dart';
import 'package:money_manager/themes/app_themes.dart';

class App extends StatefulWidget {
  const App({
    super.key,
    this.accounts,
    this.categories,
    this.transactions,
    this.settings,
  });

  final AccountRepository? accounts;
  final CategoryRepository? categories;
  final TransactionRepository? transactions;
  final AppSettingRepository? settings;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final _router = AppRouter.create();

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      accounts: widget.accounts,
      categories: widget.categories,
      transactions: widget.transactions,
      settings: widget.settings,
      child:
          BlocSelector<
            AppSettingBloc,
            AppSettingState,
            (AppAppearance, String?)
          >(
            selector: (state) =>
                (state.appSetting.appearance, state.appSetting.languageCode),
            builder: (context, data) {
              final (appearance, languageCode) = data;
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                onGenerateTitle: (context) => context.l10n.home,
                routerConfig: _router,
                theme: AppThemes.light,
                darkTheme: AppThemes.dark,
                themeMode: appearance.themeMode,
                locale: localeFor(languageCode),
                localeResolutionCallback: resolveLocale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  ...GlobalMaterialLocalizations.delegates,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
                builder: (context, child) {
                  return _LedgerBootstrap(
                    child: child ?? const SizedBox.shrink(),
                  );
                },
              );
            },
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
