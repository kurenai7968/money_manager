import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/core/utils/amount_expression.dart';
import 'package:money_manager/core/utils/id.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/record/bloc/record_event.dart';
import 'package:money_manager/pages/record/bloc/record_state.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_event.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_state.dart';

class RecordBloc extends Bloc<RecordEvent, RecordState> {
  RecordBloc({
    required TransactionsBloc transactions,
    required AccountsBloc accounts,
    required CategoriesBloc categories,
    DateTime Function()? now,
  }) : _transactions = transactions,
       _accounts = accounts,
       _categories = categories,
       _now = now ?? DateTime.now,
       super(RecordState(date: (now ?? DateTime.now)())) {
    on<RecordStarted>(_onStarted);
    on<RecordTypeSelected>(_onTypeSelected);
    on<RecordDateSelected>(_onDateSelected);
    on<RecordNoteChanged>(_onNoteChanged);
    on<RecordAccountSelected>(_onAccountSelected);
    on<RecordCategorySelected>(_onCategorySelected);
    on<RecordTransferFromSelected>(_onFromSelected);
    on<RecordTransferToSelected>(_onToSelected);
    on<RecordDigitPressed>(_onDigit);
    on<RecordDoubleZeroPressed>(_onDoubleZero);
    on<RecordDecimalPressed>(_onDecimal);
    on<RecordBackspacePressed>(_onBackspace);
    on<RecordClearPressed>(_onClear);
    on<RecordOperatorPressed>(_onOperator);
    on<RecordEqualsPressed>(_onEquals);
    on<RecordSavePressed>(_onSave);
    on<RecordDeletePressed>(_onDelete);
    on<RecordSourcesChanged>(_onSourcesChanged);
  }

  final TransactionsBloc _transactions;
  final AccountsBloc _accounts;
  final CategoriesBloc _categories;
  final DateTime Function() _now;
  final _subscriptions = <StreamSubscription<dynamic>>[];
  String? _transactionId;
  TransactionType? _initialType;
  String? _initialAccountId;
  String? _draftId;
  var _opened = false;
  var _existingReady = false;
  var _submitting = false;

  void _listen() {
    if (_subscriptions.isNotEmpty) {
      return;
    }
    _subscriptions.add(
      _transactions.stream.listen(
        (_) => add(const RecordSourcesChanged(transactions: true)),
      ),
    );
    _subscriptions.add(
      _accounts.stream.listen((_) => add(const RecordSourcesChanged())),
    );
    _subscriptions.add(
      _categories.stream.listen((_) => add(const RecordSourcesChanged())),
    );
  }

  void _onStarted(RecordStarted event, Emitter<RecordState> emit) {
    _transactionId = event.transactionId;
    _initialType = event.initialType;
    _initialAccountId = event.initialAccountId;
    _listen();
    emit(_refresh(state.copyWith(transactionId: event.transactionId)));
  }

  void _onTypeSelected(RecordTypeSelected event, Emitter<RecordState> emit) {
    final next = event.type;
    var categoryId = state.categoryId;
    var clearCategory = false;
    if (next == TransactionType.transfer) {
      categoryId = null;
      clearCategory = true;
    } else {
      CategoryModel? selected;
      for (final item in _categories.state.categories) {
        if (item.id == categoryId) {
          selected = item;
          break;
        }
      }
      if (selected != null && selected.kind.name != next.name) {
        categoryId = null;
        clearCategory = true;
      }
    }
    emit(
      _refresh(
        state.copyWith(
          type: next,
          categoryId: categoryId,
          clearCategoryId: clearCategory,
          error: RecordError.none,
          status: RecordStatus.success,
        ),
      ),
    );
  }

  void _onDateSelected(RecordDateSelected event, Emitter<RecordState> emit) {
    emit(
      state.copyWith(
        date: event.date,
        error: RecordError.none,
        status: RecordStatus.success,
      ),
    );
  }

  void _onNoteChanged(RecordNoteChanged event, Emitter<RecordState> emit) {
    emit(
      state.copyWith(
        note: event.note,
        error: RecordError.none,
        status: RecordStatus.success,
      ),
    );
  }

