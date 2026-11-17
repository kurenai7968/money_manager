import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/home/bloc/home_bloc.dart';
import 'package:money_manager/pages/home/bloc/home_event.dart';
import 'package:money_manager/pages/home/bloc/home_state.dart';
import 'package:money_manager/repositories/transaction_repository.dart';
import 'package:money_manager/services/account_book_service.dart';

import '../support/memory_account_repository.dart';
import '../support/memory_category_repository.dart';
import '../support/memory_transaction_repository.dart';

void main() {
  final today = DateTime.now();
  final day = DateTime(today.year, today.month, today.day);
  final nextMonth = DateTime(today.year, today.month + 1);

  late MemoryTransactionRepository transactionsRepo;
  late MemoryAccountRepository accountRepo;
  late MemoryCategoryRepository categoryRepo;

  setUp(() {
    accountRepo = MemoryAccountRepository();
    categoryRepo = MemoryCategoryRepository();
    transactionsRepo = MemoryTransactionRepository()
      ..transactions.add(
        TransactionModel(
          id: 3,
          type: TransactionType.expense,
          amount: 18.0,
          date: day,
          accountId: 1,
          categoryId: 4,
        ),
      )
      ..transactions.add(
        TransactionModel(
          id: 5,
          type: TransactionType.transfer,
          amount: 5.0,
          date: day,
          fromAccountId: 1,
          toAccountId: 2,
        ),
      );
  });

  HomeBloc buildBloc({TransactionRepository? transactions}) {
    return HomeBloc(
      accountBookService: AccountBookServiceImpl(
        accounts: accountRepo,
        categories: categoryRepo,
        transactions: transactions ?? transactionsRepo,
      ),
    );
  }

  blocTest<HomeBloc, HomeState>(
    'totals the open month and ignores transfers',
    build: buildBloc,
    act: (bloc) {
      accountRepo.accounts.add(_account(1, 0));
      bloc.add(const HomeInitialized());
    },
    expect: () => [
      isA<HomeState>().having(
        (state) => state.status,
        'status',
        HomeStatus.loading,
      ),
      isA<HomeState>()
          .having((state) => state.status, 'status', HomeStatus.success)
          .having((state) => state.expense, 'expense', 18)
          .having((state) => state.income, 'income', 0)
          .having((state) => state.balance, 'balance', -18)
          .having((state) => state.transactions, 'month', hasLength(2))
          .having(
            (state) => state.days.single.transactions,
            'day',
            hasLength(2),
          )
          .having((state) => state.days.single.net, 'net', -18),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'selects the first day of the next month and the last day of the previous month',
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const HomeInitialized());
      await bloc.stream.firstWhere(
        (state) => state.status == HomeStatus.success,
      );
      bloc.add(const HomeMonthShifted(1));
      await bloc.stream.firstWhere((state) => state.month == nextMonth);
      bloc
        ..add(const HomeMonthShifted(-1))
        ..add(const HomeMonthShifted(-1));
    },
    expect: () => [
      isA<HomeState>().having(
        (state) => state.status,
        'status',
        HomeStatus.loading,
      ),
      isA<HomeState>().having((state) => state.selectedDay, 'today', day),
      isA<HomeState>()
          .having((state) => state.month, 'month', nextMonth)
          .having(
            (state) => state.selectedDay,
            'day',
            DateTime(nextMonth.year, nextMonth.month, 1),
          )
          .having((state) => state.transactions, 'rows', isEmpty),
      isA<HomeState>()
          .having(
            (state) => state.month,
            'month',
            DateTime(today.year, today.month),
          )
          .having(
            (state) => state.selectedDay,
            'day',
            DateTime(today.year, today.month + 1, 0),
          ),
      isA<HomeState>()
          .having(
            (state) => state.month,
            'month',
            DateTime(today.year, today.month - 1),
          )
          .having(
            (state) => state.selectedDay,
            'day',
            DateTime(today.year, today.month, 0),
          ),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'jumps to a later month on its first day and an earlier month on its last day',
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const HomeInitialized());
      await bloc.stream.firstWhere(
        (state) => state.status == HomeStatus.success,
      );
      bloc
        ..add(HomeMonthSelected(DateTime(today.year, today.month, 20)))
        ..add(HomeMonthSelected(DateTime(2031, 8, 15)))
        ..add(HomeMonthSelected(DateTime(2020, 2, 15)));
    },
    expect: () => [
      isA<HomeState>().having(
        (state) => state.status,
        'status',
        HomeStatus.loading,
      ),
      isA<HomeState>().having((state) => state.selectedDay, 'today', day),
      isA<HomeState>()
          .having((state) => state.month, 'month', DateTime(2031, 8))
          .having((state) => state.selectedDay, 'day', DateTime(2031, 8, 1)),
      isA<HomeState>()
          .having((state) => state.month, 'month', DateTime(2020, 2))
          .having((state) => state.selectedDay, 'day', DateTime(2020, 2, 29)),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'emits failure when the account book cannot be read',
    build: () => buildBloc(transactions: _FailingTransactions()),
    act: (bloc) => bloc.add(const HomeInitialized()),
    expect: () => [
      isA<HomeState>().having(
        (state) => state.status,
        'status',
        HomeStatus.loading,
      ),
      isA<HomeState>()
          .having((state) => state.status, 'status', HomeStatus.failure)
          .having((state) => state.expense, 'expense', 0)
          .having((state) => state.income, 'income', 0)
          .having((state) => state.balance, 'balance', 0)
          .having((state) => state.transactions, 'rows', isEmpty),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'limits the month to one account and can return to all',
    build: buildBloc,
    act: (bloc) async {
      accountRepo.accounts.add(_account(1, 0));
      accountRepo.accounts.add(_account(2, 1, type: AccountType.bank));
      transactionsRepo.transactions.add(
        TransactionModel(
          id: 6,
          type: TransactionType.income,
          amount: 9.0,
          date: day,
          accountId: 2,
          categoryId: 7,
        ),
      );
      bloc.add(const HomeInitialized());
      await bloc.stream.firstWhere(
        (state) => state.status == HomeStatus.success,
      );
      bloc
        ..add(const HomeAccountSelected(2))
        ..add(const HomeAccountSelected(1))
        ..add(const HomeAccountSelected(null));
    },
    expect: () => [
      isA<HomeState>().having(
        (state) => state.status,
        'status',
        HomeStatus.loading,
      ),
      isA<HomeState>()
          .having((state) => state.selectedAccountId, 'account', isNull)
          .having((state) => state.income, 'income', 9)
          .having((state) => state.expense, 'expense', 18)
          .having((state) => state.balance, 'balance', -9)
          .having((state) => state.transactions, 'rows', hasLength(3)),
      isA<HomeState>()
          .having((state) => state.selectedAccountId, 'account', 2)
          .having((state) => state.income, 'income', 9)
          .having((state) => state.expense, 'expense', 0)
          .having((state) => state.balance, 'balance', 9)
          .having((state) => state.transactions, 'rows', hasLength(2)),
      isA<HomeState>()
          .having((state) => state.selectedAccountId, 'account', 1)
          .having((state) => state.income, 'income', 0)
          .having((state) => state.expense, 'expense', 18)
          .having((state) => state.balance, 'balance', -18)
          .having((state) => state.transactions, 'rows', hasLength(2))
          .having((state) => state.days.single.net, 'net', -18),
      isA<HomeState>()
          .having((state) => state.selectedAccountId, 'account', isNull)
          .having((state) => state.transactions, 'rows', hasLength(3)),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'returns to all when the selected account is missing or inactive',
    build: buildBloc,
    act: (bloc) async {
      accountRepo.accounts.add(_account(1, 0));
      bloc.add(const HomeInitialized());
      await bloc.stream.firstWhere(
        (state) => state.status == HomeStatus.success,
      );
      bloc
        ..add(const HomeAccountSelected(99))
        ..add(const HomeAccountSelected(1));
      await bloc.stream.firstWhere((state) => state.selectedAccountId == 1);
      accountRepo.accounts[0] = accountRepo.accounts[0].copyWith(
        isActive: false,
      );
      bloc.add(const HomeInitialized());
    },
    expect: () => [
      isA<HomeState>().having(
        (state) => state.status,
        'status',
        HomeStatus.loading,
      ),
      isA<HomeState>()
          .having((state) => state.status, 'status', HomeStatus.success)
          .having((state) => state.selectedAccountId, 'account', isNull),
      isA<HomeState>()
          .having((state) => state.selectedAccountId, 'account', 1)
          .having((state) => state.transactions, 'rows', hasLength(2)),
      isA<HomeState>().having(
        (state) => state.status,
        'status',
        HomeStatus.loading,
      ),
      isA<HomeState>()
          .having((state) => state.selectedAccountId, 'account', isNull)
          .having((state) => state.transactions, 'rows', hasLength(2))
          .having((state) => state.accounts.single.isActive, 'active', isFalse),
    ],
  );
}

AccountModel _account(
  int id,
  int sortOrder, {
  AccountType type = AccountType.cash,
}) {
  return AccountModel(
    id: id,
    name: 'Account $id',
    type: type,
    icon: 'other',
    sortOrder: sortOrder,
  );
}

class _FailingTransactions implements TransactionRepository {
  @override
  Future<int> countForCategory(int categoryId) async => 0;

  @override
  Future<void> delete(int id) async {}

  @override
  Future<List<TransactionModel>> getAll() async {
    throw StateError('unavailable');
  }

  @override
  Future<int> save(TransactionModel transaction) async => 0;
}
