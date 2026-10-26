import 'package:money_manager/core/mapping/account_mapping.dart';
import 'package:money_manager/database/sqlite/account_table.dart';
import 'package:money_manager/database/sqlite/app_database.dart';
import 'package:money_manager/entities/account_entity.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:sqflite/sqflite.dart';

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
  Future<List<AccountModel>> getAll() async {
    final rows = await _database.db.query(
      AccountTable.tableName,
      orderBy:
          '${AccountTable.sortOrder.column} ASC, ${AccountTable.name.column} ASC',
    );
    return [
      for (final row in rows)
        AccountEntity.fromJson(Map<String, dynamic>.from(row)).toModel(),
    ];
  }

  @override
  Future<bool> isEmpty() async {
    final count = Sqflite.firstIntValue(
      await _database.db.rawQuery(
        'SELECT COUNT(*) FROM ${AccountTable.tableName}',
      ),
    );
    return (count ?? 0) == 0;
  }

  @override
  Future<void> save(AccountModel account) async {
    await _database.db.insert(
      AccountTable.tableName,
      account.toEntity().toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> archive(String id) async {
    await _database.db.update(
      AccountTable.tableName,
      {AccountTable.archived.column: 1},
      where: '${AccountTable.id.column} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> reorder(List<String> ids) async {
    await _database.db.transaction((txn) async {
      for (var index = 0; index < ids.length; index++) {
        await txn.update(
          AccountTable.tableName,
          {AccountTable.sortOrder.column: index},
          where: '${AccountTable.id.column} = ?',
          whereArgs: [ids[index]],
        );
      }
    });
  }
}
