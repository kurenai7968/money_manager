import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/core/utils/ledger_balance.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/accounts/bloc/account_detail_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/account_detail_event.dart';
import 'package:money_manager/pages/accounts/bloc/account_detail_state.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_state.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_event.dart';
import 'package:money_manager/pages/categories/bloc/categories_state.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_event.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_state.dart';
import 'package:money_manager/repositories/account_repository.dart';

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

  late AccountsBloc accounts;
  late TransactionsBloc transactions;
  late CategoriesBloc categories;

  setUp(() {
    final accountRepo = MemoryAccountRepository()..accounts.add(cash);
    final transactionRepo = MemoryTransactionRepository()
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
    accounts = AccountsBloc(accountRepo, transactionRepo);
    transactions = TransactionsBloc(transactionRepo, accountRepo);
    categories = CategoriesBloc(MemoryCategoryRepository());
  });

  tearDown(() async {
    await accounts.close();
    await transactions.close();
    await categories.close();
  });

  blocTest<AccountDetailBloc, AccountDetailState>(
    'shows the account history and one balance',
    build: () => AccountDetailBloc(
      accountId: 'cash',
      accounts: accounts,
      transactions: transactions,
      categories: categories,
    ),
    act: (bloc) async {
      await _load(accounts, transactions, categories);
      bloc.add(const AccountDetailStarted());
    },
    verify: (bloc) {
      expect(bloc.state.history.map((item) => item.id), ['lunch', 'move']);
      expect(bloc.state.balanceMinor, balanceOf(cash, bloc.state.history));
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
    build: () => AccountDetailBloc(
      accountId: 'missing',
      accounts: accounts,
      transactions: transactions,
      categories: categories,
    ),
    act: (bloc) async {
      await _load(accounts, transactions, categories);
      bloc.add(const AccountDetailStarted());
    },
    expect: () => [
      isA<AccountDetailState>()
          .having((state) => state.account, 'account', isNull)
          .having((state) => state.history, 'history', isEmpty),
    ],
  );

  blocTest<AccountDetailBloc, AccountDetailState>(
    'emits failure when accounts cannot be read',
    setUp: () async {
      await accounts.close();
      accounts = AccountsBloc(
        _FailingAccounts(),
        MemoryTransactionRepository(),
      );
    },
    build: () => AccountDetailBloc(
      accountId: 'cash',
      accounts: accounts,
      transactions: transactions,
      categories: categories,
    ),
    act: (bloc) async {
      await _load(accounts, transactions, categories);
      bloc.add(const AccountDetailStarted());
    },
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

Future<void> _load(
  AccountsBloc accounts,
  TransactionsBloc transactions,
  CategoriesBloc categories,
) async {
  accounts.add(const AccountsStarted());
  transactions.add(const TransactionsStarted());
  categories.add(const CategoriesStarted([]));
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
  await _until(
    categories,
    (state) =>
        state.status == CategoriesStatus.success ||
        state.status == CategoriesStatus.failure,
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
