import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/core/utils/id.dart';
import 'package:money_manager/core/utils/ledger_balance.dart';
import 'package:money_manager/core/utils/money_format.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/pages/accounts/bloc/account_form_event.dart';
import 'package:money_manager/pages/accounts/bloc/account_form_state.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_state.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';

class AccountFormBloc extends Bloc<AccountFormEvent, AccountFormState> {
  AccountFormBloc({
    required AccountsBloc accounts,
    required TransactionsBloc transactions,
  }) : _accounts = accounts,
       _transactions = transactions,
       super(AccountFormState(accountId: createId())) {
    on<AccountFormStarted>(_onStarted);
    on<AccountFormTypeSelected>(_onTypeSelected);
    on<AccountFormSavePressed>(_onSave);
    on<AccountFormArchivePressed>(_onArchive);
    on<AccountFormSourcesChanged>(_onSourcesChanged);
  }

  final AccountsBloc _accounts;
  final TransactionsBloc _transactions;
  final _subscriptions = <StreamSubscription<dynamic>>[];
  var _prepared = false;
  var _submitting = false;
  String? _languageCode;
  String? _languageEn;
  String? _languageZh;
  String? _languageZhCn;
  var _locale = 'en';

  void _listen() {
    if (_subscriptions.isNotEmpty) {
      return;
    }
    _subscriptions.add(
      _accounts.stream.listen((_) => add(const AccountFormSourcesChanged())),
    );
  }

  void _onStarted(AccountFormStarted event, Emitter<AccountFormState> emit) {
    _locale = event.locale;
    _languageCode = event.languageCode;
    _listen();
    final next = state.copyWith(
      editing: event.accountId != null,
      accountId: event.accountId ?? state.accountId,
    );
    if (!_canPrepare()) {
      emit(next);
      return;
    }
    _emitPrepared(emit, next);
  }

  void _onTypeSelected(
    AccountFormTypeSelected event,
    Emitter<AccountFormState> emit,
  ) {
    emit(state.copyWith(type: event.type));
  }

  void _onSave(AccountFormSavePressed event, Emitter<AccountFormState> emit) {
    final name = event.name.trim();
    if (name.isEmpty) {
      emit(
        state.copyWith(
          status: AccountFormStatus.failure,
          error: AccountFormError.nameRequired,
        ),
      );
      return;
    }
    final minor = parseAmountMinor(event.balanceText);
    if (minor == null) {
      emit(
        state.copyWith(
          status: AccountFormStatus.failure,
          error: AccountFormError.amountInvalid,
        ),
      );
      return;
    }
    final code = event.languageCode;
    final account = AccountModel(
      id: state.accountId,
      name: state.localized ? null : name,
      languageEn: state.localized ? (code == 'en' ? name : _languageEn) : null,
      languageZh: state.localized ? (code == 'zh' ? name : _languageZh) : null,
      languageZhCn: state.localized
          ? (code == 'zh_CN' ? name : _languageZhCn)
          : null,
      type: state.type,
      openingBalanceMinor: minor,
      sortOrder: state.sortOrder,
      archived: state.archived,
    );
    _submitting = true;
    emit(
      state.copyWith(
        status: AccountFormStatus.success,
        error: AccountFormError.none,
      ),
    );
    _accounts.add(AccountSavePressed(account));
  }

  void _onArchive(
    AccountFormArchivePressed event,
    Emitter<AccountFormState> emit,
  ) {
    AccountModel? account;
    for (final item in _accounts.state.accounts) {
      if (item.id == state.accountId) {
        account = item;
        break;
      }
    }
    if (account == null) {
      return;
    }
    final balance = balanceOf(account, _transactions.state.transactions);
    _submitting = true;
    _accounts.add(AccountArchivePressed(account, balanceMinor: balance));
  }

  void _onSourcesChanged(
    AccountFormSourcesChanged event,
    Emitter<AccountFormState> emit,
  ) {
    final accounts = _accounts.state;
    if (_submitting) {
      if (accounts.status == AccountsStatus.success &&
          accounts.error == AccountsError.none) {
        _submitting = false;
        emit(
          state.copyWith(
            status: AccountFormStatus.success,
            error: AccountFormError.none,
            saved: true,
          ),
        );
        return;
      }
      if (accounts.error == AccountsError.nameRequired) {
        _submitting = false;
        emit(
          state.copyWith(
            status: AccountFormStatus.failure,
            error: AccountFormError.nameRequired,
          ),
        );
        return;
      }
      if (accounts.error == AccountsError.archiveBlocked) {
        _submitting = false;
        emit(
          state.copyWith(
            status: AccountFormStatus.failure,
            error: AccountFormError.archiveBlocked,
          ),
        );
        return;
      }
      if (accounts.status == AccountsStatus.failure) {
        _submitting = false;
      }
    }
    if (!_canPrepare()) {
      return;
    }
    _emitPrepared(emit, state);
  }

  bool _canPrepare() {
    if (_prepared || _languageCode == null) {
      return false;
    }
    final status = _accounts.state.status;
    return status == AccountsStatus.success || status == AccountsStatus.failure;
  }

  void _emitPrepared(Emitter<AccountFormState> emit, AccountFormState current) {
    final code = _languageCode;
    if (code == null) {
      return;
    }
    _prepared = true;
    final accounts = _accounts.state;
    AccountModel? existing;
    for (final account in accounts.accounts) {
      if (account.id == current.accountId) {
        existing = account;
        break;
      }
    }
    if (existing != null) {
      _languageEn = existing.languageEn;
      _languageZh = existing.languageZh;
      _languageZhCn = existing.languageZhCn;
      emit(
        current.copyWith(
          status: AccountFormStatus.success,
          prepared: true,
          editing: true,
          type: existing.type,
          sortOrder: existing.sortOrder,
          archived: existing.archived,
          localized:
              existing.languageEn != null ||
              existing.languageZh != null ||
              existing.languageZhCn != null,
          name: existing.labelFor(code),
          balanceText: formatMinor(
            existing.openingBalanceMinor,
            locale: _locale,
          ).replaceAll(',', ''),
        ),
      );
      return;
    }
    var sortOrder = 0;
    for (final account in accounts.accounts) {
      if (account.sortOrder >= sortOrder) {
        sortOrder = account.sortOrder + 1;
      }
    }
    emit(
      current.copyWith(
        status: AccountFormStatus.success,
        prepared: true,
        sortOrder: sortOrder,
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
