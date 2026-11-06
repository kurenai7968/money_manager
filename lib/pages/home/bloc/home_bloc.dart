import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/core/utils/ledger_balance.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_state.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_state.dart';
import 'package:money_manager/pages/home/bloc/home_event.dart';
import 'package:money_manager/pages/home/bloc/home_state.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final TransactionsBloc _transactions;
  final CategoriesBloc _categories;
  final AccountsBloc _accounts;
  final DateTime Function() _now;
  final _subscriptions = <StreamSubscription<dynamic>>[];

  HomeBloc({
    required TransactionsBloc transactions,
    required CategoriesBloc categories,
    required AccountsBloc accounts,
    DateTime Function()? now,
  }) : _transactions = transactions,
       _categories = categories,
       _accounts = accounts,
       _now = now ?? DateTime.now,
       super(_initial(now ?? DateTime.now)) {
    on<HomeStarted>(_onStarted);
    on<HomeMonthShifted>(_onMonthShifted);
    on<HomeViewToggled>(_onViewToggled);
    on<HomeDaySelected>(_onDaySelected);
    on<HomeSourcesChanged>(_onSourcesChanged);
  }

  static HomeState _initial(DateTime Function() now) {
    final today = now();
    return HomeState(
      month: DateTime(today.year, today.month),
      selectedDay: DateTime(today.year, today.month, today.day),
    );
  }

  void _listen() {
    if (_subscriptions.isNotEmpty) {
      return;
    }
    _subscriptions.add(
      _transactions.stream.listen((_) => add(const HomeSourcesChanged())),
    );
    _subscriptions.add(
      _categories.stream.listen((_) => add(const HomeSourcesChanged())),
    );
    _subscriptions.add(
      _accounts.stream.listen((_) => add(const HomeSourcesChanged())),
    );
  }

  void _onStarted(HomeStarted event, Emitter<HomeState> emit) {
    _listen();
    _publish(emit, state);
  }

  void _onMonthShifted(HomeMonthShifted event, Emitter<HomeState> emit) {
    final month = DateTime(state.month.year, state.month.month + event.delta);
    final today = _now();
    final selected = today.year == month.year && today.month == month.month
        ? DateTime(today.year, today.month, today.day)
        : null;
    _publish(
      emit,
      state.copyWith(
        month: month,
        selectedDay: selected,
        clearSelectedDay: selected == null,
      ),
    );
  }

  void _onViewToggled(HomeViewToggled event, Emitter<HomeState> emit) {
    emit(
      state.copyWith(
        view: state.view == HomeView.summary
            ? HomeView.calendar
            : HomeView.summary,
      ),
    );
  }

  void _onDaySelected(HomeDaySelected event, Emitter<HomeState> emit) {
    final day = DateTime(event.day.year, event.day.month, event.day.day);
    _publish(emit, state.copyWith(selectedDay: day));
  }

  void _onSourcesChanged(HomeSourcesChanged event, Emitter<HomeState> emit) {
    _publish(emit, state);
  }

  void _publish(Emitter<HomeState> emit, HomeState base) {
    final month = base.month;
    final transactions = [
      for (final item in _transactions.state.transactions)
        if (item.date.year == month.year && item.date.month == month.month)
          item,
    ];
    final days = daysOf(transactions);
    final failed =
        _transactions.state.status == TransactionsStatus.failure ||
        _categories.state.status == CategoriesStatus.failure ||
        _accounts.state.status == AccountsStatus.failure;
    emit(
      base.copyWith(
        status: failed ? HomeStatus.failure : HomeStatus.success,
        transactions: transactions,
        figures: monthFigures(transactions, month),
        days: days,
        selectedTransactions: transactionsOn(days, base.selectedDay),
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
