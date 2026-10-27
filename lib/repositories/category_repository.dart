import 'package:money_manager/core/errors/app_exception.dart';
import 'package:money_manager/core/mapping/category_mapping.dart';
import 'package:money_manager/database/sqlite/app_database.dart';
import 'package:money_manager/database/sqlite/category_table.dart';
import 'package:money_manager/entities/category_entity.dart';
import 'package:money_manager/models/category_model.dart';

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
  Future<List<CategoryModel>> getAll() {
    return _guard('Categories could not be read.', () async {
      final rows = await _database.query(
        CategoryTable.tableName,
        orderBy:
            '${CategoryTable.sortOrder.column} ASC, ${CategoryTable.name.column} ASC',
      );
      return [
        for (final row in rows)
          CategoryEntity.fromJson(Map<String, dynamic>.from(row)).toModel(),
      ];
    });
  }

  @override
  Future<bool> isEmpty() {
    return _guard('Categories could not be read.', () async {
      final count = await _database.count(
        'SELECT COUNT(*) FROM ${CategoryTable.tableName}',
      );
      return count == 0;
    });
  }

  @override
  Future<void> save(CategoryModel category) {
    return _guard('Category could not be saved.', () async {
      await _database.insert(
        CategoryTable.tableName,
        category.toEntity().toJson(),
      );
    });
  }

  @override
  Future<void> delete(String id) {
    return _guard('Category could not be deleted.', () {
      return _database.delete(
        CategoryTable.tableName,
        where: '${CategoryTable.id.column} = ?',
        whereArgs: [id],
      );
    });
  }

  @override
  Future<void> reorder(List<String> ids) {
    return _guard('Categories could not be reordered.', () {
      return _database.transaction((txn) async {
        for (var index = 0; index < ids.length; index++) {
          await txn.update(
            CategoryTable.tableName,
            {CategoryTable.sortOrder.column: index},
            where: '${CategoryTable.id.column} = ?',
            whereArgs: [ids[index]],
          );
        }
      });
    });
  }
}

Future<T> _guard<T>(String message, Future<T> Function() action) async {
  try {
    return await action();
  } on AppException {
    rethrow;
  } catch (error) {
    throw CacheException('$message $error');
  }
}
