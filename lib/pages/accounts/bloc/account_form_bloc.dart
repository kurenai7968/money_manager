import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/services/account_book_service.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/pages/accounts/bloc/account_form_event.dart';
import 'package:money_manager/pages/accounts/bloc/account_form_state.dart';
import 'package:money_manager/repositories/account_repository.dart';

class AccountFormBloc extends Bloc<AccountFormEvent, AccountFormState> {
  final AccountRepository _accounts;
  final AccountBookService _accountBook;
  var _prepared = false;
  String? _languageCode;
  String? _languageEn;
  String? _languageZh;
  String? _languageZhCn;
  List<AccountModel> _accountRows = const [];
  Map<int, double> _balances = const {};

  AccountFormBloc({
    required AccountRepository accounts,
    required AccountBookService accountBook,
  }) : _accounts = accounts,
       _accountBook = accountBook,
       super(const AccountFormState()) {
    on<AccountFormInitialized>(_onInitialized);
    on<AccountFormTypeSelected>(_onTypeSelected);
    on<AccountFormIconSelected>(_onIconSelected);
    on<AccountFormSavePressed>(_onSave);
    on<AccountFormArchivePressed>(_onArchive);
  }

  Future<void> _onInitialized(
    AccountFormInitialized event,
    Emitter<AccountFormState> emit,
  ) async {
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
      final loaded = await _accountBook.loadAccounts();
      _accountRows = [for (final book in loaded) book.account];
      _balances = {
        for (final book in loaded)
          if (book.account.id != null) book.account.id!: book.balance,
      };
    } catch (_) {
      _accountRows = const [];
      _balances = const {};
    }
    _emitPrepared(emit, next);
  }

  void _onTypeSelected(
    AccountFormTypeSelected event,
    Emitter<AccountFormState> emit,
  ) {
    emit(state.copyWith(type: event.type));
  }

  void _onIconSelected(
    AccountFormIconSelected event,
    Emitter<AccountFormState> emit,
  ) {
    emit(state.copyWith(icon: event.icon));
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
      icon: state.icon,
      sortOrder: state.sortOrder,
      isActive: state.isActive,
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
      final id = await _accounts.save(account);
      emit(
        state.copyWith(
          accountId: id,
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
    final id = state.accountId;
    if (id == null) {
      return;
    }
    AccountModel? account;
    for (final item in _accountRows) {
      if (item.id == id) {
        account = item;
        break;
      }
    }
    if (account == null) {
      return;
    }
    final balance = _balances[id] ?? 0;
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
      await _accounts.archive(id);
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
          icon: existing.icon,
          sortOrder: existing.sortOrder,
          isActive: existing.isActive,
          localized:
              existing.languageEn != null ||
              existing.languageZh != null ||
              existing.languageZhCn != null,
          name: existing.labelFor(code),
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
