import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/database/sqlite/app_database.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/repositories/category_repository.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('saves language names without a default name', () async {
    final file = path.join(
      Directory.systemTemp.path,
      'money-manager-categories-${DateTime.now().microsecondsSinceEpoch}.db',
    );
    final database = await AppDatabase.open(path: file);
    final repository = SqliteCategoryRepository(database);
    const food = CategoryModel(
      id: 'food',
      languageEn: 'Food',
      languageZh: '飲食',
      languageZhCn: '饮食',
      icon: 'food',
      color: 'coral',
      kind: CategoryKind.expense,
      sortOrder: 0,
    );

    await repository.save(food);
    final loaded = await repository.getAll();

    expect(loaded.single, food);
    await database.close();
    await File(file).delete();
  });
}
