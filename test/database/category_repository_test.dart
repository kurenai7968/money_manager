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

  test('keeps an existing category name when adding language columns', () async {
    final file = path.join(
      Directory.systemTemp.path,
      'money-manager-categories-v2-${DateTime.now().microsecondsSinceEpoch}.db',
    );
    final created = await openDatabase(
      file,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE accounts (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            opening_balance INTEGER NOT NULL,
            sort_order INTEGER NOT NULL,
            archived INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE categories (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            icon TEXT NOT NULL,
            color TEXT NOT NULL,
            kind TEXT NOT NULL,
            sort_order INTEGER NOT NULL,
            archived INTEGER NOT NULL
          )
        ''');
        await db.insert('categories', {
          'id': 'food',
          'name': 'Food',
          'icon': 'food',
          'color': 'coral',
          'kind': 'expense',
          'sort_order': 0,
          'archived': 0,
        });
      },
    );
    await created.close();

    final database = await AppDatabase.open(path: file);
    final repository = SqliteCategoryRepository(database);
    final loaded = await repository.getAll();

    expect(loaded.single.name, 'Food');
    expect(loaded.single.languageEn, isNull);
    expect(loaded.single.languageZh, isNull);
    expect(loaded.single.languageZhCn, isNull);
    expect(loaded.single.labelFor('en'), 'Food');
    await database.close();
    await File(file).delete();
  });
}
