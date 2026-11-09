import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/analysis/bloc/analysis_event.dart';
import 'package:money_manager/pages/analysis/bloc/analysis_state.dart';
import 'package:money_manager/pages/analysis/models/analysis_rollup.dart';
import 'package:money_manager/services/ledger_service.dart';

class AnalysisBloc extends Bloc<AnalysisEvent, AnalysisState> {
  final LedgerService _ledger;
  final DateTime Function() _now;
  var _failed = false;
  List<AccountModel> _accountRows = const [];
  List<TransactionModel> _transactionRows = const [];
  List<CategoryModel> _categoryRows = const [];

  AnalysisBloc({required LedgerService ledger, DateTime Function()? now})
    : _ledger = ledger,
      _now = now ?? DateTime.now,
      super(_initial(now ?? DateTime.now)) {
    on<AnalysisInitialized>(_onInitialized);
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

  Future<void> _onInitialized(
    AnalysisInitialized event,
    Emitter<AnalysisState> emit,
  ) async {
    await _load();
    _publish(emit, state);
  }

  Future<void> _load() async {
    try {
      final loaded = await _ledger.loadAccounts();
      _accountRows = loaded.accounts;
      _transactionRows = loaded.transactions;
      _categoryRows = await _ledger.loadCategories();
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
