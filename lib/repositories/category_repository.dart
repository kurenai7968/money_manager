import 'package:money_manager/core/mapping/category_mapping.dart';
import 'package:money_manager/database/sqlite/app_database.dart';
import 'package:money_manager/entities/category_entity.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:sqflite/sqflite.dart';

abstract interface class CategoryRepository {
  Future<List<CategoryModel>> getAll();

  Future<bool> isEmpty();

  Future<void> save(CategoryModel category);

  Future<void> delete(String id);

  Future<void> reorder(List<String> ids);
}

class SqliteCategoryRepository implements CategoryRepository {
  SqliteCategoryRepository(this._database);

  final AppDatabase _database;

  @override
  Future<List<CategoryModel>> getAll() async {
    final rows = await _database.db.query(
      'categories',
      orderBy: 'sort_order ASC, name ASC',
    );
    return [
      for (final row in rows)
        CategoryEntity.fromJson(Map<String, dynamic>.from(row)).toModel(),
    ];
  }

  @override
  Future<bool> isEmpty() async {
    final count = Sqflite.firstIntValue(
      await _database.db.rawQuery('SELECT COUNT(*) FROM categories'),
    );
    return (count ?? 0) == 0;
  }

  @override
  Future<void> save(CategoryModel category) async {
    await _database.db.insert(
      'categories',
      category.toEntity().toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> delete(String id) async {
    await _database.db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> reorder(List<String> ids) async {
    await _database.db.transaction((txn) async {
      for (var index = 0; index < ids.length; index++) {
        await txn.update(
          'categories',
          {'sort_order': index},
          where: 'id = ?',
          whereArgs: [ids[index]],
        );
      }
    });
  }
}
