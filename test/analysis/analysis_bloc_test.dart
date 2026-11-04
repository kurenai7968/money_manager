import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_state.dart';
import 'package:money_manager/pages/analysis/bloc/analysis_bloc.dart';
import 'package:money_manager/pages/analysis/bloc/analysis_event.dart';
import 'package:money_manager/pages/analysis/bloc/analysis_state.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_event.dart';
import 'package:money_manager/pages/categories/bloc/categories_state.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_event.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_state.dart';
import 'package:money_manager/repositories/transaction_repository.dart';

import '../support/memory_account_repository.dart';
import '../support/memory_category_repository.dart';
import '../support/memory_transaction_repository.dart';

void main() {
  late MemoryTransactionRepository transactionsRepo;
  late TransactionsBloc transactions;
  late CategoriesBloc categories;
  late AccountsBloc accounts;

  setUp(() {
    transactionsRepo = MemoryTransactionRepository()
      ..transactions.addAll([
        TransactionModel(
          id: 'lunch',
          type: TransactionType.expense,
          amountMinor: 400,
          date: DateTime(2026, 10, 3),
          accountId: 'cash',
          categoryId: 'food',
        ),
        TransactionModel(
          id: 'older',
          type: TransactionType.expense,
          amountMinor: 100,
          date: DateTime(2026, 9, 3),
          accountId: 'cash',
          categoryId: 'food',
        ),
        TransactionModel(
          id: 'pay',
          type: TransactionType.income,
          amountMinor: 50,
          date: DateTime(2026, 10, 4),
          accountId: 'cash',
          categoryId: 'salary',
        ),
        TransactionModel(
          id: 'move',
          type: TransactionType.transfer,
          amountMinor: 900,
          date: DateTime(2026, 10, 5),
          fromAccountId: 'cash',
          toAccountId: 'bank',
        ),
      ]);
    final categoriesRepo = MemoryCategoryRepository()
      ..categories.addAll([
        const CategoryModel(
          id: 'food',
          name: 'Food',
          icon: 'restaurant',
          color: 'coral',
          kind: CategoryKind.expense,
          sortOrder: 0,
        ),
        const CategoryModel(
          id: 'salary',
          name: 'Salary',
          icon: 'payments',
          color: 'green',
          kind: CategoryKind.income,
          sortOrder: 1,
        ),
      ]);
    transactions = TransactionsBloc(
      transactionsRepo,
      MemoryAccountRepository(),
    );
    categories = CategoriesBloc(categoriesRepo);
    accounts = AccountsBloc(
      MemoryAccountRepository()..accounts.add(_cash),
      transactionsRepo,
    );
  });

  tearDown(() async {
    await transactions.close();
    await categories.close();
    await accounts.close();
  });

  blocTest<AnalysisBloc, AnalysisState>(
    'compares expense with last month and ignores transfers',
    build: () => AnalysisBloc(
      transactions: transactions,
      categories: categories,
      accounts: accounts,
      now: () => DateTime(2026, 10, 15),
    ),
    act: (bloc) async {
      await _load(transactions, categories, accounts);
      bloc.add(const AnalysisStarted());
      bloc.add(const AnalysisKindSelected(CategoryKind.income));
    },
    expect: () => [
      isA<AnalysisState>()
          .having((state) => state.rollup.current, 'current', 400)
          .having((state) => state.rollup.previous, 'previous', 100)
          .having(
            (state) => state.rollup.byCategory.single.sharePercent,
            'share',
            100,
          )
          .having((state) => state.rollup.byAccount, 'accounts', hasLength(1)),
      isA<AnalysisState>()
          .having((state) => state.kind, 'kind', CategoryKind.income)
          .having((state) => state.rollup.current, 'current', 50)
          .having((state) => state.rollup.previous, 'previous', 0),
    ],
  );

  blocTest<AnalysisBloc, AnalysisState>(
    'emits an empty rollup when transactions cannot be read',
    setUp: () async {
      await transactions.close();
      transactions = TransactionsBloc(
        _FailingTransactions(),
        MemoryAccountRepository(),
      );
    },
    build: () => AnalysisBloc(
      transactions: transactions,
      categories: categories,
      accounts: accounts,
      now: () => DateTime(2026, 10, 15),
    ),
    act: (bloc) async {
      await _load(transactions, categories, accounts);
      bloc.add(const AnalysisStarted());
    },
    expect: () => [
      isA<AnalysisState>()
          .having((state) => state.status, 'status', AnalysisStatus.failure)
          .having((state) => state.rollup.current, 'current', 0)
          .having((state) => state.rollup.byCategory, 'categories', isEmpty),
    ],
  );
}

const _cash = AccountModel(
  id: 'cash',
  name: 'Cash',
  type: AccountType.cash,
  openingBalanceMinor: 0,
  sortOrder: 0,
);

Future<void> _load(
  TransactionsBloc transactions,
  CategoriesBloc categories,
  AccountsBloc accounts,
) async {
  transactions.add(const TransactionsStarted());
  categories.add(const CategoriesStarted([]));
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
  Future<List<TransactionModel>> getAll() async =>
      throw StateError('unavailable');

  @override
  Future<void> save(TransactionModel transaction) async {}
}
