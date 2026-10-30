import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_state.dart';

import '../support/memory_account_repository.dart';
import '../support/memory_transaction_repository.dart';

void main() {
  late MemoryAccountRepository repository;
  late MemoryTransactionRepository transactions;

  setUp(() {
    repository = MemoryAccountRepository();
    transactions = MemoryTransactionRepository();
  });

  const cash = AccountModel(
    id: 'cash',
    name: 'Cash',
    type: AccountType.cash,
    openingBalanceMinor: 1500,
    sortOrder: 0,
  );

  blocTest<AccountsBloc, AccountsState>(
    'seeds a cash account when the store is empty',
    build: () => AccountsBloc(repository, transactions),
    act: (bloc) => bloc.add(const AccountsStarted()),
    verify: (bloc) {
      final account = bloc.state.accounts.single;
      expect(account.type, AccountType.cash);
      expect(account.name, isNull);
      expect(account.languageEn, 'Cash');
      expect(account.languageZh, '現金');
      expect(account.languageZhCn, '现金');
      expect(account.openingBalanceMinor, 0);
      expect(transactions.transactions, isEmpty);
    },
  );

  blocTest<AccountsBloc, AccountsState>(
    'rejects an empty name',
    build: () => AccountsBloc(repository, transactions),
    act: (bloc) => bloc.add(
      const AccountSavePressed(
        AccountModel(
          id: 'cash',
          name: ' ',
          type: AccountType.cash,
          openingBalanceMinor: 0,
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
    'saves an account',
    build: () => AccountsBloc(repository, transactions),
    act: (bloc) => bloc.add(const AccountSavePressed(cash)),
    expect: () => const [
      AccountsState(status: AccountsStatus.success, accounts: [cash]),
    ],
    verify: (bloc) {
      expect(bloc.state.netWorth, 1500);
      final opening = transactions.transactions.single;
      expect(opening.type, TransactionType.opening);
      expect(opening.accountId, cash.id);
      expect(opening.amountMinor, 1500);
      expect(opening.categoryId, isNull);
      expect(opening.fromAccountId, isNull);
      expect(opening.toAccountId, isNull);
    },
  );

  blocTest<AccountsBloc, AccountsState>(
    'updates the opening transaction to the saved balance',
    build: () => AccountsBloc(repository, transactions),
    setUp: () {
      transactions.transactions.add(
        TransactionModel(
          id: 'opening-cash',
          type: TransactionType.opening,
          amountMinor: 100,
          date: DateTime(2026, 1, 1),
          accountId: cash.id,
        ),
      );
    },
    act: (bloc) => bloc.add(const AccountSavePressed(cash)),
    verify: (bloc) {
      final opening = transactions.transactions.single;
      expect(opening.amountMinor, 1500);
      expect(opening.date, DateTime(2026, 1, 1));
      expect(bloc.state.accounts.single.openingBalanceMinor, 1500);
    },
  );

  blocTest<AccountsBloc, AccountsState>(
    'removes the opening transaction when the balance is zero',
    build: () => AccountsBloc(repository, transactions),
    setUp: () {
      transactions.transactions.add(
        TransactionModel(
          id: 'opening-cash',
          type: TransactionType.opening,
          amountMinor: 1500,
          date: DateTime(2026, 1, 1),
          accountId: cash.id,
        ),
      );
    },
    act: (bloc) =>
        bloc.add(AccountSavePressed(cash.copyWith(openingBalanceMinor: 0))),
    verify: (bloc) {
      expect(transactions.transactions, isEmpty);
      expect(bloc.state.accounts.single.openingBalanceMinor, 0);
    },
  );

  blocTest<AccountsBloc, AccountsState>(
    'adds an opening transaction for an existing balance',
    build: () => AccountsBloc(repository, transactions),
    setUp: () {
      repository.accounts.add(cash);
    },
    act: (bloc) => bloc.add(const AccountsStarted()),
    verify: (bloc) {
      expect(bloc.state.accounts.single.openingBalanceMinor, 1500);
      final opening = transactions.transactions.single;
      expect(opening.id, 'opening-cash');
      expect(opening.amountMinor, 1500);
      expect(opening.accountId, cash.id);
    },
  );

  blocTest<AccountsBloc, AccountsState>(
    'blocks archiving an account that still has a balance',
    build: () => AccountsBloc(repository, transactions),
    act: (bloc) =>
        bloc.add(const AccountArchivePressed(cash, balanceMinor: 1500)),
    expect: () => const [
      AccountsState(
        status: AccountsStatus.failure,
        error: AccountsError.archiveBlocked,
      ),
    ],
  );

  blocTest<AccountsBloc, AccountsState>(
    'archives an account at zero',
    build: () => AccountsBloc(repository, transactions),
    setUp: () {
      repository.accounts.add(cash.copyWith(openingBalanceMinor: 0));
    },
    act: (bloc) => bloc.add(
      AccountArchivePressed(
        cash.copyWith(openingBalanceMinor: 0),
        balanceMinor: 0,
      ),
    ),
    verify: (bloc) {
      expect(bloc.state.active, isEmpty);
      expect(bloc.state.accounts.single.archived, isTrue);
    },
  );

  test('net worth subtracts credit owed', () {
    expect(
      netWorthMinor(const [
        AccountModel(
          id: 'bank',
          name: 'Bank',
          type: AccountType.bank,
          openingBalanceMinor: 5000,
          sortOrder: 0,
        ),
        AccountModel(
          id: 'card',
          name: 'Card',
          type: AccountType.credit,
          openingBalanceMinor: 1200,
          sortOrder: 1,
        ),
      ]),
      3800,
    );
  });
}
