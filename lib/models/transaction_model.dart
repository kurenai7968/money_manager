import 'package:equatable/equatable.dart';
import 'package:money_manager/models/ledger_kinds.dart';

class TransactionModel extends Equatable {
  const TransactionModel({
    required this.id,
    required this.type,
    required this.amountMinor,
    required this.date,
    this.note = '',
    this.accountId,
    this.categoryId,
    this.fromAccountId,
    this.toAccountId,
  });

  final String id;
  final TransactionType type;
  final int amountMinor;
  final DateTime date;
  final String note;
  final String? accountId;
  final String? categoryId;
  final String? fromAccountId;
  final String? toAccountId;

  TransactionModel copyWith({
    String? id,
    TransactionType? type,
    int? amountMinor,
    DateTime? date,
    String? note,
    String? accountId,
    String? categoryId,
    String? fromAccountId,
    String? toAccountId,
    bool clearCategory = false,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amountMinor: amountMinor ?? this.amountMinor,
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
    amountMinor,
    date,
    note,
    accountId,
    categoryId,
    fromAccountId,
    toAccountId,
  ];
}
