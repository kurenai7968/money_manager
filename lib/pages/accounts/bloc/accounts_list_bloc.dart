import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/core/utils/ledger_balance.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_list_event.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_list_state.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_state.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_state.dart';

class AccountsListBloc extends Bloc<AccountsListEvent, AccountsListState> {
  final AccountsBloc _accounts;
  final TransactionsBloc _transactions;
  final _subscriptions = <StreamSubscription<dynamic>>[];

  AccountsListBloc({
    required AccountsBloc accounts,
    required TransactionsBloc transactions,
  }) : _accounts = accounts,
       _transactions = transactions,
       super(const AccountsListState()) {
    on<AccountsListStarted>(_onStarted);
    on<AccountsListSourcesChanged>(_onSourcesChanged);
  }

  void _listen() {
    if (_subscriptions.isNotEmpty) {
      return;
    }
    _subscriptions.add(
      _accounts.stream.listen((_) => add(const AccountsListSourcesChanged())),
    );
    _subscriptions.add(
      _transactions.stream.listen(
        (_) => add(const AccountsListSourcesChanged()),
      ),
    );
  }

  void _onStarted(AccountsListStarted event, Emitter<AccountsListState> emit) {
    _listen();
    _publish(emit);
  }

  void _onSourcesChanged(
    AccountsListSourcesChanged event,
    Emitter<AccountsListState> emit,
  ) {
    _publish(emit);
  }

  void _publish(Emitter<AccountsListState> emit) {
    final active = _accounts.state.active;
    final transactions = _transactions.state.transactions;
    final balances = balancesOf(active, transactions);
    final assets = <AccountLine>[];
    final liabilities = <AccountLine>[];
    for (final account in active) {
      final line = AccountLine(
        account: account,
        balanceMinor: balances[account.id] ?? account.openingBalanceMinor,
      );
      if (account.type == AccountType.credit) {
        liabilities.add(line);
      } else {
        assets.add(line);
      }
    }
    final failed =
        _accounts.state.status == AccountsStatus.failure ||
        _transactions.state.status == TransactionsStatus.failure;
    emit(
      AccountsListState(
        status: failed
            ? AccountsListStatus.failure
            : AccountsListStatus.success,
        assets: assets,
        liabilities: liabilities,
        netWorth: netWorthOf(active, transactions),
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
