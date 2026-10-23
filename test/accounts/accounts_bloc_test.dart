import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_state.dart';

import '../support/memory_account_repository.dart';

void main() {
  late MemoryAccountRepository repository;

  setUp(() {
    repository = MemoryAccountRepository();
  });

  const cash = AccountModel(
    id: 'cash',
    name: 'Cash',
    type: AccountType.cash,
    openingBalanceMinor: 1500,
    sortOrder: 0,
  );

  blocTest<AccountsBloc, AccountsState>(
    'loads an empty list',
    build: () => AccountsBloc(repository),
    act: (bloc) => bloc.add(const AccountsStarted()),
    expect: () => const [
      AccountsState(status: AccountsStatus.loading),
      AccountsState(status: AccountsStatus.success),
    ],
  );

  blocTest<AccountsBloc, AccountsState>(
    'rejects an empty name',
    build: () => AccountsBloc(repository),
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
    build: () => AccountsBloc(repository),
    act: (bloc) => bloc.add(const AccountSavePressed(cash)),
    expect: () => const [
      AccountsState(status: AccountsStatus.success, accounts: [cash]),
    ],
    verify: (bloc) {
      expect(bloc.state.netWorth, 1500);
    },
  );

  blocTest<AccountsBloc, AccountsState>(
    'blocks archiving an account that still has a balance',
    build: () => AccountsBloc(repository),
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
    build: () => AccountsBloc(repository),
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
