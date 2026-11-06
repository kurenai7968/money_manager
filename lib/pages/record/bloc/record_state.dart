import 'package:equatable/equatable.dart';
import 'package:money_manager/core/utils/amount_expression.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';

enum RecordStatus { initial, success, failure }

enum RecordError {
  none,
  needAccount,
  invalid,
  needDifferentAccounts,
  needCategory,
  chooseAccount,
}

class RecordState extends Equatable {
  final RecordStatus status;
  final RecordError error;
  final bool closePage;
  final TransactionType type;
  final DateTime date;
  final String note;
  final String? accountId;
  final String? categoryId;
  final String? fromId;
  final String? toId;
  final String? transactionId;
  final AmountExpression expression;
  final List<AccountModel> accounts;
  final List<CategoryModel> visibleCategories;

  const RecordState({
    this.status = RecordStatus.initial,
    this.error = RecordError.none,
    this.closePage = false,
    this.type = TransactionType.expense,
    required this.date,
    this.note = '',
    this.accountId,
    this.categoryId,
    this.fromId,
    this.toId,
    this.transactionId,
    this.expression = const AmountExpression(),
    this.accounts = const [],
    this.visibleCategories = const [],
  });

  int? get result => expression.resultMinor;

  RecordState copyWith({
    RecordStatus? status,
    RecordError? error,
    bool? closePage,
    TransactionType? type,
    DateTime? date,
    String? note,
    String? accountId,
    bool clearAccountId = false,
    String? categoryId,
    bool clearCategoryId = false,
    String? fromId,
    bool clearFromId = false,
    String? toId,
    bool clearToId = false,
    String? transactionId,
    bool clearTransactionId = false,
    AmountExpression? expression,
    List<AccountModel>? accounts,
    List<CategoryModel>? visibleCategories,
  }) {
    return RecordState(
      status: status ?? this.status,
      error: error ?? this.error,
      closePage: closePage ?? this.closePage,
      type: type ?? this.type,
      date: date ?? this.date,
      note: note ?? this.note,
      accountId: clearAccountId ? null : accountId ?? this.accountId,
      categoryId: clearCategoryId ? null : categoryId ?? this.categoryId,
      fromId: clearFromId ? null : fromId ?? this.fromId,
      toId: clearToId ? null : toId ?? this.toId,
      transactionId: clearTransactionId
          ? null
          : transactionId ?? this.transactionId,
      expression: expression ?? this.expression,
      accounts: accounts ?? this.accounts,
      visibleCategories: visibleCategories ?? this.visibleCategories,
    );
  }

  @override
  List<Object?> get props => [
    status,
    error,
    closePage,
    type,
    date,
    note,
    accountId,
    categoryId,
    fromId,
    toId,
    transactionId,
    expression,
    accounts,
    visibleCategories,
  ];
}
