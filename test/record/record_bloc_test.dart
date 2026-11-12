import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/pages/record/models/amount_expression.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/record/bloc/record_bloc.dart';
import 'package:money_manager/pages/record/bloc/record_event.dart';
import 'package:money_manager/pages/record/bloc/record_state.dart';
import 'package:money_manager/services/account_book_service.dart';

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
          id: 1,
          name: 'Cash',
          type: AccountType.cash,
          icon: 'other',
          sortOrder: 0,
        ),
      );
    transactionRepo = MemoryTransactionRepository()
      ..transactions.add(
        TransactionModel(
          id: 2,
          type: TransactionType.expense,
          amount: 7.0,
          date: DateTime(2026, 10, 2),
          note: 'Lunch',
          accountId: 1,
          categoryId: 3,
        ),
      );
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
          id: 4,
          name: 'Salary',
          icon: 'payments',
          type: CategoryKind.income,
          sortOrder: 0,
        ),
      ]);
  });

  RecordBloc buildBloc() {
    return RecordBloc(
      accountBook: AccountBookServiceImpl(
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
      bloc.add(const RecordInitialized());
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
        transactionRepo.transactions.where((item) => item.amount == 5.0),
        hasLength(1),
      );
    },
    expect: () => [
      isA<RecordState>()
          .having((state) => state.accountId, 'account', 1)
          .having((state) => state.categoryId, 'category', 3),
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
      bloc.add(const RecordInitialized(initialType: TransactionType.transfer));
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
      bloc.add(const RecordInitialized(transactionId: 2));
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
