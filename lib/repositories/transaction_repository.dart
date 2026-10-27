import 'package:money_manager/core/errors/app_exception.dart';
import 'package:money_manager/core/mapping/transaction_mapping.dart';
import 'package:money_manager/database/sqlite/app_database.dart';
import 'package:money_manager/database/sqlite/transaction_table.dart';
import 'package:money_manager/entities/transaction_entity.dart';
import 'package:money_manager/models/transaction_model.dart';

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
  Future<List<TransactionModel>> getAll() {
    return _guard('Transactions could not be read.', () async {
      final rows = await _database.query(
        TransactionTable.tableName,
        orderBy:
            '${TransactionTable.date.column} DESC, ${TransactionTable.id.column} DESC',
      );
      return [
        for (final row in rows)
          TransactionEntity.fromJson(Map<String, dynamic>.from(row)).toModel(),
      ];
    });
  }

  @override
  Future<void> save(TransactionModel transaction) {
    return _guard('Transaction could not be saved.', () async {
      await _database.insert(
        TransactionTable.tableName,
        transaction.toEntity().toJson(),
      );
    });
  }

  @override
  Future<void> delete(String id) {
    return _guard('Transaction could not be deleted.', () {
      return _database.delete(
        TransactionTable.tableName,
        where: '${TransactionTable.id.column} = ?',
        whereArgs: [id],
      );
    });
  }

  @override
  Future<int> countForCategory(String categoryId) {
    return _guard('Transactions could not be read.', () {
      return _database.count(
        'SELECT COUNT(*) FROM ${TransactionTable.tableName} WHERE ${TransactionTable.categoryId.column} = ?',
        [categoryId],
      );
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
