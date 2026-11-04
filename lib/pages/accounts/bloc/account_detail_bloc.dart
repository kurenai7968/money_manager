import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/core/utils/ledger_balance.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/pages/accounts/bloc/account_detail_event.dart';
import 'package:money_manager/pages/accounts/bloc/account_detail_state.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_state.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_state.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_state.dart';

class AccountDetailBloc extends Bloc<AccountDetailEvent, AccountDetailState> {
  AccountDetailBloc({
    required this.accountId,
    required AccountsBloc accounts,
    required TransactionsBloc transactions,
    required CategoriesBloc categories,
  }) : _accounts = accounts,
       _transactions = transactions,
       _categories = categories,
       super(const AccountDetailState()) {
    on<AccountDetailStarted>(_onStarted);
    on<AccountDetailSourcesChanged>(_onSourcesChanged);
  }

  final String accountId;
  final AccountsBloc _accounts;
  final TransactionsBloc _transactions;
  final CategoriesBloc _categories;
  final _subscriptions = <StreamSubscription<dynamic>>[];

  void _listen() {
    if (_subscriptions.isNotEmpty) {
      return;
    }
    _subscriptions.add(
      _accounts.stream.listen((_) => add(const AccountDetailSourcesChanged())),
    );
    _subscriptions.add(
      _transactions.stream.listen(
        (_) => add(const AccountDetailSourcesChanged()),
      ),
    );
    _subscriptions.add(
      _categories.stream.listen(
        (_) => add(const AccountDetailSourcesChanged()),
      ),
    );
  }

  void _onStarted(
    AccountDetailStarted event,
    Emitter<AccountDetailState> emit,
  ) {
    _listen();
    _publish(emit);
  }

  void _onSourcesChanged(
    AccountDetailSourcesChanged event,
    Emitter<AccountDetailState> emit,
  ) {
    _publish(emit);
  }

  void _publish(Emitter<AccountDetailState> emit) {
    final failed =
        _accounts.state.status == AccountsStatus.failure ||
        _transactions.state.status == TransactionsStatus.failure ||
        _categories.state.status == CategoriesStatus.failure;
    AccountModel? account;
    for (final item in _accounts.state.accounts) {
      if (item.id == accountId) {
        account = item;
        break;
      }
    }
    if (account == null) {
      emit(
        AccountDetailState(
          status: failed
              ? AccountDetailStatus.failure
              : AccountDetailStatus.success,
          categories: _categories.state.categories,
          accounts: _accounts.state.accounts,
        ),
      );
      return;
    }
    final history = [
      for (final item in _transactions.state.transactions)
        if (item.accountId == account.id ||
            item.fromAccountId == account.id ||
            item.toAccountId == account.id)
          item,
    ];
    emit(
      AccountDetailState(
        status: failed
            ? AccountDetailStatus.failure
            : AccountDetailStatus.success,
        account: account,
        balanceMinor: balanceOf(account, history),
        history: history,
        categories: _categories.state.categories,
        accounts: _accounts.state.accounts,
      ),
    );
  }

  @override
  Future<void> close() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    return super.close();
  }
}
