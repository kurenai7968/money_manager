import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/app_providers.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_bloc.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_state.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/l10n/locale_resolution.dart';
import 'package:money_manager/routes/app_router.dart';
import 'package:money_manager/themes/app_themes.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: BlocBuilder<AppSettingBloc, AppSettingState>(
        buildWhen: (previous, current) =>
            previous.appSetting.appThemeMode !=
                current.appSetting.appThemeMode ||
            previous.appSetting.locale != current.appSetting.locale,
        builder: (context, state) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (context) => context.l10n.home,
            theme: AppThemes.light,
            darkTheme: AppThemes.dark,
            themeMode: state.appSetting.appThemeMode.themeMode,
            locale: state.appSetting.locale,
            localeResolutionCallback: resolveLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: AppRouter.create(),
          );
        },
      ),
    );
  }
}
