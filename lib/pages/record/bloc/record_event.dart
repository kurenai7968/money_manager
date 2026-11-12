import 'package:equatable/equatable.dart';
import 'package:money_manager/pages/record/models/amount_expression.dart';
import 'package:money_manager/models/account_book_kinds.dart';

sealed class RecordEvent extends Equatable {
  const RecordEvent();

  @override
  List<Object?> get props => [];
}

class RecordInitialized extends RecordEvent {
  final int? transactionId;
  final TransactionType? initialType;
  final int? initialAccountId;

  const RecordInitialized({
    this.transactionId,
    this.initialType,
    this.initialAccountId,
  });

  @override
  List<Object?> get props => [transactionId, initialType, initialAccountId];
}

class RecordTypeSelected extends RecordEvent {
  final TransactionType type;

  const RecordTypeSelected(this.type);

  @override
  List<Object?> get props => [type];
}

class RecordDateSelected extends RecordEvent {
  final DateTime date;

  const RecordDateSelected(this.date);

  @override
  List<Object?> get props => [date];
}

class RecordNoteChanged extends RecordEvent {
  final String note;

  const RecordNoteChanged(this.note);

  @override
  List<Object?> get props => [note];
}

class RecordAccountSelected extends RecordEvent {
  final int accountId;

  const RecordAccountSelected(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class RecordCategorySelected extends RecordEvent {
  final int categoryId;

  const RecordCategorySelected(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class RecordTransferFromSelected extends RecordEvent {
  final int accountId;

  const RecordTransferFromSelected(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class RecordTransferToSelected extends RecordEvent {
  final int accountId;

  const RecordTransferToSelected(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class RecordDigitPressed extends RecordEvent {
  final String digit;

  const RecordDigitPressed(this.digit);

  @override
  List<Object?> get props => [digit];
}

class RecordDoubleZeroPressed extends RecordEvent {
  const RecordDoubleZeroPressed();
}

class RecordDecimalPressed extends RecordEvent {
  const RecordDecimalPressed();
}

class RecordBackspacePressed extends RecordEvent {
  const RecordBackspacePressed();
}

class RecordClearPressed extends RecordEvent {
  const RecordClearPressed();
}

class RecordOperatorPressed extends RecordEvent {
  final AmountOperator operator;

  const RecordOperatorPressed(this.operator);

  @override
  List<Object?> get props => [operator];
}

class RecordEqualsPressed extends RecordEvent {
  const RecordEqualsPressed();
}

class RecordSavePressed extends RecordEvent {
  const RecordSavePressed();
}

class RecordDeletePressed extends RecordEvent {
  const RecordDeletePressed();
}
