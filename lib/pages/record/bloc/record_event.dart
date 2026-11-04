import 'package:equatable/equatable.dart';
import 'package:money_manager/core/utils/amount_expression.dart';
import 'package:money_manager/models/ledger_kinds.dart';

sealed class RecordEvent extends Equatable {
  const RecordEvent();

  @override
  List<Object?> get props => [];
}

class RecordStarted extends RecordEvent {
  const RecordStarted({
    this.transactionId,
    this.initialType,
    this.initialAccountId,
  });

  final String? transactionId;
  final TransactionType? initialType;
  final String? initialAccountId;

  @override
  List<Object?> get props => [transactionId, initialType, initialAccountId];
}

class RecordTypeSelected extends RecordEvent {
  const RecordTypeSelected(this.type);

  final TransactionType type;

  @override
  List<Object?> get props => [type];
}

class RecordDateSelected extends RecordEvent {
  const RecordDateSelected(this.date);

  final DateTime date;

  @override
  List<Object?> get props => [date];
}

class RecordNoteChanged extends RecordEvent {
  const RecordNoteChanged(this.note);

  final String note;

  @override
  List<Object?> get props => [note];
}

class RecordAccountSelected extends RecordEvent {
  const RecordAccountSelected(this.accountId);

  final String accountId;

  @override
  List<Object?> get props => [accountId];
}

class RecordCategorySelected extends RecordEvent {
  const RecordCategorySelected(this.categoryId);

  final String categoryId;

  @override
  List<Object?> get props => [categoryId];
}

class RecordTransferFromSelected extends RecordEvent {
  const RecordTransferFromSelected(this.accountId);

  final String accountId;

  @override
  List<Object?> get props => [accountId];
}

class RecordTransferToSelected extends RecordEvent {
  const RecordTransferToSelected(this.accountId);

  final String accountId;

  @override
  List<Object?> get props => [accountId];
}

class RecordDigitPressed extends RecordEvent {
  const RecordDigitPressed(this.digit);

  final String digit;

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
  const RecordOperatorPressed(this.operator);

  final AmountOperator operator;

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

class RecordSourcesChanged extends RecordEvent {
  const RecordSourcesChanged({this.transactions = false});

  final bool transactions;

  @override
  List<Object?> get props => [transactions];
}
