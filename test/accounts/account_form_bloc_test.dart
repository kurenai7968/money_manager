import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/pages/accounts/bloc/account_form_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/account_form_event.dart';
import 'package:money_manager/pages/accounts/bloc/account_form_state.dart';
import 'package:money_manager/services/account_book_service.dart';

import '../support/memory_account_repository.dart';
import '../support/memory_category_repository.dart';
import '../support/memory_transaction_repository.dart';

void main() {
  late MemoryAccountRepository accountRepo;
  late MemoryTransactionRepository transactionRepo;

  setUp(() {
    accountRepo = MemoryAccountRepository()
      ..accounts.add(
        const AccountModel(
          id: 1,
          name: 'Cash',
          type: AccountType.cash,
          icon: 'other',
          sortOrder: 4,
        ),
      );
    transactionRepo = MemoryTransactionRepository();
  });

  AccountFormBloc buildBloc() {
    return AccountFormBloc(
      accounts: accountRepo,
      accountBook: AccountBookServiceImpl(
        accounts: accountRepo,
        categories: MemoryCategoryRepository(),
        transactions: transactionRepo,
      ),
    );
  }

  blocTest<AccountFormBloc, AccountFormState>(
    'rejects a blank name',
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const AccountFormInitialized(languageCode: 'en', locale: 'en'));
      if (!bloc.state.prepared) {
        await bloc.stream.firstWhere((state) => state.prepared);
      }
      bloc.add(const AccountFormSavePressed(name: '  ', languageCode: 'en'));
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
    ],
    verify: (_) {
      expect(accountRepo.accounts, hasLength(1));
      expect(transactionRepo.transactions, isEmpty);
    },
  );

  blocTest<AccountFormBloc, AccountFormState>(
    'saves a new account from the form fields',
    build: buildBloc,
    act: (bloc) async {
      bloc.add(const AccountFormInitialized(languageCode: 'en', locale: 'en'));
      if (!bloc.state.prepared) {
        await bloc.stream.firstWhere((state) => state.prepared);
      }
      bloc.add(const AccountFormSavePressed(name: 'Wallet', languageCode: 'en'));
      if (!bloc.state.saved) {
        await bloc.stream.firstWhere((state) => state.saved);
      }
    },
    verify: (bloc) {
      final saved = accountRepo.accounts.singleWhere(
        (account) => account.name == 'Wallet',
      );
      expect(saved.type, AccountType.cash);
      expect(saved.icon, 'other');
      expect(saved.isActive, isTrue);
      expect(transactionRepo.transactions, isEmpty);
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
      accountRepo.balanceById[1] = -100.0;
      bloc.add(
        const AccountFormInitialized(
          accountId: 1,
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
