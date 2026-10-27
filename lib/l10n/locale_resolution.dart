import 'package:flutter/widgets.dart';

Locale? localeFor(String? languageCode) {
  return switch (languageCode) {
    'en' => const Locale('en'),
    'zh' => const Locale('zh'),
    'zh_CN' => const Locale('zh', 'CN'),
    _ => null,
  };
}

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
