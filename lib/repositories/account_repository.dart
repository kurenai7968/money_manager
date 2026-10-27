import 'package:money_manager/core/errors/app_exception.dart';
import 'package:money_manager/core/mapping/account_mapping.dart';
import 'package:money_manager/database/sqlite/account_table.dart';
import 'package:money_manager/database/sqlite/app_database.dart';
import 'package:money_manager/entities/account_entity.dart';
import 'package:money_manager/models/account_model.dart';

abstract interface class AccountRepository {
  Future<List<AccountModel>> getAll();

  Future<bool> isEmpty();

  Future<void> save(AccountModel account);

  Future<void> archive(String id);

  Future<void> reorder(List<String> ids);
}

class SqliteAccountRepository implements AccountRepository {
  SqliteAccountRepository(this._database);

  final AppDatabase _database;

  @override
  Future<List<AccountModel>> getAll() {
    return _guard('Accounts could not be read.', () async {
      final rows = await _database.query(
        AccountTable.tableName,
        orderBy:
            '${AccountTable.sortOrder.column} ASC, ${AccountTable.name.column} ASC',
      );
      return [
        for (final row in rows)
          AccountEntity.fromJson(Map<String, dynamic>.from(row)).toModel(),
      ];
    });
  }

  @override
  Future<bool> isEmpty() {
    return _guard('Accounts could not be read.', () async {
      final count = await _database.count(
        'SELECT COUNT(*) FROM ${AccountTable.tableName}',
      );
      return count == 0;
    });
  }

  @override
  Future<void> save(AccountModel account) {
    return _guard('Account could not be saved.', () async {
      await _database.insert(
        AccountTable.tableName,
        account.toEntity().toJson(),
      );
    });
  }

  @override
  Future<void> archive(String id) {
    return _guard('Account could not be archived.', () {
      return _database.update(
        AccountTable.tableName,
        {AccountTable.archived.column: 1},
        where: '${AccountTable.id.column} = ?',
        whereArgs: [id],
      );
    });
  }

  @override
  Future<void> reorder(List<String> ids) {
    return _guard('Accounts could not be reordered.', () {
      return _database.transaction((txn) async {
        for (var index = 0; index < ids.length; index++) {
          await txn.update(
            AccountTable.tableName,
            {AccountTable.sortOrder.column: index},
            where: '${AccountTable.id.column} = ?',
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
