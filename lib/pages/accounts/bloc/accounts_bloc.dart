import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/models/account_book_model.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_state.dart';
import 'package:money_manager/repositories/account_repository.dart';
import 'package:money_manager/services/account_book_service.dart';

class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  final AccountRepository _repository;
  final AccountBookService _accountBook;

  AccountsBloc({
    required AccountRepository accounts,
    required AccountBookService accountBook,
  }) : _repository = accounts,
       _accountBook = accountBook,
       super(const AccountsState()) {
    on<AccountsInitialized>(_onAccountsInitialized);
    on<AccountSavePressed>(_onAccountSavePressed);
    on<AccountArchivePressed>(_onAccountArchivePressed);
    on<AccountsReorderPressed>(_onAccountsReorderPressed);
  }

  Future<void> _onAccountsInitialized(
    AccountsInitialized event,
    Emitter<AccountsState> emit,
  ) async {
    emit(
      state.copyWith(status: AccountsStatus.loading, error: AccountsError.none),
    );
    await _reload(emit);
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
      await _accountBook.syncOpeningTransactions([event.account]);
    } catch (_) {
      emit(
        state.copyWith(
          status: AccountsStatus.failure,
          error: AccountsError.saveFailed,
        ),
      );
      return;
    }
    await _reload(emit);
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
    } catch (_) {
      emit(
        state.copyWith(
          status: AccountsStatus.failure,
          error: AccountsError.saveFailed,
        ),
      );
      return;
    }
    await _reload(emit);
  }

  Future<void> _onAccountsReorderPressed(
    AccountsReorderPressed event,
    Emitter<AccountsState> emit,
  ) async {
    try {
      await _repository.reorder(event.ids);
    } catch (_) {
      emit(
        state.copyWith(
          status: AccountsStatus.failure,
          error: AccountsError.saveFailed,
        ),
      );
      return;
    }
    await _reload(emit);
  }

  Future<void> _reload(Emitter<AccountsState> emit) async {
    try {
      final loaded = await _accountBook.loadAccounts();
      emit(
        state.copyWith(
          status: AccountsStatus.success,
          accounts: [for (final book in loaded) book.account],
          balances: {for (final book in loaded) book.account.id: book.balance},
          netWorth: accountBookNetWorth(loaded),
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
}
