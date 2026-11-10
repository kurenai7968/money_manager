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
    final repository = AccountRepositoryImpl(database: AppDatabase.instance);
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

  test('joins account balance and net worth', () async {
    await openTestDatabase();
    final accounts = AccountRepositoryImpl(database: AppDatabase.instance);
    final transactions = TransactionRepositoryImpl(
      database: AppDatabase.instance,
    );
    const cash = AccountModel(
      id: 'cash',
      name: 'Cash',
      type: AccountType.cash,
      openingBalanceMinor: 10000,
      sortOrder: 0,
    );
    const card = AccountModel(
      id: 'card',
      name: 'Card',
      type: AccountType.credit,
      openingBalanceMinor: 0,
      sortOrder: 1,
    );
    const old = AccountModel(
      id: 'old',
      name: 'Old',
      type: AccountType.bank,
      openingBalanceMinor: 500,
      sortOrder: 2,
      archived: true,
    );
    await accounts.save(cash);
    await accounts.save(card);
    await accounts.save(old);
    await transactions.save(
      TransactionModel(
        id: 'meal',
        type: TransactionType.expense,
        amountMinor: 2000,
        date: DateTime(2026, 10, 23),
        accountId: 'card',
        categoryId: 'food',
      ),
    );
    await transactions.save(
      TransactionModel(
        id: 'pay',
        type: TransactionType.transfer,
        amountMinor: 2000,
        date: DateTime(2026, 10, 24),
        fromAccountId: 'cash',
        toAccountId: 'card',
      ),
    );

    final balances = await accounts.balances();

    expect(balances.balanceById, {'cash': 8000, 'card': 0, 'old': 500});
    expect(balances.netWorth, 8000);
    expect(balances.accounts.map((account) => account.id), [
      'cash',
      'card',
      'old',
    ]);
  });

  test('counts an opening transaction once', () async {
    await openTestDatabase();
    final accounts = AccountRepositoryImpl(database: AppDatabase.instance);
    final transactions = TransactionRepositoryImpl(
      database: AppDatabase.instance,
    );
    const cash = AccountModel(
      id: 'cash',
      name: 'Cash',
      type: AccountType.cash,
      openingBalanceMinor: 10000,
      sortOrder: 0,
    );
    const card = AccountModel(
      id: 'card',
      name: 'Card',
      type: AccountType.credit,
      openingBalanceMinor: 1200,
      sortOrder: 1,
    );
    await accounts.save(cash);
    await accounts.save(card);
    await transactions.save(
      TransactionModel(
        id: 'opening-cash',
        type: TransactionType.income,
        amountMinor: 10000,
        date: DateTime(2026, 10, 1),
        accountId: 'cash',
      ),
    );
    await transactions.save(
      TransactionModel(
        id: 'meal',
        type: TransactionType.expense,
        amountMinor: 2000,
        date: DateTime(2026, 10, 2),
        accountId: 'cash',
        categoryId: 'food',
      ),
    );
    await transactions.save(
      TransactionModel(
        id: 'opening-card',
        type: TransactionType.income,
        amountMinor: 1200,
        date: DateTime(2026, 10, 1),
        accountId: 'card',
      ),
    );

    final balances = await accounts.balances();

    expect(balances.balanceById['cash'], 8000);
    expect(balances.balanceById['card'], 1200);
    expect(balances.netWorth, 8000 - 1200);
  });

  test('counts a negative opening expense once', () async {
    await openTestDatabase();
    final accounts = AccountRepositoryImpl(database: AppDatabase.instance);
    final transactions = TransactionRepositoryImpl(
      database: AppDatabase.instance,
    );
    await accounts.save(
      const AccountModel(
        id: 'cash',
        name: 'Cash',
        type: AccountType.cash,
        openingBalanceMinor: -500,
        sortOrder: 0,
      ),
    );
    await transactions.save(
      TransactionModel(
        id: 'opening-cash',
        type: TransactionType.expense,
        amountMinor: 500,
        date: DateTime(2026, 10, 1),
        accountId: 'cash',
      ),
    );

    final balances = await accounts.balances();

    expect(balances.balanceById['cash'], -500);
    expect(balances.netWorth, -500);
  });
}
