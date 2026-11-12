import 'package:flutter/widgets.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/account_book_kinds.dart';

List<CategoryModel> defaultCategories() {
  final en = lookupAppLocalizations(const Locale('en'));
  final zh = lookupAppLocalizations(const Locale('zh'));
  final zhCn = lookupAppLocalizations(const Locale('zh', 'CN'));
  const expense = [
    'food',
    'transit',
    'housing',
    'shopping',
    'entertainment',
    'medical',
    'other',
  ];
  const income = ['salary', 'bonus', 'other'];

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

  CategoryModel item(CategoryKind type, int index, String icon) {
    return CategoryModel(
      languageEn: nameFor(en, icon),
      languageZh: nameFor(zh, icon),
      languageZhCn: nameFor(zhCn, icon),
      icon: icon,
      type: type,
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
