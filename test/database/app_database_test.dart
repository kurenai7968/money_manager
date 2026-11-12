import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/database/sqlite/tables/account_table.dart';
import 'package:money_manager/database/sqlite/app_database.dart';

import '../support/test_stores.dart';

void main() {
  group('AppDatabase', () {
    late AppDatabase database;

    setUp(() async {
      await openTestDatabase();
      database = AppDatabase.instance;
    });

    test('queries selected columns with a limit and offset', () async {
      await database.insert(AccountTable.tableName, _account(1, 'Alpha'));
      await database.insert(AccountTable.tableName, _account(2, 'Beta'));
      await database.insert(AccountTable.tableName, _account(3, 'Gamma'));

      final rows = await database.query(
        AccountTable.tableName,
        columns: [AccountTable.id, AccountTable.name],
        orderBy: '${AccountTable.sortOrder} ASC',
        limit: 1,
        offset: 1,
      );

      expect(rows, [
        {AccountTable.id: 2, AccountTable.name: 'Beta'},
      ]);
    });

    test('insert replaces the row with the same id', () async {
      await database.insert(AccountTable.tableName, _account(1, 'Alpha'));
      final replaced = await database.insert(
        AccountTable.tableName,
        _account(1, 'Renamed'),
      );

      expect(replaced, isNonZero);
      final rows = await database.query(AccountTable.tableName);
      expect(rows.single[AccountTable.name], 'Renamed');
    });

    test('update and delete report the number of rows', () async {
      await database.insert(AccountTable.tableName, _account(1, 'Alpha'));
      await database.insert(AccountTable.tableName, _account(2, 'Beta'));

      final updated = await database.update(
        AccountTable.tableName,
        {AccountTable.name: 'Changed'},
        where: '${AccountTable.id} = ?',
        whereArgs: [1],
      );
      final deleted = await database.delete(
        AccountTable.tableName,
        where: '${AccountTable.id} = ?',
        whereArgs: [1],
      );

      expect(updated, 1);
      expect(deleted, 1);
      expect(
        await database.count('SELECT COUNT(*) FROM ${AccountTable.tableName}'),
        1,
      );
    });

    test('raw SQL reads and writes the same rows', () async {
      final inserted = await database.rawInsert(
        'INSERT INTO ${AccountTable.tableName} '
        '(${AccountTable.id}, ${AccountTable.name}, ${AccountTable.type}, '
        '${AccountTable.icon}, ${AccountTable.sortOrder}, '
        '${AccountTable.isActive}) VALUES (?, ?, ?, ?, ?, ?)',
        [1, 'Alpha', 'cash', 'other', 1, 1],
      );
      final updated = await database.rawUpdate(
        'UPDATE ${AccountTable.tableName} SET ${AccountTable.name} = ? '
        'WHERE ${AccountTable.id} = ?',
        ['Renamed', 1],
      );
      final rows = await database.rawQuery(
        'SELECT ${AccountTable.name} FROM ${AccountTable.tableName}',
      );
      final deleted = await database.rawDelete(
        'DELETE FROM ${AccountTable.tableName} WHERE ${AccountTable.id} = ?',
        [1],
      );

      expect(inserted, isNonZero);
      expect(updated, 1);
      expect(rows, [
        {AccountTable.name: 'Renamed'},
      ]);
      expect(deleted, 1);
    });

    test('a transaction can read and write before it commits', () async {
      final count = await database.transaction((txn) async {
        await txn.insert(AccountTable.tableName, _account(1, 'Alpha'));
        final rows = await txn.query(
          AccountTable.tableName,
          where: '${AccountTable.id} = ?',
          whereArgs: [1],
        );
        expect(rows.single[AccountTable.name], 'Alpha');
        final updated = await txn.update(
          AccountTable.tableName,
          {AccountTable.name: 'Renamed'},
          where: '${AccountTable.id} = ?',
          whereArgs: [1],
        );
        expect(updated, 1);
        return txn.count('SELECT COUNT(*) FROM ${AccountTable.tableName}');
      });

      expect(count, 1);
      final rows = await database.query(AccountTable.tableName);
      expect(rows.single[AccountTable.name], 'Renamed');
    });

    test('a thrown transaction action rolls the writes back', () async {
      await database.insert(AccountTable.tableName, _account(1, 'Alpha'));

      await expectLater(
        database.transaction((txn) async {
          await txn.delete(AccountTable.tableName);
          throw StateError('fail');
        }),
        throwsA(isA<StateError>()),
      );

      final rows = await database.query(AccountTable.tableName);
      expect(rows.single[AccountTable.name], 'Alpha');
    });
  });
}

Map<String, dynamic> _account(int id, String name) {
  return {
    AccountTable.id: id,
    AccountTable.name: name,
    AccountTable.type: 'cash',
    AccountTable.icon: 'other',
    AccountTable.sortOrder: id,
    AccountTable.isActive: 1,
  };
}
