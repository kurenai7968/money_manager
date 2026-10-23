// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get home => '主頁';

  @override
  String get analysis => '分析';

  @override
  String get accounts => '帳戶';

  @override
  String get settings => '設定';

  @override
  String get record => '記一筆';

  @override
  String get showCalendar => '日曆';

  @override
  String get showSummary => '摘要';

  @override
  String get previousMonth => '上個月';

  @override
  String get nextMonth => '下個月';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get home => '主頁';

  @override
  String get analysis => '分析';

  @override
  String get accounts => '帳戶';

  @override
  String get settings => '設定';

  @override
  String get record => '記一筆';

  @override
  String get showCalendar => '日曆';

  @override
  String get showSummary => '摘要';

  @override
  String get previousMonth => '上個月';

  @override
  String get nextMonth => '下個月';
}
