import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/core/utils/id.dart';
import 'package:money_manager/core/utils/ledger_balance.dart';
import 'package:money_manager/services/ledger_service.dart';
import 'package:money_manager/core/utils/money_format.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/accounts/bloc/account_form_event.dart';
import 'package:money_manager/pages/accounts/bloc/account_form_state.dart';
import 'package:money_manager/repositories/account_repository.dart';

class AccountFormBloc extends Bloc<AccountFormEvent, AccountFormState> {
  final AccountRepository _accounts;
  final LedgerService _ledger;
  var _prepared = false;
  String? _languageCode;
  String? _languageEn;
  String? _languageZh;
  String? _languageZhCn;
  var _locale = 'en';
  List<AccountModel> _accountRows = const [];
  List<TransactionModel> _transactionRows = const [];

  AccountFormBloc({
    required AccountRepository accounts,
    required LedgerService ledger,
  }) : _accounts = accounts,
       _ledger = ledger,
       super(AccountFormState(accountId: createId())) {
    on<AccountFormInitialized>(_onInitialized);
    on<AccountFormTypeSelected>(_onTypeSelected);
    on<AccountFormSavePressed>(_onSave);
    on<AccountFormArchivePressed>(_onArchive);
  }

  Future<void> _onInitialized(
    AccountFormInitialized event,
    Emitter<AccountFormState> emit,
  ) async {
    _locale = event.locale;
    _languageCode = event.languageCode;
    final next = state.copyWith(
      editing: event.accountId != null,
      accountId: event.accountId ?? state.accountId,
    );
    if (_prepared || _languageCode == null) {
      emit(next);
      return;
    }
    try {
      final loaded = await _ledger.loadAccounts();
      _accountRows = loaded.accounts;
      _transactionRows = loaded.transactions;
    } catch (_) {
      _accountRows = const [];
      _transactionRows = const [];
    }
    _emitPrepared(emit, next);
  }

  void _onTypeSelected(
    AccountFormTypeSelected event,
    Emitter<AccountFormState> emit,
  ) {
    emit(state.copyWith(type: event.type));
  }

  Future<void> _onSave(
    AccountFormSavePressed event,
    Emitter<AccountFormState> emit,
  ) async {
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
    if (!account.hasLabel) {
      emit(
        state.copyWith(
          status: AccountFormStatus.failure,
          error: AccountFormError.nameRequired,
        ),
      );
      return;
    }
    try {
      await _accounts.save(account);
      await _ledger.syncOpeningTransactions([account]);
      emit(
        state.copyWith(
          status: AccountFormStatus.success,
          error: AccountFormError.none,
          saved: true,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: AccountFormStatus.failure));
    }
  }

  Future<void> _onArchive(
    AccountFormArchivePressed event,
    Emitter<AccountFormState> emit,
  ) async {
    AccountModel? account;
    for (final item in _accountRows) {
      if (item.id == state.accountId) {
        account = item;
        break;
      }
    }
    if (account == null) {
      return;
    }
    final balance = balanceOf(account, _transactionRows);
    if (balance != 0) {
      emit(
        state.copyWith(
          status: AccountFormStatus.failure,
          error: AccountFormError.archiveBlocked,
        ),
      );
      return;
    }
    try {
      await _accounts.archive(account.id);
      emit(
        state.copyWith(
          status: AccountFormStatus.success,
          error: AccountFormError.none,
          saved: true,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: AccountFormStatus.failure));
    }
  }

  void _emitPrepared(Emitter<AccountFormState> emit, AccountFormState current) {
    final code = _languageCode;
    if (code == null) {
      return;
    }
    _prepared = true;
    AccountModel? existing;
    for (final account in _accountRows) {
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
    for (final account in _accountRows) {
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
}
