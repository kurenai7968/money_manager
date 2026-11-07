import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_defaults.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_state.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_event.dart';
import 'package:money_manager/pages/categories/bloc/categories_state.dart';
import 'package:money_manager/pages/home/bloc/home_bloc.dart';
import 'package:money_manager/pages/home/bloc/home_event.dart';
import 'package:money_manager/pages/home/bloc/home_state.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_event.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_state.dart';
import 'package:money_manager/repositories/transaction_repository.dart';

import '../support/memory_account_repository.dart';
import '../support/memory_category_repository.dart';
import '../support/memory_transaction_repository.dart';

void main() {
  const now = _Now();

  late MemoryTransactionRepository transactionsRepo;
  late MemoryAccountRepository accountRepo;
  late TransactionsBloc transactions;
  late CategoriesBloc categories;
  late AccountsBloc accounts;

  setUp(() {
    accountRepo = MemoryAccountRepository();
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
    transactions = TransactionsBloc(
      transactionsRepo,
      MemoryAccountRepository(),
    );
    categories = CategoriesBloc(MemoryCategoryRepository());
    accounts = AccountsBloc(accountRepo, transactionsRepo);
  });

  tearDown(() async {
    await transactions.close();
    await categories.close();
    await accounts.close();
  });

  blocTest<HomeBloc, HomeState>(
    'totals the open month and ignores transfers',
    build: () => HomeBloc(
      transactions: transactions,
      categories: categories,
      accounts: accounts,
      now: now,
    ),
    act: (bloc) async {
      await _load(transactions, categories, accounts);
      bloc.add(const HomeStarted());
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
    build: () => HomeBloc(
      transactions: transactions,
      categories: categories,
      accounts: accounts,
      now: now,
    ),
    act: (bloc) async {
      await _load(transactions, categories, accounts);
      bloc.add(const HomeStarted());
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
    'emits failure when the ledger cannot be read',
    build: () => HomeBloc(
      transactions: transactions,
      categories: categories,
      accounts: accounts,
      now: now,
    ),
    setUp: () async {
      await transactions.close();
      transactions = TransactionsBloc(
        _FailingTransactions(),
        MemoryAccountRepository(),
      );
    },
    act: (bloc) async {
      await _load(transactions, categories, accounts);
      bloc.add(const HomeStarted());
    },
    expect: () => [
      isA<HomeState>()
          .having((state) => state.status, 'status', HomeStatus.failure)
          .having((state) => state.figures.expenseMinor, 'expense', 0)
          .having((state) => state.transactions, 'rows', isEmpty),
    ],
  );

  blocTest<HomeBloc, HomeState>(
    'limits the month to one account and can return to all',
    build: () => HomeBloc(
      transactions: transactions,
      categories: categories,
      accounts: accounts,
      now: now,
    ),
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
      await _load(transactions, categories, accounts);
      bloc.add(const HomeStarted());
      bloc.add(const HomeAccountSelected('bank'));
      bloc.add(const HomeAccountSelected('cash'));
      bloc.add(const HomeAccountSelected(null));
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
    build: () => HomeBloc(
      transactions: transactions,
      categories: categories,
      accounts: accounts,
      now: now,
    ),
    act: (bloc) async {
      accountRepo.accounts.add(_account('cash', 0));
      await _load(transactions, categories, accounts);
      bloc.add(const HomeStarted());
      bloc.add(const HomeAccountSelected('missing'));
      bloc.add(const HomeAccountSelected('cash'));
      accountRepo.accounts[0] = accountRepo.accounts[0].copyWith(
        archived: true,
      );
      accounts.add(const AccountsStarted());
      await _until(accounts, (state) => state.status == AccountsStatus.success);
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

Future<void> _load(
  TransactionsBloc transactions,
  CategoriesBloc categories,
  AccountsBloc accounts,
) async {
  transactions.add(const TransactionsStarted());
  categories.add(CategoriesStarted(defaultCategories()));
  accounts.add(const AccountsStarted());
  await _until(
    transactions,
    (state) =>
        state.status == TransactionsStatus.success ||
        state.status == TransactionsStatus.failure,
  );
  await _until(
    categories,
    (state) =>
        state.status == CategoriesStatus.success ||
        state.status == CategoriesStatus.failure,
  );
  await _until(
    accounts,
    (state) =>
        state.status == AccountsStatus.success ||
        state.status == AccountsStatus.failure,
  );
}

Future<void> _until<S>(BlocBase<S> bloc, bool Function(S state) done) async {
  if (done(bloc.state)) {
    return;
  }
  await bloc.stream.firstWhere(done);
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
