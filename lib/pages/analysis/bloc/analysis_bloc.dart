import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/core/utils/analysis_rollup.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_state.dart';
import 'package:money_manager/pages/analysis/bloc/analysis_event.dart';
import 'package:money_manager/pages/analysis/bloc/analysis_state.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_state.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_state.dart';

class AnalysisBloc extends Bloc<AnalysisEvent, AnalysisState> {
  AnalysisBloc({
    required TransactionsBloc transactions,
    required CategoriesBloc categories,
    required AccountsBloc accounts,
    DateTime Function()? now,
  }) : _transactions = transactions,
       _categories = categories,
       _accounts = accounts,
       _now = now ?? DateTime.now,
       super(_initial(now ?? DateTime.now)) {
    on<AnalysisStarted>(_onStarted);
    on<AnalysisKindSelected>(_onKindSelected);
    on<AnalysisSourcesChanged>(_onSourcesChanged);
  }

  final TransactionsBloc _transactions;
  final CategoriesBloc _categories;
  final AccountsBloc _accounts;
  final DateTime Function() _now;
  final _subscriptions = <StreamSubscription<dynamic>>[];

  static AnalysisState _initial(DateTime Function() now) {
    final today = now();
    final month = DateTime(today.year, today.month);
    return AnalysisState(
      month: month,
      rollup: analysisRollup(const [], month, CategoryKind.expense),
    );
  }

  void _listen() {
    if (_subscriptions.isNotEmpty) {
      return;
    }
    _subscriptions.add(
      _transactions.stream.listen((_) => add(const AnalysisSourcesChanged())),
    );
    _subscriptions.add(
      _categories.stream.listen((_) => add(const AnalysisSourcesChanged())),
    );
    _subscriptions.add(
      _accounts.stream.listen((_) => add(const AnalysisSourcesChanged())),
    );
  }

  void _onStarted(AnalysisStarted event, Emitter<AnalysisState> emit) {
    _listen();
    _publish(emit, state);
  }

  void _onKindSelected(
    AnalysisKindSelected event,
    Emitter<AnalysisState> emit,
  ) {
    _publish(emit, state.copyWith(kind: event.kind));
  }

  void _onSourcesChanged(
    AnalysisSourcesChanged event,
    Emitter<AnalysisState> emit,
  ) {
    _publish(emit, state);
  }

  void _publish(Emitter<AnalysisState> emit, AnalysisState base) {
    final today = _now();
    final month = DateTime(today.year, today.month);
    final failed =
        _transactions.state.status == TransactionsStatus.failure ||
        _categories.state.status == CategoriesStatus.failure ||
        _accounts.state.status == AccountsStatus.failure;
    emit(
      base.copyWith(
        status: failed ? AnalysisStatus.failure : AnalysisStatus.success,
        month: month,
        rollup: analysisRollup(
          _transactions.state.transactions,
          month,
          base.kind,
        ),
        categories: _categories.state.categories,
        accounts: _accounts.state.active,
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
