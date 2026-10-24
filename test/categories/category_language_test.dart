import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/models/category_defaults.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';

void main() {
  test('initial categories store every language and no name', () {
    final categories = defaultCategories();
    final food = categories.firstWhere(
      (category) =>
          category.icon == 'food' && category.kind == CategoryKind.expense,
    );

    expect(food.name, isNull);
    expect(food.languageEn, 'Food');
    expect(food.languageZh, '飲食');
    expect(food.languageZhCn, '饮食');
    expect(food.labelFor('en'), 'Food');
    expect(food.labelFor('zh'), '飲食');
    expect(food.labelFor('zh_TW'), '飲食');
    expect(food.labelFor('zh_CN'), '饮食');
  });

  test('a user category shows its name in every language', () {
    const category = CategoryModel(
      id: 'rent',
      name: 'Rent',
      icon: 'other',
      color: 'slate',
      kind: CategoryKind.expense,
      sortOrder: 0,
    );

    expect(category.languageEn, isNull);
    expect(category.languageZh, isNull);
    expect(category.languageZhCn, isNull);
    expect(category.labelFor('en'), 'Rent');
    expect(category.labelFor('zh'), 'Rent');
    expect(category.labelFor('zh_CN'), 'Rent');
  });

  test('simplified locale resolves separately from traditional', () {
    expect(categoryLanguageCodeFor(const Locale('zh', 'TW')), 'zh');
    expect(categoryLanguageCodeFor(const Locale('zh', 'HK')), 'zh');
    expect(categoryLanguageCodeFor(const Locale('zh', 'CN')), 'zh_CN');
    expect(
      categoryLanguageCodeFor(
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
      ),
      'zh_CN',
    );
    expect(categoryLanguageCodeFor(const Locale('en')), 'en');
  });
}
