import 'package:flutter/widgets.dart';
import 'package:money_manager/core/utils/id.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';

List<CategoryModel> defaultCategories() {
  final en = lookupAppLocalizations(const Locale('en'));
  final zh = lookupAppLocalizations(const Locale('zh'));
  final zhCn = lookupAppLocalizations(const Locale('zh', 'CN'));
  const expense = [
    ('food', 'coral'),
    ('transit', 'blue'),
    ('housing', 'amber'),
    ('shopping', 'teal'),
    ('entertainment', 'pink'),
    ('medical', 'green'),
    ('other', 'slate'),
  ];
  const income = [('salary', 'green'), ('bonus', 'amber'), ('other', 'slate')];

  String nameFor(AppLocalizations l10n, String key) {
    return switch (key) {
      'food' => l10n.categoryFood,
      'transit' => l10n.categoryTransit,
      'housing' => l10n.categoryHousing,
      'shopping' => l10n.categoryShopping,
      'entertainment' => l10n.categoryEntertainment,
      'medical' => l10n.categoryMedical,
      'salary' => l10n.categorySalary,
      'bonus' => l10n.categoryBonus,
      _ => l10n.categoryOther,
    };
  }

  CategoryModel item(CategoryKind kind, int index, (String, String) seed) {
    return CategoryModel(
      id: createId(),
      languageEn: nameFor(en, seed.$1),
      languageZh: nameFor(zh, seed.$1),
      languageZhCn: nameFor(zhCn, seed.$1),
      icon: seed.$1,
      color: seed.$2,
      kind: kind,
      sortOrder: index,
    );
  }

  return [
    for (var index = 0; index < expense.length; index++)
      item(CategoryKind.expense, index, expense[index]),
    for (var index = 0; index < income.length; index++)
      item(CategoryKind.income, index, income[index]),
  ];
}
