import 'package:money_manager/core/mapping/account_mapping.dart';
import 'package:money_manager/database/sqlite/app_database.dart';
import 'package:money_manager/entities/account_entity.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:sqflite/sqflite.dart';

abstract interface class AccountRepository {
  Future<List<AccountModel>> getAll();

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
      'accounts',
      orderBy: 'sort_order ASC, name ASC',
    );
    return [
      for (final row in rows)
        AccountEntity.fromJson(Map<String, dynamic>.from(row)).toModel(),
    ];
  }

  @override
  Future<void> save(AccountModel account) async {
    await _database.db.insert(
      'accounts',
      account.toEntity().toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> archive(String id) async {
    await _database.db.update(
      'accounts',
      {'archived': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> reorder(List<String> ids) async {
    await _database.db.transaction((txn) async {
      for (var index = 0; index < ids.length; index++) {
        await txn.update(
          'accounts',
          {'sort_order': index},
          where: 'id = ?',
          whereArgs: [ids[index]],
        );
      }
    });
  }
}
