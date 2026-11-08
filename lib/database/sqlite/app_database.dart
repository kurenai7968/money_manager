import 'package:flutter/foundation.dart';
import 'package:money_manager/app_config.dart';
import 'package:money_manager/core/errors/app_exception.dart';
import 'package:money_manager/database/sqlite/sql_executor.dart';
import 'package:money_manager/database/sqlite/tables/account_table.dart';
import 'package:money_manager/database/sqlite/tables/category_table.dart';
import 'package:money_manager/database/sqlite/tables/transaction_table.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

export 'sql_executor.dart';

part 'sqlite_executor.dart';
part 'sql_transaction.dart';

class AppDatabase with _SqlExecutorMethods implements SqlExecutor {
  static final AppDatabase instance = AppDatabase._();
  Database? _database;

  AppDatabase._();

  @override
  DatabaseExecutor get _executor => _db;

  Future<void> initialize({String? path}) async {
    if (_database != null) return;
    _database = await openDatabase(
      path ?? await _defaultPath(),
      version: AppConfig.databaseVersion,
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

  Future<T> transaction<T>(Future<T> Function(SqlExecutor executor) action) {
    return _db.transaction((txn) => action(_SqlTransaction(txn)));
  }

  static Future<String> _defaultPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return path.join(directory.path, AppConfig.databaseName);
  }
}
