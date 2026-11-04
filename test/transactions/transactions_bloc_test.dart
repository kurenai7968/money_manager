import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_event.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_state.dart';

import '../support/memory_account_repository.dart';
import '../support/memory_transaction_repository.dart';

void main() {
  late MemoryTransactionRepository repository;
  late MemoryAccountRepository accounts;

  setUp(() {
    repository = MemoryTransactionRepository();
    accounts = MemoryAccountRepository();
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

  blocTest<TransactionsBloc, TransactionsState>(
    'rejects a zero amount',
    build: () => TransactionsBloc(repository, accounts),
    act: (bloc) =>
        bloc.add(TransactionSavePressed(expense.copyWith(amountMinor: 0))),
    expect: () => const [
      TransactionsState(
        status: TransactionsStatus.failure,
        error: TransactionsError.invalid,
      ),
    ],
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'saves an expense',
    build: () => TransactionsBloc(repository, accounts),
    act: (bloc) => bloc.add(TransactionSavePressed(expense)),
    verify: (bloc) {
      expect(bloc.state.transactions.single.amountMinor, 8600);
    },
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'rejects a transfer between the same account',
    build: () => TransactionsBloc(repository, accounts),
    act: (bloc) => bloc.add(
      TransactionSavePressed(
        TransactionModel(
          id: 'move',
          type: TransactionType.transfer,
          amountMinor: 100,
          date: DateTime(2026, 10, 23),
          fromAccountId: 'cash',
          toAccountId: 'cash',
        ),
      ),
    ),
    expect: () => const [
      TransactionsState(
        status: TransactionsStatus.failure,
        error: TransactionsError.invalid,
      ),
    ],
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'writes the signed opening balance when that income is saved',
    build: () => TransactionsBloc(repository, accounts),
    setUp: () {
      accounts.accounts.add(cash);
    },
    act: (bloc) => bloc.add(
      TransactionSavePressed(
        TransactionModel(
          id: 'opening-cash',
          type: TransactionType.income,
          amountMinor: 2000,
          date: DateTime(2026, 10, 23),
          accountId: 'cash',
          categoryId: 'salary',
        ),
      ),
    ),
    verify: (bloc) {
      expect(accounts.accounts.single.openingBalanceMinor, 2000);
      expect(bloc.state.transactions.single.id, 'opening-cash');
      expect(bloc.state.transactions.single.amountMinor, 2000);
    },
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'writes a negative opening balance when that expense is saved',
    build: () => TransactionsBloc(repository, accounts),
    setUp: () {
      accounts.accounts.add(cash);
    },
    act: (bloc) => bloc.add(
      TransactionSavePressed(
        TransactionModel(
          id: 'opening-cash',
          type: TransactionType.expense,
          amountMinor: 400,
          date: DateTime(2026, 10, 23),
          accountId: 'cash',
          categoryId: 'food',
        ),
      ),
    ),
    verify: (bloc) {
      expect(accounts.accounts.single.openingBalanceMinor, -400);
      expect(bloc.state.transactions.single.type, TransactionType.expense);
    },
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'clears the opening balance when that transaction becomes a transfer',
    build: () => TransactionsBloc(repository, accounts),
    setUp: () {
      accounts.accounts.add(cash);
    },
    act: (bloc) => bloc.add(
      TransactionSavePressed(
        TransactionModel(
          id: 'opening-cash',
          type: TransactionType.transfer,
          amountMinor: 1500,
          date: DateTime(2026, 10, 23),
          fromAccountId: 'cash',
          toAccountId: 'bank',
        ),
      ),
    ),
    verify: (bloc) {
      expect(accounts.accounts.single.openingBalanceMinor, 0);
      final saved = bloc.state.transactions.single;
      expect(saved.id, isNot('opening-cash'));
      expect(saved.type, TransactionType.transfer);
    },
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'clears the opening balance when that transaction moves account',
    build: () => TransactionsBloc(repository, accounts),
    setUp: () {
      accounts.accounts.add(cash);
    },
    act: (bloc) => bloc.add(
      TransactionSavePressed(
        TransactionModel(
          id: 'opening-cash',
          type: TransactionType.income,
          amountMinor: 1500,
          date: DateTime(2026, 10, 23),
          accountId: 'bank',
          categoryId: 'salary',
        ),
      ),
    ),
    verify: (bloc) {
      expect(accounts.accounts.single.openingBalanceMinor, 0);
      final saved = bloc.state.transactions.single;
      expect(saved.id, isNot('opening-cash'));
      expect(saved.accountId, 'bank');
    },
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'clears the opening balance when that transaction is deleted',
    build: () => TransactionsBloc(repository, accounts),
    setUp: () {
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
    },
    act: (bloc) => bloc.add(const TransactionDeletePressed('opening-cash')),
    verify: (bloc) {
      expect(accounts.accounts.single.openingBalanceMinor, 0);
      expect(bloc.state.transactions, isEmpty);
    },
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'deletes a transaction',
    build: () => TransactionsBloc(repository, accounts),
    setUp: () {
      repository.transactions.add(expense);
    },
    act: (bloc) => bloc.add(const TransactionDeletePressed('lunch')),
    verify: (bloc) {
      expect(bloc.state.transactions, isEmpty);
    },
  );
}
