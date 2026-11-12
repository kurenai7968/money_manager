import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/services/account_book_service.dart';

import '../support/memory_account_repository.dart';
import '../support/memory_category_repository.dart';
import '../support/memory_transaction_repository.dart';

void main() {
  late MemoryTransactionRepository repository;
  late MemoryAccountRepository accounts;
  late AccountBookService accountBook;

  setUp(() {
    repository = MemoryTransactionRepository();
    accounts = MemoryAccountRepository();
    accountBook = AccountBookServiceImpl(
      accounts: accounts,
      categories: MemoryCategoryRepository(),
      transactions: repository,
    );
  });

  const cash = AccountModel(
    id: 1,
    name: 'Cash',
    type: AccountType.cash,
    icon: 'other',
    sortOrder: 0,
  );

  final expense = TransactionModel(
    id: 2,
    type: TransactionType.expense,
    amount: 86.0,
    date: DateTime(2026, 10, 23),
    accountId: 1,
    categoryId: 3,
  );

  test('saves an expense', () async {
    final id = await accountBook.saveTransaction(expense);
    expect(id, 2);
    expect(repository.transactions.single.amount, 86);
  });

  test('saving a transaction leaves the account unchanged', () async {
    accounts.accounts.add(cash);
    await accountBook.saveTransaction(
      TransactionModel(
        id: 4,
        type: TransactionType.income,
        amount: 20.0,
        date: DateTime(2026, 10, 23),
        accountId: 1,
        categoryId: 5,
      ),
    );

    expect(accounts.accounts.single, cash);
    expect(repository.transactions.single.amount, 20);
  });

  test('deletes a transaction', () async {
    accounts.accounts.add(cash);
    repository.transactions.add(expense);
    await accountBook.deleteTransaction(2);
    expect(repository.transactions, isEmpty);
    expect(accounts.accounts.single, cash);
  });
}
