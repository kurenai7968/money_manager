import 'package:money_manager/core/utils/id.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';

List<CategoryModel> defaultCategories(AppLocalizations l10n) {
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
  final names = {
    'food': l10n.categoryFood,
    'transit': l10n.categoryTransit,
    'housing': l10n.categoryHousing,
    'shopping': l10n.categoryShopping,
    'entertainment': l10n.categoryEntertainment,
    'medical': l10n.categoryMedical,
    'salary': l10n.categorySalary,
    'bonus': l10n.categoryBonus,
    'other': l10n.categoryOther,
  };

  CategoryModel item(CategoryKind kind, int index, (String, String) seed) {
    return CategoryModel(
      id: createId(),
      name: names[seed.$1]!,
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
