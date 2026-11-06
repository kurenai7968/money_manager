import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/core/utils/id.dart';
import 'package:money_manager/core/utils/opening_transaction.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_event.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_state.dart';
import 'package:money_manager/repositories/account_repository.dart';
import 'package:money_manager/repositories/transaction_repository.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final TransactionRepository _repository;
  final AccountRepository _accounts;

  TransactionsBloc(this._repository, this._accounts)
    : super(const TransactionsState()) {
    on<TransactionsStarted>(_onStarted);
    on<TransactionSavePressed>(_onSave);
    on<TransactionDeletePressed>(_onDelete);
  }

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
      await _saveTransaction(transaction);
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
      final openingAccountId = accountIdFromOpeningTransaction(event.id);
      if (openingAccountId != null) {
        await _writeOpeningBalance(openingAccountId, 0);
      }
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

  Future<void> _saveTransaction(TransactionModel transaction) async {
    final openingAccountId = accountIdFromOpeningTransaction(transaction.id);
    if (openingAccountId != null && isOpeningBalanceTransaction(transaction)) {
      final signed = transaction.type == TransactionType.income
          ? transaction.amountMinor
          : -transaction.amountMinor;
      await _writeOpeningBalance(openingAccountId, signed);
      await _repository.save(transaction);
      return;
    }
    if (openingAccountId != null) {
      await _writeOpeningBalance(openingAccountId, 0);
      await _repository.save(transaction.copyWith(id: createId()));
      await _repository.delete(transaction.id);
      return;
    }
    await _repository.save(transaction);
  }

  Future<void> _writeOpeningBalance(
    String accountId,
    int openingBalanceMinor,
  ) async {
    final accounts = await _accounts.getAll();
    final matches = accounts.where((account) => account.id == accountId);
    if (matches.isEmpty) {
      return;
    }
    final account = matches.first;
    if (account.openingBalanceMinor == openingBalanceMinor) {
      return;
    }
    await _accounts.save(
      account.copyWith(openingBalanceMinor: openingBalanceMinor),
    );
  }
}
