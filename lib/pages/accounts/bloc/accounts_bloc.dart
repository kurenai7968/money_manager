import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/core/utils/ledger_commands.dart';
import 'package:money_manager/core/utils/queued_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_state.dart';
import 'package:money_manager/repositories/account_repository.dart';
import 'package:money_manager/repositories/transaction_repository.dart';

class AccountsBloc extends Bloc<AccountsEvent, AccountsState>
    with QueuedBloc<AccountsEvent, AccountsState> {
  final AccountRepository _repository;
  final TransactionRepository _transactions;

  AccountsBloc(this._repository, this._transactions)
    : super(const AccountsState()) {
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
      final loaded = await loadAccounts(_repository, _transactions);
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
      await syncOpeningTransactions(_transactions, [event.account]);
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
