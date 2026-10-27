import 'package:flutter/foundation.dart';
import 'package:money_manager/core/errors/app_exception.dart';
import 'package:money_manager/database/sqlite/account_table.dart';
import 'package:money_manager/database/sqlite/category_table.dart';
import 'package:money_manager/database/sqlite/transaction_table.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

abstract interface class SqlExecutor {
  Future<void> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
  });
}

class AppDatabase implements SqlExecutor {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<void> initialize({String? path}) async {
    if (_database != null) return;
    _database = await openDatabase(
      path ?? await _defaultPath(),
      version: 1,
      onCreate: (db, version) async {
        await db.execute(AccountTable.createSql);
        await db.execute(CategoryTable.createSql);
        await db.execute(TransactionTable.createSql);
      },
    );
  }

  @visibleForTesting
  Future<void> close() async {
    final database = _database;
    _database = null;
    await database?.close();
  }

  Database get _db {
    final database = _database;
    if (database == null) {
      throw const CacheException(
        'SQLite is not initialized. Call initialize() first.',
      );
    }
    return database;
  }

  Future<List<Map<String, Object?>>> query(
    String table, {
    String? orderBy,
    String? where,
    List<Object?>? whereArgs,
  }) {
    return _db.query(
      table,
      orderBy: orderBy,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<void> insert(String table, Map<String, dynamic> values) {
    return _db.insert(
      table,
      Map<String, Object?>.from(values),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    await _db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<void> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    await _db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<int> count(String sql, [List<Object?>? arguments]) async {
    final value = Sqflite.firstIntValue(await _db.rawQuery(sql, arguments));
    return value ?? 0;
  }

  Future<void> transaction(Future<void> Function(SqlExecutor executor) action) {
    return _db.transaction((txn) => action(_SqlTransaction(txn)));
  }

  static Future<String> _defaultPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return path.join(directory.path, 'money_manager.db');
  }
}

class _SqlTransaction implements SqlExecutor {
  _SqlTransaction(this._transaction);

  final Transaction _transaction;

  @override
  Future<void> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    await _transaction.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
    );
  }
}
