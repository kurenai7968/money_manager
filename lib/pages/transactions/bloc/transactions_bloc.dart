import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_event.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_state.dart';
import 'package:money_manager/repositories/transaction_repository.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  TransactionsBloc(this._repository) : super(const TransactionsState()) {
    on<TransactionsStarted>(_onStarted);
    on<TransactionSavePressed>(_onSave);
    on<TransactionDeletePressed>(_onDelete);
  }

  final TransactionRepository _repository;

  Future<void> _onStarted(
    TransactionsStarted event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: TransactionsStatus.loading,
        error: TransactionsError.none,
      ),
    );
    try {
      emit(
        state.copyWith(
          status: TransactionsStatus.success,
          transactions: await _repository.getAll(),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: TransactionsStatus.failure,
          error: TransactionsError.saveFailed,
        ),
      );
    }
  }

  Future<void> _onSave(
    TransactionSavePressed event,
    Emitter<TransactionsState> emit,
  ) async {
    final transaction = event.transaction;
    final invalidAmount = transaction.amountMinor <= 0;
    final invalidExpense =
        transaction.type != TransactionType.transfer &&
        (transaction.accountId == null || transaction.categoryId == null);
    final invalidTransfer =
        transaction.type == TransactionType.transfer &&
        (transaction.fromAccountId == null ||
            transaction.toAccountId == null ||
            transaction.fromAccountId == transaction.toAccountId);
    if (invalidAmount || invalidExpense || invalidTransfer) {
      emit(
        state.copyWith(
          status: TransactionsStatus.failure,
          error: TransactionsError.invalid,
        ),
      );
      return;
    }
    try {
      await _repository.save(transaction);
      emit(
        state.copyWith(
          status: TransactionsStatus.success,
          transactions: await _repository.getAll(),
          error: TransactionsError.none,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: TransactionsStatus.failure,
          error: TransactionsError.saveFailed,
        ),
      );
    }
  }

  Future<void> _onDelete(
    TransactionDeletePressed event,
    Emitter<TransactionsState> emit,
  ) async {
    try {
      await _repository.delete(event.id);
      emit(
        state.copyWith(
          status: TransactionsStatus.success,
          transactions: await _repository.getAll(),
          error: TransactionsError.none,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: TransactionsStatus.failure,
          error: TransactionsError.saveFailed,
        ),
      );
    }
  }
}
