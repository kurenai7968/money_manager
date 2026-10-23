import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_state.dart';
import 'package:money_manager/repositories/account_repository.dart';

class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  AccountsBloc(this._repository) : super(const AccountsState()) {
    on<AccountsStarted>(_onAccountsStarted);
    on<AccountSavePressed>(_onAccountSavePressed);
    on<AccountArchivePressed>(_onAccountArchivePressed);
    on<AccountsReorderPressed>(_onAccountsReorderPressed);
  }

  final AccountRepository _repository;

  Future<void> _onAccountsStarted(
    AccountsStarted event,
    Emitter<AccountsState> emit,
  ) async {
    emit(
      state.copyWith(status: AccountsStatus.loading, error: AccountsError.none),
    );
    try {
      final accounts = await _repository.getAll();
      emit(state.copyWith(status: AccountsStatus.success, accounts: accounts));
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
    if (event.account.name.trim().isEmpty) {
      emit(
        state.copyWith(
          status: AccountsStatus.failure,
          error: AccountsError.nameRequired,
        ),
      );
      return;
    }
    if (event.account.openingBalanceMinor < 0) {
      emit(
        state.copyWith(
          status: AccountsStatus.failure,
          error: AccountsError.saveFailed,
        ),
      );
      return;
    }
    try {
      await _repository.save(event.account);
      final accounts = await _repository.getAll();
      emit(
        state.copyWith(
          status: AccountsStatus.success,
          accounts: accounts,
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
      emit(
        state.copyWith(
          status: AccountsStatus.success,
          accounts: accounts,
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
      emit(state.copyWith(status: AccountsStatus.success, accounts: accounts));
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
