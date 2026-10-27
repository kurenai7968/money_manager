import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/database/sqlite/app_database.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/repositories/account_repository.dart';

import '../support/test_stores.dart';

void main() {
  test('saves and reads an account', () async {
    await openTestDatabase();
    final repository = SqliteAccountRepository(AppDatabase.instance);
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
  });

  test('saves the default cash account languages', () async {
    await openTestDatabase();
    final repository = SqliteAccountRepository(AppDatabase.instance);
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
  });
}