  void _onAccountSelected(
    RecordAccountSelected event,
    Emitter<RecordState> emit,
  ) {
    emit(
      state.copyWith(
        accountId: event.accountId,
        error: RecordError.none,
        status: RecordStatus.success,
      ),
    );
  }

  void _onCategorySelected(
    RecordCategorySelected event,
    Emitter<RecordState> emit,
  ) {
    emit(
      state.copyWith(
        categoryId: event.categoryId,
        error: RecordError.none,
        status: RecordStatus.success,
      ),
    );
  }

  void _onFromSelected(
    RecordTransferFromSelected event,
    Emitter<RecordState> emit,
  ) {
    emit(
      state.copyWith(
        fromId: event.accountId,
        error: RecordError.none,
        status: RecordStatus.success,
      ),
    );
  }

  void _onToSelected(
    RecordTransferToSelected event,
    Emitter<RecordState> emit,
  ) {
    emit(
      state.copyWith(
        toId: event.accountId,
        error: RecordError.none,
        status: RecordStatus.success,
      ),
    );
  }

  void _onDigit(RecordDigitPressed event, Emitter<RecordState> emit) {
    _edit(emit, state.expression.appendDigit(event.digit));
  }

  void _onDoubleZero(RecordDoubleZeroPressed event, Emitter<RecordState> emit) {
    _edit(emit, state.expression.appendDoubleZero());
  }

  void _onDecimal(RecordDecimalPressed event, Emitter<RecordState> emit) {
    _edit(emit, state.expression.appendDecimal());
  }

  void _onBackspace(RecordBackspacePressed event, Emitter<RecordState> emit) {
    _edit(emit, state.expression.backspace());
  }

  void _onClear(RecordClearPressed event, Emitter<RecordState> emit) {
    _edit(emit, state.expression.clear());
  }

  void _onOperator(RecordOperatorPressed event, Emitter<RecordState> emit) {
    _edit(emit, state.expression.applyOperator(event.operator));
  }

  void _onEquals(RecordEqualsPressed event, Emitter<RecordState> emit) {
    final next = state.expression.evaluate();
    if (next == null) {
      emit(
        state.copyWith(
          status: RecordStatus.failure,
          error: RecordError.invalid,
        ),
      );
      return;
    }
    _edit(emit, next);
  }

  void _edit(Emitter<RecordState> emit, AmountExpression next) {
    emit(
      state.copyWith(
        expression: next,
        error: RecordError.none,
        status: RecordStatus.success,
      ),
    );
  }

  void _onSave(RecordSavePressed event, Emitter<RecordState> emit) {
    final accounts = state.accounts;
    final error = _validationError(state.result, accounts);
    if (error != null) {
      emit(state.copyWith(status: RecordStatus.failure, error: error));
      return;
    }
    _draftId ??= _transactionId ?? createId();
    _submitting = true;
    emit(state.copyWith(status: RecordStatus.success, error: RecordError.none));
    final type = state.type;
    _transactions.add(
      TransactionSavePressed(
        TransactionModel(
          id: _draftId!,
          type: type,
          amountMinor: state.result!,
          date: state.date,
          note: state.note,
          accountId: type == TransactionType.transfer ? null : state.accountId,
          categoryId: type == TransactionType.transfer
              ? null
              : state.categoryId,
          fromAccountId: type == TransactionType.transfer ? state.fromId : null,
          toAccountId: type == TransactionType.transfer ? state.toId : null,
        ),
      ),
    );
  }

  void _onDelete(RecordDeletePressed event, Emitter<RecordState> emit) {
    final id = _transactionId;
    if (id == null) {
      return;
    }
    _submitting = true;
    _transactions.add(TransactionDeletePressed(id));
  }

