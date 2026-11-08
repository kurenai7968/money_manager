import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_state.dart';
import 'package:money_manager/repositories/account_repository.dart';
import 'package:money_manager/services/ledger_service.dart';
import 'package:money_manager/repositories/transaction_repository.dart';

class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  final AccountRepository _repository;
  final TransactionRepository _transactions;
  final LedgerService _ledger;

  AccountsBloc({
    required AccountRepository accounts,
    required TransactionRepository transactions,
    required LedgerService ledger,
  }) : _repository = accounts,
       _transactions = transactions,
       _ledger = ledger,
       super(const AccountsState()) {
    on<AccountsStarted>(_onAccountsStarted);
    on<AccountSavePressed>(_onAccountSavePressed);
    on<AccountArchivePressed>(_onAccountArchivePressed);
    on<AccountsReorderPressed>(_onAccountsReorderPressed);
  }

  Future<void> _onAccountsStarted(
    AccountsStarted event,
    Emitter<AccountsState> emit,
  ) async {
    emit(
      state.copyWith(status: AccountsStatus.loading, error: AccountsError.none),
    );
    try {
      final loaded = await _ledger.loadAccounts();
      emit(
        state.copyWith(
          status: AccountsStatus.success,
          accounts: loaded.accounts,
          transactions: loaded.transactions,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AccountsStatus.failure,
          error: AccountsError.saveFailed,
        ),
      );
    }
  }

  Future<void> _onAccountSavePressed(
    AccountSavePressed event,
    Emitter<AccountsState> emit,
  ) async {
    if (!event.account.hasLabel) {
      emit(
        state.copyWith(
          status: AccountsStatus.failure,
          error: AccountsError.nameRequired,
        ),
      );
      return;
    }
    try {
      await _repository.save(event.account);
      await _ledger.syncOpeningTransactions([event.account]);
      final accounts = await _repository.getAll();
      final transactions = await _transactions.getAll();
      emit(
        state.copyWith(
          status: AccountsStatus.success,
          accounts: accounts,
          transactions: transactions,
          error: AccountsError.none,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AccountsStatus.failure,
          error: AccountsError.saveFailed,
        ),
      );
    }
  }

  Future<void> _onAccountArchivePressed(
    AccountArchivePressed event,
    Emitter<AccountsState> emit,
  ) async {
    if (event.balanceMinor != 0) {
      emit(
        state.copyWith(
          status: AccountsStatus.failure,
          error: AccountsError.archiveBlocked,
        ),
      );
      return;
    }
    try {
      await _repository.archive(event.account.id);
      final accounts = await _repository.getAll();
      final transactions = await _transactions.getAll();
      emit(
        state.copyWith(
          status: AccountsStatus.success,
          accounts: accounts,
          transactions: transactions,
          error: AccountsError.none,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AccountsStatus.failure,
          error: AccountsError.saveFailed,
        ),
      );
    }
  }

  Future<void> _onAccountsReorderPressed(
    AccountsReorderPressed event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      await _repository.reorder(event.ids);
      final accounts = await _repository.getAll();
      final transactions = await _transactions.getAll();
      emit(
        state.copyWith(
          status: AccountsStatus.success,
          accounts: accounts,
          transactions: transactions,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AccountsStatus.failure,
          error: AccountsError.saveFailed,
        ),
      );
    }
  }
}
