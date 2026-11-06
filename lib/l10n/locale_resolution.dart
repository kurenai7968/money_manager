import 'package:flutter/widgets.dart';

Locale resolveLocale(Locale? locale, Iterable<Locale> _) {
  if (locale != null && locale.languageCode == 'zh') {
    final simplified =
        locale.scriptCode == 'Hans' ||
        locale.countryCode == 'CN' ||
        locale.countryCode == 'SG';
    return simplified ? const Locale('zh', 'CN') : const Locale('zh');
  }
  return const Locale('en');
}
