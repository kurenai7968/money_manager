import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/core/utils/ledger_balance.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_list_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_list_event.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_list_state.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_state.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_event.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_state.dart';
import 'package:money_manager/repositories/account_repository.dart';

import '../support/memory_account_repository.dart';
import '../support/memory_transaction_repository.dart';

void main() {
  late MemoryAccountRepository accountRepo;
  late MemoryTransactionRepository transactionRepo;
  late AccountsBloc accounts;
  late TransactionsBloc transactions;

  setUp(() {
    accountRepo = MemoryAccountRepository()
      ..accounts.addAll([
        const AccountModel(
          id: 'cash',
          name: 'Cash',
          type: AccountType.cash,
          openingBalanceMinor: 10000,
          sortOrder: 0,
        ),
        const AccountModel(
          id: 'card',
          name: 'Card',
          type: AccountType.credit,
          openingBalanceMinor: 3000,
          sortOrder: 1,
        ),
        const AccountModel(
          id: 'old',
          name: 'Old',
          type: AccountType.bank,
          openingBalanceMinor: 0,
          sortOrder: 2,
          archived: true,
        ),
      ]);
    transactionRepo = MemoryTransactionRepository()
      ..transactions.add(
        TransactionModel(
          id: 'lunch',
          type: TransactionType.expense,
          amountMinor: 2000,
          date: DateTime(2026, 10, 1),
          accountId: 'cash',
          categoryId: 'food',
        ),
      );
    accounts = AccountsBloc(accountRepo, transactionRepo);
    transactions = TransactionsBloc(transactionRepo, accountRepo);
  });

  tearDown(() async {
    await accounts.close();
    await transactions.close();
  });

  blocTest<AccountsListBloc, AccountsListState>(
    'groups assets and liabilities and counts net worth once',
    build: () =>
        AccountsListBloc(accounts: accounts, transactions: transactions),
    act: (bloc) async {
      await _load(accounts, transactions);
      bloc.add(const AccountsListStarted());
    },
    verify: (bloc) {
      expect(bloc.state.assets.map((line) => line.account.id), ['cash']);
      expect(bloc.state.assets.single.balanceMinor, 8000);
      expect(bloc.state.liabilities.single.account.id, 'card');
      expect(
        bloc.state.netWorth,
        netWorthOf(
          accountRepo.accounts.where((item) => !item.archived),
          transactionRepo.transactions,
        ),
      );
    },
    expect: () => [isA<AccountsListState>()],
  );

  blocTest<AccountsListBloc, AccountsListState>(
    'emits failure when accounts cannot be read',
    setUp: () async {
      await accounts.close();
      accounts = AccountsBloc(_FailingAccounts(), transactionRepo);
    },
    build: () =>
        AccountsListBloc(accounts: accounts, transactions: transactions),
    act: (bloc) async {
      await _load(accounts, transactions);
      bloc.add(const AccountsListStarted());
    },
    expect: () => [
      isA<AccountsListState>().having(
        (state) => state.status,
        'status',
        AccountsListStatus.failure,
      ),
    ],
  );

  blocTest<AccountsListBloc, AccountsListState>(
    'stays empty before any account exists',
    build: () =>
        AccountsListBloc(accounts: accounts, transactions: transactions),
    act: (bloc) => bloc.add(const AccountsListStarted()),
    expect: () => [
      isA<AccountsListState>()
          .having((state) => state.assets, 'assets', isEmpty)
          .having((state) => state.liabilities, 'liabilities', isEmpty)
          .having((state) => state.netWorth, 'worth', 0),
    ],
  );
}

Future<void> _load(AccountsBloc accounts, TransactionsBloc transactions) async {
  accounts.add(const AccountsStarted());
  transactions.add(const TransactionsStarted());
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
}

Future<void> _until<S>(BlocBase<S> bloc, bool Function(S state) done) async {
  if (done(bloc.state)) {
    return;
  }
  await bloc.stream.firstWhere(done);
}

class _FailingAccounts implements AccountRepository {
  @override
  Future<void> archive(String id) async {}

  @override
  Future<List<AccountModel>> getAll() async => throw StateError('unavailable');

  @override
  Future<bool> isEmpty() async => throw StateError('unavailable');

  @override
  Future<void> reorder(List<String> ids) async {}

  @override
  Future<void> save(AccountModel account) async {}
}
