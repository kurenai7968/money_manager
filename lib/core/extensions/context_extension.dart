import 'package:flutter/widgets.dart';
import 'package:money_manager/l10n/app_localizations.dart';

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
}
