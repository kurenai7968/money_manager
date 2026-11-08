import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/pages/record/models/amount_expression.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/record/bloc/record_bloc.dart';
import 'package:money_manager/pages/record/bloc/record_event.dart';
import 'package:money_manager/pages/record/bloc/record_state.dart';
import 'package:money_manager/services/ledger_service.dart';

import '../support/memory_account_repository.dart';
import '../support/memory_category_repository.dart';
import '../support/memory_transaction_repository.dart';

void main() {
  late MemoryAccountRepository accountRepo;
  late MemoryTransactionRepository transactionRepo;
  late MemoryCategoryRepository categoryRepo;

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
          sortOrder: 0,
        ),
      ]);
  });

  RecordBloc buildBloc() {
    return RecordBloc(
      ledger: LedgerServiceImpl(
        accounts: accountRepo,
        categories: categoryRepo,
        transactions: transactionRepo,
      ),
      now: () => DateTime(2026, 10, 15),
    );
  }

  blocTest<RecordBloc, RecordState>(
    'rejects an empty amount, then saves the keypad result',
    build: buildBloc,
    act: (bloc) async {
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
    build: buildBloc,
    act: (bloc) async {
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
    build: buildBloc,
    act: (bloc) async {
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
