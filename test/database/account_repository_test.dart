import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/database/sqlite/app_database.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/repositories/account_repository.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('saves and reads an account', () async {
    final file = path.join(
      Directory.systemTemp.path,
      'money-manager-sql-${DateTime.now().microsecondsSinceEpoch}.db',
    );
    final database = await AppDatabase.open(path: file);
    final repository = SqliteAccountRepository(database);
    const account = AccountModel(
      id: 'bank',
      name: 'Bank',
      type: AccountType.bank,
      openingBalanceMinor: 7200000,
      sortOrder: 1,
    );

    await repository.save(account);
    final loaded = await repository.getAll();

    expect(loaded.single, account);
    await database.close();
    await File(file).delete();
  });

  test('saves the default cash account languages', () async {
    final file = path.join(
      Directory.systemTemp.path,
      'money-manager-cash-${DateTime.now().microsecondsSinceEpoch}.db',
    );
    final database = await AppDatabase.open(path: file);
    final repository = SqliteAccountRepository(database);
    const cash = AccountModel(
      id: 'cash',
      languageEn: 'Cash',
      languageZh: '現金',
      languageZhCn: '现金',
      type: AccountType.cash,
      openingBalanceMinor: 0,
      sortOrder: 0,
    );

    await repository.save(cash);
    final loaded = await repository.getAll();

    expect(loaded.single, cash);
    await database.close();
    await File(file).delete();
  });
}
