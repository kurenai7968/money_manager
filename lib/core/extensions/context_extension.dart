import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_bloc.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/models/app_setting_model.dart';
import 'package:money_manager/themes/account_book_palette.dart';

String categoryLanguageCodeFor(Locale locale) {
  if (locale.languageCode != 'zh') {
    return 'en';
  }
  final simplified =
      locale.scriptCode == 'Hans' ||
      locale.countryCode == 'CN' ||
      locale.countryCode == 'SG';
  return simplified ? 'zh_CN' : 'zh';
}

extension ContextExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String get categoryLanguageCode =>
      categoryLanguageCodeFor(Localizations.localeOf(this));

  AppSettingModel get appSetting {
    try {
      return watch<AppSettingBloc>().state.appSetting;
    } on ProviderNotFoundException {
      return const AppSettingModel();
    }
  }

  Color accountBookColor({required bool income}) {
    final setting = appSetting;
    return AccountBookPalette.directionColor(
      income: income,
      incomeColor: setting.incomeColor,
      expenseColor: setting.expenseColor,
    );
  }
}
