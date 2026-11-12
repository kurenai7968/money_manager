import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/analysis/bloc/analysis_bloc.dart';
import 'package:money_manager/pages/analysis/bloc/analysis_event.dart';
import 'package:money_manager/pages/analysis/bloc/analysis_state.dart';
import 'package:money_manager/services/account_book_service.dart';
import 'package:money_manager/repositories/transaction_repository.dart';

import '../support/memory_account_repository.dart';
import '../support/memory_category_repository.dart';
import '../support/memory_transaction_repository.dart';

void main() {
  late MemoryTransactionRepository transactionsRepo;
  late MemoryAccountRepository accountRepo;
  late MemoryCategoryRepository categoryRepo;

  setUp(() {
    transactionsRepo = MemoryTransactionRepository()
      ..transactions.addAll([
        TransactionModel(
          id: 1,
          type: TransactionType.expense,
          amount: 4.0,
          date: DateTime(2026, 10, 3),
          accountId: 2,
          categoryId: 3,
        ),
        TransactionModel(
          id: 4,
          type: TransactionType.expense,
          amount: 1.0,
          date: DateTime(2026, 9, 3),
          accountId: 2,
          categoryId: 3,
        ),
        TransactionModel(
          id: 5,
          type: TransactionType.income,
          amount: 0.5,
          date: DateTime(2026, 10, 4),
          accountId: 2,
          categoryId: 6,
        ),
        TransactionModel(
          id: 7,
          type: TransactionType.transfer,
          amount: 9.0,
          date: DateTime(2026, 10, 5),
          fromAccountId: 2,
          toAccountId: 8,
        ),
      ]);
    categoryRepo = MemoryCategoryRepository()
      ..categories.addAll(const [
        CategoryModel(
          id: 3,
          name: 'Food',
          icon: 'restaurant',
          type: CategoryKind.expense,
          sortOrder: 0,
        ),
        CategoryModel(
          id: 6,
          name: 'Salary',
          icon: 'payments',
          type: CategoryKind.income,
          sortOrder: 1,
        ),
      ]);
    accountRepo = MemoryAccountRepository()..accounts.add(_cash);
  });

  AnalysisBloc buildBloc({TransactionRepository? transactions}) {
    return AnalysisBloc(
      accountBook: AccountBookServiceImpl(
        accounts: accountRepo,
        categories: categoryRepo,
        transactions: transactions ?? transactionsRepo,
      ),
      now: () => DateTime(2026, 10, 15),
    );
  }

  blocTest<AnalysisBloc, AnalysisState>(
    'compares expense with last month and ignores transfers',
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const AnalysisInitialized());
      await bloc.stream.firstWhere(
        (state) => state.status == AnalysisStatus.success,
      );
      bloc.add(const AnalysisKindSelected(CategoryKind.income));
    },
    expect: () => [
      isA<AnalysisState>()
          .having((state) => state.rollup.current, 'current', 4.0)
          .having((state) => state.rollup.previous, 'previous', 1.0)
          .having(
            (state) => state.rollup.byCategory.single.sharePercent,
            'share',
            100,
          )
          .having((state) => state.rollup.byAccount, 'accounts', hasLength(1)),
      isA<AnalysisState>()
          .having((state) => state.kind, 'kind', CategoryKind.income)
          .having((state) => state.rollup.current, 'current', 0.5)
          .having((state) => state.rollup.previous, 'previous', 0.0),
    ],
  );

  blocTest<AnalysisBloc, AnalysisState>(
    'emits an empty rollup when transactions cannot be read',
    build: () => buildBloc(transactions: _FailingTransactions()),
    act: (bloc) => bloc.add(const AnalysisInitialized()),
    expect: () => [
      isA<AnalysisState>()
          .having((state) => state.status, 'status', AnalysisStatus.failure)
          .having((state) => state.rollup.current, 'current', 0.0)
          .having((state) => state.rollup.byCategory, 'categories', isEmpty),
    ],
  );
}

const _cash = AccountModel(
  id: 2,
  name: 'Cash',
  type: AccountType.cash,
  icon: 'other',
  sortOrder: 0,
);

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
