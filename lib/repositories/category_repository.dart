import 'package:money_manager/core/errors/app_exception.dart';
import 'package:money_manager/core/mapping/category_mapping.dart';
import 'package:money_manager/database/sqlite/app_database.dart';
import 'package:money_manager/database/sqlite/tables/category_table.dart';
import 'package:money_manager/entities/category_entity.dart';
import 'package:money_manager/models/category_model.dart';

abstract interface class CategoryRepository {
  Future<List<CategoryModel>> getAll();
  Future<bool> isEmpty();
  Future<int> save(CategoryModel category);
  Future<void> delete(int id);
  Future<void> reorder(List<int> ids);
}

class CategoryRepositoryImpl implements CategoryRepository {
  final AppDatabase _database;

  CategoryRepositoryImpl({required this._database});

  @override
  Future<List<CategoryModel>> getAll() {
    return guard('Categories could not be read.', () async {
      final rows = await _database.query(
        CategoryTable.tableName,
        orderBy: '${CategoryTable.sortOrder} ASC, ${CategoryTable.name} ASC',
      );
      return [
        for (final row in rows)
          CategoryEntity.fromJson(Map<String, dynamic>.from(row)).toModel(),
      ];
    });
  }

  @override
  Future<bool> isEmpty() {
    return guard('Categories could not be read.', () async {
      final count = await _database.count(
        'SELECT COUNT(*) FROM ${CategoryTable.tableName}',
      );
      return count == 0;
    });
  }

  @override
  Future<int> save(CategoryModel category) {
    return guard('Category could not be saved.', () {
      return _database.insert(
        CategoryTable.tableName,
        category.toEntity().toJson(),
      );
    });
  }

  @override
  Future<void> delete(int id) {
    return guard('Category could not be deleted.', () async {
      await _database.delete(
        CategoryTable.tableName,
        where: '${CategoryTable.id} = ?',
        whereArgs: [id],
      );
    });
  }

  @override
  Future<void> reorder(List<int> ids) {
    return guard('Categories could not be reordered.', () {
      return _database.transaction((txn) async {
        for (var index = 0; index < ids.length; index++) {
          await txn.update(
            CategoryTable.tableName,
            {CategoryTable.sortOrder: index},
            where: '${CategoryTable.id} = ?',
            whereArgs: [ids[index]],
          );
        }
      });
    });
  }
}
