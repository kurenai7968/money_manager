import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/database/sqlite/app_database.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/repositories/account_repository.dart';
import 'package:money_manager/repositories/transaction_repository.dart';

import '../support/test_stores.dart';

void main() {
  test('saves and reads an account', () async {
    await openTestDatabase();
    final repository = AccountRepositoryImpl(database: AppDatabase.instance);
    const account = AccountModel(
      id: 1,
      name: 'Bank',
      type: AccountType.bank,
      icon: 'other',
      sortOrder: 1,
    );

    await repository.save(account);
    final loaded = await repository.getAll();

    expect(loaded.single, account);
  });

  test('saves the default cash account languages', () async {
    await openTestDatabase();
    final repository = AccountRepositoryImpl(database: AppDatabase.instance);
    const cash = AccountModel(
      id: 1,
      languageEn: 'Cash',
      languageZh: '現金',
      languageZhCn: '现金',
      type: AccountType.cash,
      icon: 'other',
      sortOrder: 0,
    );

    await repository.save(cash);
    final loaded = await repository.getAll();

    expect(loaded.single, cash);
  });

  test('joins account balance and net worth', () async {
    await openTestDatabase();
    final accounts = AccountRepositoryImpl(database: AppDatabase.instance);
    final transactions = TransactionRepositoryImpl(
      database: AppDatabase.instance,
    );
    const cash = AccountModel(
      id: 1,
      name: 'Cash',
      type: AccountType.cash,
      icon: 'other',
      sortOrder: 0,
    );
    const card = AccountModel(
      id: 2,
      name: 'Card',
      type: AccountType.credit,
      icon: 'other',
      sortOrder: 1,
    );
    const old = AccountModel(
      id: 3,
      name: 'Old',
      type: AccountType.bank,
      icon: 'other',
      sortOrder: 2,
      isActive: false,
    );
    await accounts.save(cash);
    await accounts.save(card);
    await accounts.save(old);
    await transactions.save(
      TransactionModel(
        id: 4,
        type: TransactionType.expense,
        amount: 20.0,
        date: DateTime(2026, 10, 23),
        accountId: 2,
        categoryId: 8,
      ),
    );
    await transactions.save(
      TransactionModel(
        id: 5,
        type: TransactionType.transfer,
        amount: 20.0,
        date: DateTime(2026, 10, 24),
        fromAccountId: 1,
        toAccountId: 2,
      ),
    );
    await transactions.save(
      TransactionModel(
        id: 6,
        type: TransactionType.income,
        amount: 5.0,
        date: DateTime(2026, 10, 25),
        accountId: 3,
      ),
    );

    final balances = await accounts.balances();

    expect(balances.balanceById, {1: -20, 2: 0, 3: 5});
    expect(balances.netWorth, -20);
    expect(balances.accounts.map((account) => account.id), [1, 2, 3]);
  });

  test('counts income and expense from transactions', () async {
    await openTestDatabase();
    final accounts = AccountRepositoryImpl(database: AppDatabase.instance);
    final transactions = TransactionRepositoryImpl(
      database: AppDatabase.instance,
    );
    await accounts.save(
      const AccountModel(
        id: 1,
        name: 'Cash',
        type: AccountType.cash,
        icon: 'other',
        sortOrder: 0,
      ),
    );
    await accounts.save(
      const AccountModel(
        id: 2,
        name: 'Card',
        type: AccountType.credit,
        icon: 'other',
        sortOrder: 1,
      ),
    );
    await transactions.save(
      TransactionModel(
        id: 3,
        type: TransactionType.income,
        amount: 100.0,
        date: DateTime(2026, 10, 1),
        accountId: 1,
      ),
    );
    await transactions.save(
      TransactionModel(
        id: 4,
        type: TransactionType.expense,
        amount: 20.0,
        date: DateTime(2026, 10, 2),
        accountId: 1,
        categoryId: 8,
      ),
    );
    await transactions.save(
      TransactionModel(
        id: 5,
        type: TransactionType.expense,
        amount: 12.0,
        date: DateTime(2026, 10, 1),
        accountId: 2,
      ),
    );

    final balances = await accounts.balances();

    expect(balances.balanceById[1], 80);
    expect(balances.balanceById[2], 12);
    expect(balances.netWorth, 68);
  });

  test('counts an expense as a negative cash balance', () async {
    await openTestDatabase();
    final accounts = AccountRepositoryImpl(database: AppDatabase.instance);
    final transactions = TransactionRepositoryImpl(
      database: AppDatabase.instance,
    );
    await accounts.save(
      const AccountModel(
        id: 1,
        name: 'Cash',
        type: AccountType.cash,
        icon: 'other',
        sortOrder: 0,
      ),
    );
    await transactions.save(
      TransactionModel(
        id: 2,
        type: TransactionType.expense,
        amount: 5.0,
        date: DateTime(2026, 10, 1),
        accountId: 1,
      ),
    );

    final balances = await accounts.balances();

    expect(balances.balanceById[1], -5);
    expect(balances.netWorth, -5);
  });
}
