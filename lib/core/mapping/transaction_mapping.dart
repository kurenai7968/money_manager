import 'package:money_manager/entities/transaction_entity.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';

extension TransactionEntityMapping on TransactionEntity {
  TransactionModel toModel() {
    return TransactionModel(
      id: id,
      type: TransactionType.values.byName(type),
      amountMinor: amountMinor,
      date: DateTime.parse(date),
      note: note ?? '',
      accountId: accountId,
      categoryId: categoryId,
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
    );
  }
}

extension TransactionModelMapping on TransactionModel {
  TransactionEntity toEntity() {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return TransactionEntity(
      id: id,
      type: type.name,
      amountMinor: amountMinor,
      date: '${date.year}-$month-$day',
      note: note.isEmpty ? null : note,
      accountId: accountId,
      categoryId: categoryId,
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
    );
  }
}
