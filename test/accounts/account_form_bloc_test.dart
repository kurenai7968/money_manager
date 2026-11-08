import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/accounts/bloc/account_form_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/account_form_event.dart';
import 'package:money_manager/pages/accounts/bloc/account_form_state.dart';

import '../support/memory_account_repository.dart';
import '../support/memory_transaction_repository.dart';

void main() {
  late MemoryAccountRepository accountRepo;
  late MemoryTransactionRepository transactionRepo;

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
  });

  AccountFormBloc buildBloc() {
    return AccountFormBloc(
      accounts: accountRepo,
      transactions: transactionRepo,
    );
  }

  blocTest<AccountFormBloc, AccountFormState>(
    'rejects a blank name and an invalid amount',
    build: buildBloc,
    act: (bloc) async {
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
    build: buildBloc,
    act: (bloc) async {
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
    build: buildBloc,
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
