import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/core/utils/opening_transaction.dart';
import 'package:money_manager/models/account_defaults.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_state.dart';
import 'package:money_manager/repositories/account_repository.dart';
import 'package:money_manager/repositories/transaction_repository.dart';

class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
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
      if (await _repository.isEmpty()) {
        await _repository.save(defaultAccount());
      }
      final accounts = await _repository.getAll();
      await _syncOpeningTransactions(accounts);
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
      await _syncOpeningTransactions([event.account]);
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

  Future<void> _syncOpeningTransactions(List<AccountModel> accounts) async {
    final existing = await _transactions.getAll();
    for (final account in accounts) {
      final id = openingTransactionId(account.id);
      final prior = existing.where((item) => item.id == id).toList();
      if (account.openingBalanceMinor == 0) {
        for (final item in prior) {
          await _transactions.delete(item.id);
        }
        continue;
      }
      final previous = prior.isEmpty ? null : prior.first;
      final type = account.openingBalanceMinor > 0
          ? TransactionType.income
          : TransactionType.expense;
      final sameType = previous != null && previous.type == type;
      await _transactions.save(
        TransactionModel(
          id: id,
          type: type,
          amountMinor: account.openingBalanceMinor.abs(),
          date: previous?.date ?? DateTime.now(),
          note: previous?.note ?? '',
          accountId: account.id,
          categoryId: sameType ? previous?.categoryId : null,
        ),
      );
    }
  }
}
