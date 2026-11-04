import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/accounts/bloc/account_form_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/account_form_event.dart';
import 'package:money_manager/pages/accounts/bloc/account_form_state.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_state.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_event.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_state.dart';

import '../support/memory_account_repository.dart';
import '../support/memory_transaction_repository.dart';

void main() {
  late MemoryAccountRepository accountRepo;
  late MemoryTransactionRepository transactionRepo;
  late AccountsBloc accounts;
  late TransactionsBloc transactions;

  setUp(() {
    accountRepo = MemoryAccountRepository()
      ..accounts.add(
        const AccountModel(
          id: 'cash',
          name: 'Cash',
          type: AccountType.cash,
          openingBalanceMinor: 0,
          sortOrder: 4,
        ),
      );
    transactionRepo = MemoryTransactionRepository();
    accounts = AccountsBloc(accountRepo, transactionRepo);
    transactions = TransactionsBloc(transactionRepo, accountRepo);
  });

  tearDown(() async {
    await accounts.close();
    await transactions.close();
  });

  blocTest<AccountFormBloc, AccountFormState>(
    'rejects a blank name and an invalid amount',
    build: () =>
        AccountFormBloc(accounts: accounts, transactions: transactions),
    act: (bloc) async {
      await _load(accounts, transactions);
      bloc.add(const AccountFormStarted(languageCode: 'en', locale: 'en'));
      if (!bloc.state.prepared) {
        await bloc.stream.firstWhere((state) => state.prepared);
      }
      bloc.add(
        const AccountFormSavePressed(
          name: '  ',
          balanceText: '1',
          languageCode: 'en',
        ),
      );
      bloc.add(
        const AccountFormSavePressed(
          name: 'Wallet',
          balanceText: 'nope',
          languageCode: 'en',
        ),
      );
    },
    expect: () => [
      isA<AccountFormState>()
          .having((state) => state.prepared, 'prepared', isTrue)
          .having((state) => state.sortOrder, 'sort', 5),
      isA<AccountFormState>().having(
        (state) => state.error,
        'error',
        AccountFormError.nameRequired,
      ),
      isA<AccountFormState>().having(
        (state) => state.error,
        'error',
        AccountFormError.amountInvalid,
      ),
    ],
    verify: (_) {
      expect(accountRepo.accounts, hasLength(1));
    },
  );

  blocTest<AccountFormBloc, AccountFormState>(
    'saves a new account from the form fields',
    build: () =>
        AccountFormBloc(accounts: accounts, transactions: transactions),
    act: (bloc) async {
      await _load(accounts, transactions);
      bloc.add(const AccountFormStarted(languageCode: 'en', locale: 'en'));
      if (!bloc.state.prepared) {
        await bloc.stream.firstWhere((state) => state.prepared);
      }
      bloc.add(
        const AccountFormSavePressed(
          name: 'Wallet',
          balanceText: '10',
          languageCode: 'en',
        ),
      );
      if (!bloc.state.saved) {
        await bloc.stream.firstWhere((state) => state.saved);
      }
    },
    verify: (bloc) {
      final saved = accountRepo.accounts.singleWhere(
        (account) => account.name == 'Wallet',
      );
      expect(saved.openingBalanceMinor, 1000);
      expect(saved.type, AccountType.cash);
      expect(bloc.state.saved, isTrue);
    },
    expect: () => [
      isA<AccountFormState>().having(
        (state) => state.prepared,
        'prepared',
        isTrue,
      ),
      isA<AccountFormState>().having((state) => state.saved, 'saved', isTrue),
    ],
  );

  blocTest<AccountFormBloc, AccountFormState>(
    'blocks archive when the balance is not zero',
    build: () =>
        AccountFormBloc(accounts: accounts, transactions: transactions),
    act: (bloc) async {
      transactionRepo.transactions.add(
        TransactionModel(
          id: 'lunch',
          type: TransactionType.expense,
          amountMinor: 100,
          date: DateTime(2026, 10, 1),
          accountId: 'cash',
          categoryId: 'food',
        ),
      );
      await _load(accounts, transactions);
      bloc.add(
        const AccountFormStarted(
          accountId: 'cash',
          languageCode: 'en',
          locale: 'en',
        ),
      );
      if (!bloc.state.prepared) {
        await bloc.stream.firstWhere((state) => state.prepared);
      }
      bloc.add(const AccountFormArchivePressed());
      if (bloc.state.error != AccountFormError.archiveBlocked) {
        await bloc.stream.firstWhere(
          (state) => state.error == AccountFormError.archiveBlocked,
        );
      }
    },
    expect: () => [
      isA<AccountFormState>().having(
        (state) => state.editing,
        'editing',
        isTrue,
      ),
      isA<AccountFormState>().having(
        (state) => state.error,
        'error',
        AccountFormError.archiveBlocked,
      ),
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
