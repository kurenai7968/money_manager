import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/home/bloc/home_bloc.dart';
import 'package:money_manager/pages/home/bloc/home_event.dart';
import 'package:money_manager/pages/home/bloc/home_state.dart';
import 'package:money_manager/services/account_book_service.dart';
import 'package:money_manager/repositories/transaction_repository.dart';

import '../support/memory_account_repository.dart';
import '../support/memory_category_repository.dart';
import '../support/memory_transaction_repository.dart';

void main() {
  const now = _Now();

  late MemoryTransactionRepository transactionsRepo;
  late MemoryAccountRepository accountRepo;
  late MemoryCategoryRepository categoryRepo;

  setUp(() {
    accountRepo = MemoryAccountRepository();
    categoryRepo = MemoryCategoryRepository();
    transactionsRepo = MemoryTransactionRepository()
      ..transactions.add(
        TransactionModel(
          id: 'lunch',
          type: TransactionType.expense,
          amountMinor: 1800,
          date: DateTime(2026, 10, 15),
          accountId: 'cash',
          categoryId: 'food',
        ),
      )
      ..transactions.add(
        TransactionModel(
          id: 'move',
          type: TransactionType.transfer,
          amountMinor: 500,
          date: DateTime(2026, 10, 15),
          fromAccountId: 'cash',
          toAccountId: 'bank',
        ),
      );
  });

  HomeBloc buildBloc({TransactionRepository? transactions}) {
    return HomeBloc(
      accountBook: AccountBookServiceImpl(
        accounts: accountRepo,
        categories: categoryRepo,
        transactions: transactions ?? transactionsRepo,
      ),
      now: now,
    );
  }

  blocTest<HomeBloc, HomeState>(
    'totals the open month and ignores transfers',
    build: buildBloc,
    act: (bloc) {
      accountRepo.accounts.add(_account('cash', 0));
      bloc.add(const HomeInitialized());
    },
    expect: () => [
      isA<HomeState>()
          .having((state) => state.status, 'status', HomeStatus.success)
          .having((state) => state.figures.expenseMinor, 'expense', 1800)
          .having((state) => state.figures.incomeMinor, 'income', 0)
          .having((state) => state.transactions, 'month', hasLength(2))
          .having((state) => state.selectedTransactions, 'day', hasLength(2))
          .having((state) => state.days.single.netMinor, 'net', -1800),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'clears the selected day when the month is not the current one',
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const HomeInitialized());
      await bloc.stream.firstWhere(
        (state) => state.status == HomeStatus.success,
      );
      bloc.add(const HomeMonthShifted(1));
    },
    expect: () => [
      isA<HomeState>().having(
        (state) => state.selectedDay,
        'today',
        DateTime(2026, 10, 15),
      ),
      isA<HomeState>()
          .having((state) => state.month, 'month', DateTime(2026, 11))
          .having((state) => state.selectedDay, 'day', isNull)
          .having((state) => state.transactions, 'rows', isEmpty),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'emits failure when the account book cannot be read',
    build: () => buildBloc(transactions: _FailingTransactions()),
    act: (bloc) => bloc.add(const HomeInitialized()),
    expect: () => [
      isA<HomeState>()
          .having((state) => state.status, 'status', HomeStatus.failure)
          .having((state) => state.figures.expenseMinor, 'expense', 0)
          .having((state) => state.transactions, 'rows', isEmpty),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'limits the month to one account and can return to all',
    build: buildBloc,
    act: (bloc) async {
      accountRepo.accounts.add(_account('cash', 0));
      accountRepo.accounts.add(_account('bank', 1, type: AccountType.bank));
      transactionsRepo.transactions.add(
        TransactionModel(
          id: 'pay',
          type: TransactionType.income,
          amountMinor: 900,
          date: DateTime(2026, 10, 15),
          accountId: 'bank',
          categoryId: 'salary',
        ),
      );
      bloc.add(const HomeInitialized());
      await bloc.stream.firstWhere(
        (state) => state.status == HomeStatus.success,
      );
      bloc
        ..add(const HomeAccountSelected('bank'))
        ..add(const HomeAccountSelected('cash'))
        ..add(const HomeAccountSelected(null));
    },
    expect: () => [
      isA<HomeState>()
          .having((state) => state.selectedAccountId, 'account', isNull)
          .having((state) => state.figures.incomeMinor, 'income', 900)
          .having((state) => state.figures.expenseMinor, 'expense', 1800)
          .having((state) => state.transactions, 'rows', hasLength(3)),
      isA<HomeState>()
          .having((state) => state.selectedAccountId, 'account', 'bank')
          .having((state) => state.figures.incomeMinor, 'income', 900)
          .having((state) => state.figures.expenseMinor, 'expense', 0)
          .having((state) => state.transactions, 'rows', hasLength(2)),
      isA<HomeState>()
          .having((state) => state.selectedAccountId, 'account', 'cash')
          .having((state) => state.figures.incomeMinor, 'income', 0)
          .having((state) => state.figures.expenseMinor, 'expense', 1800)
          .having((state) => state.transactions, 'rows', hasLength(2))
          .having((state) => state.days.single.netMinor, 'net', -1800),
      isA<HomeState>()
          .having((state) => state.selectedAccountId, 'account', isNull)
          .having((state) => state.transactions, 'rows', hasLength(3)),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'returns to all when the selected account is missing or archived',
    build: buildBloc,
    act: (bloc) async {
      accountRepo.accounts.add(_account('cash', 0));
      bloc.add(const HomeInitialized());
      await bloc.stream.firstWhere(
        (state) => state.status == HomeStatus.success,
      );
      bloc
        ..add(const HomeAccountSelected('missing'))
        ..add(const HomeAccountSelected('cash'));
      await bloc.stream.firstWhere(
        (state) => state.selectedAccountId == 'cash',
      );
      accountRepo.accounts[0] = accountRepo.accounts[0].copyWith(
        archived: true,
      );
      bloc.add(const HomeInitialized());
    },
    expect: () => [
      isA<HomeState>().having(
        (state) => state.selectedAccountId,
        'account',
        isNull,
      ),
      isA<HomeState>()
          .having((state) => state.selectedAccountId, 'account', 'cash')
          .having((state) => state.transactions, 'rows', hasLength(2)),
      isA<HomeState>()
          .having((state) => state.selectedAccountId, 'account', isNull)
          .having((state) => state.transactions, 'rows', hasLength(2))
          .having(
            (state) => state.accounts.single.archived,
            'archived',
            isTrue,
          ),
    ],
  );
}

AccountModel _account(
  String id,
  int sortOrder, {
  AccountType type = AccountType.cash,
}) {
  return AccountModel(
    id: id,
    name: id,
    type: type,
    openingBalanceMinor: 0,
    sortOrder: sortOrder,
  );
}

class _Now {
  const _Now();

  DateTime call() => DateTime(2026, 10, 15);
}

class _FailingTransactions implements TransactionRepository {
  @override
  Future<int> countForCategory(String categoryId) async => 0;

  @override
  Future<void> delete(String id) async {}

  @override
  Future<List<TransactionModel>> getAll() async {
    throw StateError('unavailable');
  }

  @override
  Future<void> save(TransactionModel transaction) async {}
}
