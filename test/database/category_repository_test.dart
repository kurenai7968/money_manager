import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/database/sqlite/app_database.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/repositories/category_repository.dart';

import '../support/test_stores.dart';

void main() {
  test('saves language names without a default name', () async {
    await openTestDatabase();
    final repository = CategoryRepositoryImpl(database: AppDatabase.instance);
    const food = CategoryModel(
      id: 1,
      languageEn: 'Food',
      languageZh: '飲食',
      languageZhCn: '饮食',
      icon: 'food',
      type: CategoryKind.expense,
      sortOrder: 0,
    );

    await repository.save(food);
    final loaded = await repository.getAll();

    expect(loaded.single, food);
  });

  test('saving a name clears the default language fields', () async {
    await openTestDatabase();
    final repository = CategoryRepositoryImpl(database: AppDatabase.instance);
    const food = CategoryModel(
      id: 1,
      languageEn: 'Food',
      languageZh: '飲食',
      languageZhCn: '饮食',
      icon: 'food',
      type: CategoryKind.expense,
      sortOrder: 0,
    );
    const renamed = CategoryModel(
      id: 1,
      name: 'Groceries',
      icon: 'shopping',
      type: CategoryKind.expense,
      sortOrder: 0,
    );

    await repository.save(food);
    await repository.save(renamed);
    final loaded = await repository.getAll();

    expect(loaded.single, renamed);
    expect(loaded.single.labelFor('zh'), 'Groceries');
    expect(loaded.single.labelFor('zh_CN'), 'Groceries');
  });
}
