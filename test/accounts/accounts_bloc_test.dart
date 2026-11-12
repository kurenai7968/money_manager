import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/models/account_balances.dart';
import 'package:money_manager/models/account_book_model.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_state.dart';
import 'package:money_manager/repositories/account_repository.dart';
import 'package:money_manager/services/account_book_service.dart';

import '../support/memory_account_repository.dart';
import '../support/memory_category_repository.dart';
import '../support/memory_transaction_repository.dart';

void main() {
  late MemoryAccountRepository repository;
  late MemoryTransactionRepository transactions;

  setUp(() {
    repository = MemoryAccountRepository();
    transactions = MemoryTransactionRepository();
  });

  AccountsBloc buildBloc({AccountRepository? accounts}) {
    final accountRepo = accounts ?? repository;
    return AccountsBloc(
      accounts: accountRepo,
      accountBook: AccountBookServiceImpl(
        accounts: accountRepo,
        categories: MemoryCategoryRepository(),
        transactions: transactions,
      ),
    );
  }

  const cash = AccountModel(
    id: 1,
    name: 'Cash',
    type: AccountType.cash,
    icon: 'other',
    sortOrder: 0,
  );

  blocTest<AccountsBloc, AccountsState>(
    'seeds a cash account when the store is empty',
    build: () => buildBloc(),
    act: (bloc) => bloc.add(const AccountsInitialized()),
    verify: (bloc) {
      final account = bloc.state.accounts.single;
      expect(account.type, AccountType.cash);
      expect(account.name, isNull);
      expect(account.languageEn, 'Cash');
      expect(account.languageZh, '現金');
      expect(account.languageZhCn, '现金');
      expect(account.icon, 'other');
      expect(account.isActive, isTrue);
      expect(transactions.transactions, isEmpty);
    },
  );

  blocTest<AccountsBloc, AccountsState>(
    'rejects an empty name',
    build: () => buildBloc(),
    act: (bloc) => bloc.add(
      const AccountSavePressed(
        AccountModel(
          id: 1,
          name: ' ',
          type: AccountType.cash,
          icon: 'other',
          sortOrder: 0,
        ),
      ),
    ),
    expect: () => const [
      AccountsState(
        status: AccountsStatus.failure,
        error: AccountsError.nameRequired,
      ),
    ],
  );

  blocTest<AccountsBloc, AccountsState>(
    'saves an account without creating a transaction',
    build: () => buildBloc(),
    act: (bloc) => bloc.add(const AccountSavePressed(cash)),
    expect: () => [
      isA<AccountsState>()
          .having((state) => state.status, 'status', AccountsStatus.success)
          .having((state) => state.accounts, 'accounts', [cash]),
    ],
    verify: (bloc) {
      expect(bloc.state.netWorth, 0);
      expect(transactions.transactions, isEmpty);
    },
  );

  blocTest<AccountsBloc, AccountsState>(
    'leaves existing transactions unchanged when an account is saved',
    build: () => buildBloc(),
    setUp: () {
      transactions.transactions.add(
        TransactionModel(
          id: 2,
          type: TransactionType.income,
          amount: 15.0,
          date: DateTime(2026, 1, 1),
          note: 'start',
          accountId: cash.id,
          categoryId: 3,
        ),
      );
    },
    act: (bloc) => bloc.add(const AccountSavePressed(cash)),
    verify: (_) {
      final saved = transactions.transactions.single;
      expect(saved.id, 2);
      expect(saved.type, TransactionType.income);
      expect(saved.amount, 15);
      expect(saved.note, 'start');
      expect(saved.categoryId, 3);
    },
  );

  blocTest<AccountsBloc, AccountsState>(
    'does not add a transaction when existing accounts are loaded',
    build: () => buildBloc(),
    setUp: () {
      repository.accounts.add(cash);
    },
    act: (bloc) => bloc.add(const AccountsInitialized()),
    verify: (_) {
      expect(transactions.transactions, isEmpty);
      expect(repository.accounts.single.id, cash.id);
    },
  );

  blocTest<AccountsBloc, AccountsState>(
    'blocks archiving an account that still has a balance',
    build: () => buildBloc(),
    act: (bloc) => bloc.add(const AccountArchivePressed(cash, balance: 15.0)),
    expect: () => const [
      AccountsState(
        status: AccountsStatus.failure,
        error: AccountsError.archiveBlocked,
      ),
    ],
  );

  blocTest<AccountsBloc, AccountsState>(
    'archives an account at zero',
    build: () => buildBloc(),
    setUp: () {
      repository.accounts.add(cash);
    },
    act: (bloc) => bloc.add(const AccountArchivePressed(cash, balance: 0.0)),
    verify: (bloc) {
      expect(bloc.state.active, isEmpty);
      expect(bloc.state.accounts.single.isActive, isFalse);
    },
  );

  blocTest<AccountsBloc, AccountsState>(
    'groups assets and liabilities and counts net worth once',
    build: () => buildBloc(),
    setUp: () {
      repository.accounts.addAll(const [
        cash,
        AccountModel(
          id: 2,
          name: 'Card',
          type: AccountType.credit,
          icon: 'other',
          sortOrder: 1,
        ),
        AccountModel(
          id: 3,
          name: 'Old',
          type: AccountType.bank,
          icon: 'other',
          sortOrder: 2,
          isActive: false,
        ),
      ]);
      repository.balanceById[1] = 80.0;
      repository.balanceById[2] = 30.0;
    },
    act: (bloc) => bloc.add(const AccountsInitialized()),
    verify: (bloc) {
      expect(bloc.state.assets.map((line) => line.account.id), [1]);
      expect(bloc.state.assets.single.balance, 80);
      expect(bloc.state.liabilities.single.account.id, 2);
      expect(bloc.state.liabilities.single.balance, 30);
      expect(bloc.state.netWorth, 50);
    },
  );

  blocTest<AccountsBloc, AccountsState>(
    'emits failure when accounts cannot be read',
    build: () => buildBloc(accounts: _FailingAccounts()),
    act: (bloc) => bloc.add(const AccountsInitialized()),
    expect: () => [
      isA<AccountsState>().having(
        (state) => state.status,
        'status',
        AccountsStatus.loading,
      ),
      isA<AccountsState>().having(
        (state) => state.status,
        'status',
        AccountsStatus.failure,
      ),
    ],
  );

  test('net worth subtracts credit owed', () {
    expect(
      accountBookNetWorth(const [
        AccountBookModel(
          account: AccountModel(
            id: 1,
            name: 'Bank',
            type: AccountType.bank,
            icon: 'other',
            sortOrder: 0,
          ),
          balance: 50.0,
          transactions: [],
        ),
        AccountBookModel(
          account: AccountModel(
            id: 2,
            name: 'Card',
            type: AccountType.credit,
            icon: 'other',
            sortOrder: 1,
          ),
          balance: 12.0,
          transactions: [],
        ),
      ]),
      38,
    );
  });
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
