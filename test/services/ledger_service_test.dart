import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/services/ledger_service.dart';

import '../support/memory_account_repository.dart';
import '../support/memory_category_repository.dart';
import '../support/memory_transaction_repository.dart';

void main() {
  late MemoryTransactionRepository repository;
  late MemoryAccountRepository accounts;
  late LedgerService ledger;

  setUp(() {
    repository = MemoryTransactionRepository();
    accounts = MemoryAccountRepository();
    ledger = LedgerServiceImpl(
      accounts: accounts,
      categories: MemoryCategoryRepository(),
      transactions: repository,
    );
  });

  const cash = AccountModel(
    id: 'cash',
    name: 'Cash',
    type: AccountType.cash,
    openingBalanceMinor: 1500,
    sortOrder: 0,
  );

  final expense = TransactionModel(
    id: 'lunch',
    type: TransactionType.expense,
    amountMinor: 8600,
    date: DateTime(2026, 10, 23),
    accountId: 'cash',
    categoryId: 'food',
  );

  test('saves an expense', () async {
    await ledger.saveTransaction(expense);
    expect(repository.transactions.single.amountMinor, 8600);
  });

  test('writes the signed opening balance when that income is saved', () async {
    accounts.accounts.add(cash);
    await ledger.saveTransaction(
      TransactionModel(
        id: 'opening-cash',
        type: TransactionType.income,
        amountMinor: 2000,
        date: DateTime(2026, 10, 23),
        accountId: 'cash',
        categoryId: 'salary',
      ),
    );
    expect(accounts.accounts.single.openingBalanceMinor, 2000);
    expect(repository.transactions.single.id, 'opening-cash');
    expect(repository.transactions.single.amountMinor, 2000);
  });

  test(
    'writes a negative opening balance when that expense is saved',
    () async {
      accounts.accounts.add(cash);
      await ledger.saveTransaction(
        TransactionModel(
          id: 'opening-cash',
          type: TransactionType.expense,
          amountMinor: 400,
          date: DateTime(2026, 10, 23),
          accountId: 'cash',
          categoryId: 'food',
        ),
      );
      expect(accounts.accounts.single.openingBalanceMinor, -400);
      expect(repository.transactions.single.type, TransactionType.expense);
    },
  );

  test(
    'clears the opening balance when that transaction becomes a transfer',
    () async {
      accounts.accounts.add(cash);
      await ledger.saveTransaction(
        TransactionModel(
          id: 'opening-cash',
          type: TransactionType.transfer,
          amountMinor: 1500,
          date: DateTime(2026, 10, 23),
          fromAccountId: 'cash',
          toAccountId: 'bank',
        ),
      );
      expect(accounts.accounts.single.openingBalanceMinor, 0);
      final saved = repository.transactions.single;
      expect(saved.id, isNot('opening-cash'));
      expect(saved.type, TransactionType.transfer);
    },
  );

  test(
    'clears the opening balance when that transaction moves account',
    () async {
      accounts.accounts.add(cash);
      await ledger.saveTransaction(
        TransactionModel(
          id: 'opening-cash',
          type: TransactionType.income,
          amountMinor: 1500,
          date: DateTime(2026, 10, 23),
          accountId: 'bank',
          categoryId: 'salary',
        ),
      );
      expect(accounts.accounts.single.openingBalanceMinor, 0);
      final saved = repository.transactions.single;
      expect(saved.id, isNot('opening-cash'));
      expect(saved.accountId, 'bank');
    },
  );

  test('clears the opening balance when that transaction is deleted', () async {
    accounts.accounts.add(cash);
    repository.transactions.add(
      TransactionModel(
        id: 'opening-cash',
        type: TransactionType.income,
        amountMinor: 1500,
        date: DateTime(2026, 10, 23),
        accountId: 'cash',
        categoryId: 'salary',
      ),
    );
    await ledger.deleteTransaction('opening-cash');
    expect(accounts.accounts.single.openingBalanceMinor, 0);
    expect(repository.transactions, isEmpty);
  });

  test('deletes a transaction', () async {
    repository.transactions.add(expense);
    await ledger.deleteTransaction('lunch');
    expect(repository.transactions, isEmpty);
  });
}
