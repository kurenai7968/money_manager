import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/core/utils/amount_expression.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_state.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_event.dart';
import 'package:money_manager/pages/categories/bloc/categories_state.dart';
import 'package:money_manager/pages/record/bloc/record_bloc.dart';
import 'package:money_manager/pages/record/bloc/record_event.dart';
import 'package:money_manager/pages/record/bloc/record_state.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_event.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_state.dart';

import '../support/memory_account_repository.dart';
import '../support/memory_category_repository.dart';
import '../support/memory_transaction_repository.dart';

void main() {
  late MemoryAccountRepository accountRepo;
  late MemoryTransactionRepository transactionRepo;
  late AccountsBloc accounts;
  late TransactionsBloc transactions;
  late CategoriesBloc categories;

  setUp(() {
    accountRepo = MemoryAccountRepository()
      ..accounts.add(
        const AccountModel(
          id: 'cash',
          name: 'Cash',
          type: AccountType.cash,
          openingBalanceMinor: 0,
          sortOrder: 0,
        ),
      );
    transactionRepo = MemoryTransactionRepository()
      ..transactions.add(
        TransactionModel(
          id: 'lunch',
          type: TransactionType.expense,
          amountMinor: 700,
          date: DateTime(2026, 10, 2),
          note: 'Lunch',
          accountId: 'cash',
          categoryId: 'food',
        ),
      );
    final categoriesRepo = MemoryCategoryRepository()
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
          sortOrder: 0,
        ),
      ]);
    accounts = AccountsBloc(accountRepo, transactionRepo);
    transactions = TransactionsBloc(transactionRepo, accountRepo);
    categories = CategoriesBloc(categoriesRepo);
  });

  tearDown(() async {
    await accounts.close();
    await transactions.close();
    await categories.close();
  });

  blocTest<RecordBloc, RecordState>(
    'rejects an empty amount, then saves the keypad result',
    build: () => RecordBloc(
      transactions: transactions,
      accounts: accounts,
      categories: categories,
      now: () => DateTime(2026, 10, 15),
    ),
    act: (bloc) async {
      await _load(accounts, transactions, categories);
      bloc.add(const RecordStarted());
      if (bloc.state.accountId == null) {
        await bloc.stream.firstWhere((state) => state.accountId != null);
      }
      bloc.add(const RecordSavePressed());
      bloc.add(const RecordDigitPressed('5'));
      bloc.add(const RecordSavePressed());
      if (!bloc.state.closePage) {
        await bloc.stream.firstWhere((state) => state.closePage);
      }
    },
    verify: (_) {
      expect(
        transactionRepo.transactions.where((item) => item.amountMinor == 500),
        hasLength(1),
      );
    },
    expect: () => [
      isA<RecordState>()
          .having((state) => state.accountId, 'account', 'cash')
          .having((state) => state.categoryId, 'category', 'food'),
      isA<RecordState>().having(
        (state) => state.error,
        'error',
        RecordError.invalid,
      ),
      isA<RecordState>().having(
        (state) => state.expression.display,
        'display',
        '5',
      ),
      isA<RecordState>().having((state) => state.closePage, 'close', isTrue),
    ],
  );

  blocTest<RecordBloc, RecordState>(
    'rejects a transfer that uses one account',
    build: () => RecordBloc(
      transactions: transactions,
      accounts: accounts,
      categories: categories,
      now: () => DateTime(2026, 10, 15),
    ),
    act: (bloc) async {
      await _load(accounts, transactions, categories);
      bloc.add(const RecordStarted(initialType: TransactionType.transfer));
      if (bloc.state.type != TransactionType.transfer) {
        await bloc.stream.firstWhere(
          (state) => state.type == TransactionType.transfer,
        );
      }
      bloc.add(const RecordDigitPressed('2'));
      bloc.add(const RecordSavePressed());
    },
    expect: () => [
      isA<RecordState>().having(
        (state) => state.type,
        'type',
        TransactionType.transfer,
      ),
      isA<RecordState>(),
      isA<RecordState>().having(
        (state) => state.error,
        'error',
        RecordError.needDifferentAccounts,
      ),
    ],
  );

  blocTest<RecordBloc, RecordState>(
    'loads an existing transaction and evaluates the expression',
    build: () => RecordBloc(
      transactions: transactions,
      accounts: accounts,
      categories: categories,
      now: () => DateTime(2026, 10, 15),
    ),
    act: (bloc) async {
      await _load(accounts, transactions, categories);
      bloc.add(const RecordStarted(transactionId: 'lunch'));
      if (bloc.state.note != 'Lunch') {
        await bloc.stream.firstWhere((state) => state.note == 'Lunch');
      }
      bloc.add(const RecordClearPressed());
      bloc.add(const RecordDigitPressed('1'));
      bloc.add(const RecordOperatorPressed(AmountOperator.add));
      bloc.add(const RecordDigitPressed('2'));
      bloc.add(const RecordEqualsPressed());
    },
    expect: () => [
      isA<RecordState>()
          .having((state) => state.note, 'note', 'Lunch')
          .having((state) => state.expression.display, 'amount', '7'),
      isA<RecordState>(),
      isA<RecordState>(),
      isA<RecordState>(),
      isA<RecordState>(),
      isA<RecordState>().having(
        (state) => state.expression.resultMinor,
        'result',
        300,
      ),
    ],
  );
}

Future<void> _load(
  AccountsBloc accounts,
  TransactionsBloc transactions,
  CategoriesBloc categories,
) async {
  accounts.add(const AccountsStarted());
  transactions.add(const TransactionsStarted());
  categories.add(const CategoriesStarted([]));
  await _until(
    accounts,
    (state) =>
        state.status == AccountsStatus.success ||
        state.status == AccountsStatus.failure,
  );
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
}

Future<void> _until<S>(BlocBase<S> bloc, bool Function(S state) done) async {
  if (done(bloc.state)) {
    return;
  }
  await bloc.stream.firstWhere(done);
}
