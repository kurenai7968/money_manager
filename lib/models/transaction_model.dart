import 'package:equatable/equatable.dart';
import 'package:money_manager/models/account_book_kinds.dart';

class TransactionModel extends Equatable {
  final int? id;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final String note;
  final int? accountId;
  final int? categoryId;
  final int? fromAccountId;
  final int? toAccountId;

  const TransactionModel({
    this.id,
    required this.type,
    required this.amount,
    required this.date,
    this.note = '',
    this.accountId,
    this.categoryId,
    this.fromAccountId,
    this.toAccountId,
  });

  TransactionModel copyWith({
    int? id,
    TransactionType? type,
    double? amount,
    DateTime? date,
    String? note,
    int? accountId,
    int? categoryId,
    int? fromAccountId,
    int? toAccountId,
    bool clearCategory = false,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      accountId: accountId ?? this.accountId,
      categoryId: clearCategory ? null : categoryId ?? this.categoryId,
      fromAccountId: fromAccountId ?? this.fromAccountId,
      toAccountId: toAccountId ?? this.toAccountId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    amount,
    date,
    note,
    accountId,
    categoryId,
    fromAccountId,
    toAccountId,
  ];
}
