import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/models/account_balances.dart';
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
    id: 1,
    name: 'Cash',
    type: AccountType.cash,
    icon: 'other',
    sortOrder: 0,
  );

  late AccountRepository accountRepo;
  late MemoryTransactionRepository transactionRepo;
  late MemoryCategoryRepository categoryRepo;

  setUp(() {
    accountRepo = MemoryAccountRepository()
      ..accounts.add(cash)
      ..balanceById[1] = -1200;
    transactionRepo = MemoryTransactionRepository()
      ..transactions.addAll([
        TransactionModel(
          id: 2,
          type: TransactionType.expense,
          amount: 10.0,
          date: DateTime(2026, 10, 2),
          accountId: 1,
          categoryId: 3,
        ),
        TransactionModel(
          id: 4,
          type: TransactionType.transfer,
          amount: 2.0,
          date: DateTime(2026, 10, 3),
          fromAccountId: 1,
          toAccountId: 5,
        ),
        TransactionModel(
          id: 6,
          type: TransactionType.expense,
          amount: 0.5,
          date: DateTime(2026, 10, 4),
          accountId: 5,
          categoryId: 3,
        ),
      ]);
    categoryRepo = MemoryCategoryRepository();
  });

  AccountDetailBloc buildBloc(int accountId) {
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
    build: () => buildBloc(1),
    act: (bloc) => bloc.add(const AccountDetailInitialized()),
    verify: (bloc) {
      expect(bloc.state.history.map((item) => item.id), [2, 4]);
      expect(bloc.state.balance, -1200);
    },
    expect: () => [
      isA<AccountDetailState>().having(
        (state) => state.account?.id,
        'account',
        1,
      ),
    ],
  );

  blocTest<AccountDetailBloc, AccountDetailState>(
    'has no account when the id is missing',
    build: () => buildBloc(7),
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
    build: () => buildBloc(1),
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
  Future<void> archive(int id) async {}

  @override
  Future<List<AccountModel>> getAll() async => throw StateError('unavailable');

  @override
  Future<AccountBalances> balances() async => throw StateError('unavailable');

  @override
  Future<bool> isEmpty() async => throw StateError('unavailable');

  @override
  Future<void> reorder(List<int> ids) async {}

  @override
  Future<int> save(AccountModel account) async => 0;
}
