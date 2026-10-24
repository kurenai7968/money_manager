import 'package:flutter/widgets.dart';
import 'package:money_manager/core/utils/id.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';

AccountModel defaultAccount() {
  final en = lookupAppLocalizations(const Locale('en'));
  final zh = lookupAppLocalizations(const Locale('zh'));
  final zhCn = lookupAppLocalizations(const Locale('zh', 'CN'));
  return AccountModel(
    id: createId(),
    languageEn: en.cash,
    languageZh: zh.cash,
    languageZhCn: zhCn.cash,
    type: AccountType.cash,
    openingBalanceMinor: 0,
    sortOrder: 0,
  );
}
