import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/analysis/bloc/analysis_bloc.dart';
import 'package:money_manager/pages/analysis/bloc/analysis_event.dart';
import 'package:money_manager/pages/analysis/bloc/analysis_state.dart';
import 'package:money_manager/services/ledger_service.dart';
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
    categoryRepo = MemoryCategoryRepository()
      ..categories.addAll(const [
        CategoryModel(
          id: 'food',
          name: 'Food',
          icon: 'restaurant',
          color: 'coral',
          kind: CategoryKind.expense,
          sortOrder: 0,
        ),
        CategoryModel(
          id: 'salary',
          name: 'Salary',
          icon: 'payments',
          color: 'green',
          kind: CategoryKind.income,
          sortOrder: 1,
        ),
      ]);
    accountRepo = MemoryAccountRepository()..accounts.add(_cash);
  });

  AnalysisBloc buildBloc({TransactionRepository? transactions}) {
    return AnalysisBloc(
      ledger: LedgerServiceImpl(
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
    build: () => buildBloc(transactions: _FailingTransactions()),
    act: (bloc) => bloc.add(const AnalysisInitialized()),
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