  void _onSourcesChanged(
    RecordSourcesChanged event,
    Emitter<RecordState> emit,
  ) {
    if (_submitting && event.transactions) {
      final transactions = _transactions.state;
      if (transactions.status == TransactionsStatus.success &&
          transactions.error == TransactionsError.none) {
        _submitting = false;
        emit(
          state.copyWith(
            status: RecordStatus.success,
            error: RecordError.none,
            closePage: true,
          ),
        );
        return;
      }
      if (transactions.error == TransactionsError.invalid) {
        _submitting = false;
        emit(
          state.copyWith(
            status: RecordStatus.failure,
            error: RecordError.invalid,
          ),
        );
        return;
      }
    }
    emit(_refresh(state));
  }

  RecordState _refresh(RecordState current) {
    final loaded = _accounts.state.active;
    final transactions = _transactions.state;
    var next = current;

    if (!_opened) {
      _opened = true;
      next = next.copyWith(
        type: _initialType ?? TransactionType.expense,
        accountId: _initialAccountId,
        fromId: _initialAccountId,
      );
    }

    if (!_existingReady && _transactionId != null) {
      TransactionModel? existing;
      for (final item in transactions.transactions) {
        if (item.id == _transactionId) {
          existing = item;
          break;
        }
      }
      if (existing == null) {
        if (transactions.status == TransactionsStatus.success ||
            transactions.status == TransactionsStatus.failure) {
          _existingReady = true;
        } else {
          return _withCategories(next, loaded);
        }
      } else {
        next = next.copyWith(
          type: existing.type,
          date: existing.date,
          note: existing.note,
          accountId: existing.accountId,
          clearAccountId: existing.accountId == null,
          categoryId: existing.categoryId,
          clearCategoryId: existing.categoryId == null,
          fromId: existing.fromAccountId,
          clearFromId: existing.fromAccountId == null,
          toId: existing.toAccountId,
          clearToId: existing.toAccountId == null,
          expression: AmountExpression.fromMinor(existing.amountMinor),
        );
        _existingReady = true;
      }
    }

    if (_transactionId == null && loaded.isNotEmpty) {
      if (next.type != TransactionType.transfer && next.accountId == null) {
        next = next.copyWith(accountId: _accountOn(loaded, _initialAccountId));
      }
      next = next.copyWith(
        fromId: next.fromId ?? _accountOn(loaded, _initialAccountId),
      );
    }

    return _withCategories(next, loaded);
  }

  RecordState _withCategories(RecordState current, List<AccountModel> loaded) {
    final visible = [
      for (final category in _categories.state.active)
        if (category.kind.name == current.type.name) category,
    ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    var categoryId = current.categoryId;
    var clearCategory = false;
    final waitingForExisting = _transactionId != null && !_existingReady;
    if (current.type != TransactionType.transfer &&
        visible.isNotEmpty &&
        !waitingForExisting) {
      final selected = visible.where((item) => item.id == categoryId);
      if (selected.isEmpty) {
        categoryId = visible.first.id;
      }
    }
    if (categoryId == null) {
      clearCategory = current.categoryId != null;
    }
    return current.copyWith(
      status: current.status == RecordStatus.initial
          ? RecordStatus.success
          : current.status,
      accounts: loaded,
      visibleCategories: visible,
      categoryId: categoryId,
      clearCategoryId: clearCategory,
    );
  }

  String _accountOn(List<AccountModel> loaded, String? preferred) {
    for (final account in loaded) {
      if (account.id == preferred) {
        return account.id;
      }
    }
    return loaded.first.id;
  }

  RecordError? _validationError(int? amount, List<AccountModel> loaded) {
    if (loaded.isEmpty) {
      return RecordError.needAccount;
    }
    if (amount == null || amount <= 0) {
      return RecordError.invalid;
    }
    final known = loaded.map((account) => account.id).toSet();
    if (state.type == TransactionType.transfer) {
      final fromId = state.fromId;
      final toId = state.toId;
      final pair =
          fromId != null &&
          toId != null &&
          fromId != toId &&
          known.contains(fromId) &&
          known.contains(toId);
      return pair ? null : RecordError.needDifferentAccounts;
    }
    if (state.categoryId == null) {
      return RecordError.needCategory;
    }
    if (state.accountId == null || !known.contains(state.accountId)) {
      return RecordError.chooseAccount;
    }
    return null;
  }

  @override
  Future<void> close() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    return super.close();
  }
}
