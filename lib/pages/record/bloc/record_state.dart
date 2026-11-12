import 'package:equatable/equatable.dart';
import 'package:money_manager/pages/record/models/amount_expression.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/account_book_kinds.dart';

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
  final int? accountId;
  final int? categoryId;
  final int? fromId;
  final int? toId;
  final int? transactionId;
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

  double? get result {
    final minor = expression.resultMinor;
    if (minor == null) {
      return null;
    }
    return minor / 100;
  }

  RecordState copyWith({
    RecordStatus? status,
    RecordError? error,
    bool? closePage,
    TransactionType? type,
    DateTime? date,
    String? note,
    int? accountId,
    bool clearAccountId = false,
    int? categoryId,
    bool clearCategoryId = false,
    int? fromId,
    bool clearFromId = false,
    int? toId,
    bool clearToId = false,
    int? transactionId,
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
