import 'package:money_manager/core/mapping/transaction_mapping.dart';
import 'package:money_manager/database/sqlite/app_database.dart';
import 'package:money_manager/database/sqlite/transaction_table.dart';
import 'package:money_manager/entities/transaction_entity.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:sqflite/sqflite.dart';

abstract interface class TransactionRepository {
  Future<List<TransactionModel>> getAll();

  Future<void> save(TransactionModel transaction);

  Future<void> delete(String id);

  Future<int> countForCategory(String categoryId);
}

class SqliteTransactionRepository implements TransactionRepository {
  SqliteTransactionRepository(this._database);

  final AppDatabase _database;

  @override
  Future<List<TransactionModel>> getAll() async {
    final rows = await _database.db.query(
      TransactionTable.tableName,
      orderBy:
          '${TransactionTable.date.column} DESC, ${TransactionTable.id.column} DESC',
    );
    return [
      for (final row in rows)
        TransactionEntity.fromJson(Map<String, dynamic>.from(row)).toModel(),
    ];
  }

  @override
  Future<void> save(TransactionModel transaction) async {
    await _database.db.insert(
      TransactionTable.tableName,
      transaction.toEntity().toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> delete(String id) async {
    await _database.db.delete(
      TransactionTable.tableName,
      where: '${TransactionTable.id.column} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> countForCategory(String categoryId) async {
    final count = Sqflite.firstIntValue(
      await _database.db.rawQuery(
        'SELECT COUNT(*) FROM ${TransactionTable.tableName} WHERE ${TransactionTable.categoryId.column} = ?',
        [categoryId],
      ),
    );
    return count ?? 0;
  }
}
