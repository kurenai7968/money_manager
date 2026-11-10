import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/accounts/bloc/account_detail_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/account_detail_event.dart';
import 'package:money_manager/pages/accounts/bloc/account_detail_state.dart';
import 'package:money_manager/repositories/account_repository.dart';
import 'package:money_manager/services/account_book_service.dart';

import '../support/memory_account_repository.dart';
import '../support/memory_category_repository.dart';
import '../support/memory_transaction_repository.dart';

void main() {
  const cash = AccountModel(
    id: 'cash',
    name: 'Cash',
    type: AccountType.cash,
    openingBalanceMinor: 0,
    sortOrder: 0,
  );

  late AccountRepository accountRepo;
  late MemoryTransactionRepository transactionRepo;
  late MemoryCategoryRepository categoryRepo;

  setUp(() {
    accountRepo = MemoryAccountRepository()
      ..accounts.add(cash)
      ..balanceById['cash'] = -1200;
    transactionRepo = MemoryTransactionRepository()
      ..transactions.addAll([
        TransactionModel(
          id: 'lunch',
          type: TransactionType.expense,
          amountMinor: 1000,
          date: DateTime(2026, 10, 2),
          accountId: 'cash',
          categoryId: 'food',
        ),
        TransactionModel(
          id: 'move',
          type: TransactionType.transfer,
          amountMinor: 200,
          date: DateTime(2026, 10, 3),
          fromAccountId: 'cash',
          toAccountId: 'bank',
        ),
        TransactionModel(
          id: 'other',
          type: TransactionType.expense,
          amountMinor: 50,
          date: DateTime(2026, 10, 4),
          accountId: 'bank',
          categoryId: 'food',
        ),
      ]);
    categoryRepo = MemoryCategoryRepository();
  });

  AccountDetailBloc buildBloc(String accountId) {
    return AccountDetailBloc(
      accountId: accountId,
      accountBook: AccountBookServiceImpl(
        accounts: accountRepo,
        categories: categoryRepo,
        transactions: transactionRepo,
      ),
    );
  }

  blocTest<AccountDetailBloc, AccountDetailState>(
    'shows the account history and one balance',
    build: () => buildBloc('cash'),
    act: (bloc) => bloc.add(const AccountDetailInitialized()),
    verify: (bloc) {
      expect(bloc.state.history.map((item) => item.id), ['lunch', 'move']);
      expect(bloc.state.balanceMinor, -1200);
    },
    expect: () => [
      isA<AccountDetailState>().having(
        (state) => state.account?.id,
        'account',
        'cash',
      ),
    ],
  );

  blocTest<AccountDetailBloc, AccountDetailState>(
    'has no account when the id is missing',
    build: () => buildBloc('missing'),
    act: (bloc) => bloc.add(const AccountDetailInitialized()),
    expect: () => [
      isA<AccountDetailState>()
          .having((state) => state.account, 'account', isNull)
          .having((state) => state.history, 'history', isEmpty),
    ],
  );

  blocTest<AccountDetailBloc, AccountDetailState>(
    'emits failure when accounts cannot be read',
    setUp: () {
      accountRepo = _FailingAccounts();
    },
    build: () => buildBloc('cash'),
    act: (bloc) => bloc.add(const AccountDetailInitialized()),
    expect: () => [
      isA<AccountDetailState>()
          .having(
            (state) => state.status,
            'status',
            AccountDetailStatus.failure,
          )
          .having((state) => state.account, 'account', isNull),
    ],
  );
}

class _FailingAccounts implements AccountRepository {
  @override
  Future<void> archive(String id) async {}

  @override
  Future<List<AccountModel>> getAll() async => throw StateError('unavailable');

  @override
  Future<AccountBalances> balances() async => throw StateError('unavailable');

  @override
  Future<bool> isEmpty() async => throw StateError('unavailable');

  @override
  Future<void> reorder(List<String> ids) async {}

  @override
  Future<void> save(AccountModel account) async {}
}
