import 'package:equatable/equatable.dart';
import 'package:money_manager/models/transaction_model.dart';

sealed class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object?> get props => [];
}

class TransactionsStarted extends TransactionsEvent {
  const TransactionsStarted();
}

class TransactionSavePressed extends TransactionsEvent {
  final TransactionModel transaction;

  const TransactionSavePressed(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class TransactionDeletePressed extends TransactionsEvent {
  final String id;

  const TransactionDeletePressed(this.id);

  @override
  List<Object?> get props => [id];
}
