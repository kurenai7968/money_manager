import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_event.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_state.dart';

import '../support/memory_transaction_repository.dart';

void main() {
  late MemoryTransactionRepository repository;

  setUp(() {
    repository = MemoryTransactionRepository();
  });

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
    build: () => TransactionsBloc(repository),
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
    build: () => TransactionsBloc(repository),
    act: (bloc) => bloc.add(TransactionSavePressed(expense)),
    verify: (bloc) {
      expect(bloc.state.transactions.single.amountMinor, 8600);
    },
  );

  blocTest<TransactionsBloc, TransactionsState>(
    'rejects a transfer between the same account',
    build: () => TransactionsBloc(repository),
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
    'deletes a transaction',
    build: () => TransactionsBloc(repository),
    setUp: () {
      repository.transactions.add(expense);
    },
    act: (bloc) => bloc.add(const TransactionDeletePressed('lunch')),
    verify: (bloc) {
      expect(bloc.state.transactions, isEmpty);
    },
  );
}
