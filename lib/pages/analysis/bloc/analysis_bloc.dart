import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/core/utils/analysis_rollup.dart';
import 'package:money_manager/core/utils/ledger_commands.dart';
import 'package:money_manager/core/utils/queued_bloc.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/analysis/bloc/analysis_event.dart';
import 'package:money_manager/pages/analysis/bloc/analysis_state.dart';
import 'package:money_manager/repositories/account_repository.dart';
import 'package:money_manager/repositories/category_repository.dart';
import 'package:money_manager/repositories/transaction_repository.dart';

class AnalysisBloc extends Bloc<AnalysisEvent, AnalysisState>
    with QueuedBloc<AnalysisEvent, AnalysisState> {
  final AccountRepository _accounts;
  final TransactionRepository _transactions;
  final CategoryRepository _categories;
  final DateTime Function() _now;
  var _failed = false;
  List<AccountModel> _accountRows = const [];
  List<TransactionModel> _transactionRows = const [];
  List<CategoryModel> _categoryRows = const [];

  AnalysisBloc({
    required this._accounts,
    required this._transactions,
    required this._categories,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now,
       super(_initial(now ?? DateTime.now)) {
    on<AnalysisStarted>(_onStarted);
    on<AnalysisKindSelected>(_onKindSelected);
  }

  static AnalysisState _initial(DateTime Function() now) {
    final today = now();
    final month = DateTime(today.year, today.month);
    return AnalysisState(
      month: month,
      rollup: analysisRollup(const [], month, CategoryKind.expense),
    );
  }

  Future<void> _onStarted(
    AnalysisStarted event,
    Emitter<AnalysisState> emit,
  ) async {
    await _load();
    _publish(emit, state);
  }

  Future<void> _load() async {
    try {
      final loaded = await loadAccounts(_accounts, _transactions);
      _accountRows = loaded.accounts;
      _transactionRows = loaded.transactions;
      _categoryRows = await loadCategories(_categories);
      _failed = false;
    } catch (_) {
      _failed = true;
    }
  }

  void _onKindSelected(
    AnalysisKindSelected event,
    Emitter<AnalysisState> emit,
  ) {
    _publish(emit, state.copyWith(kind: event.kind));
  }

  void _publish(Emitter<AnalysisState> emit, AnalysisState base) {
    final today = _now();
    final month = DateTime(today.year, today.month);
    emit(
      base.copyWith(
        status: _failed ? AnalysisStatus.failure : AnalysisStatus.success,
        month: month,
        rollup: analysisRollup(_transactionRows, month, base.kind),
        categories: _categoryRows,
        accounts: [
          for (final account in _accountRows)
            if (!account.archived) account,
        ],
      ),
    );
  }
}
