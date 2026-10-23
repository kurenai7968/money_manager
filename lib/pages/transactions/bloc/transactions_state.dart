import 'package:equatable/equatable.dart';
import 'package:money_manager/models/transaction_model.dart';

enum TransactionsStatus { initial, loading, success, failure }

enum TransactionsError { none, saveFailed, invalid }

class TransactionsState extends Equatable {
  const TransactionsState({
    this.status = TransactionsStatus.initial,
    this.transactions = const [],
    this.error = TransactionsError.none,
  });

  final TransactionsStatus status;
  final List<TransactionModel> transactions;
  final TransactionsError error;

  TransactionsState copyWith({
    TransactionsStatus? status,
    List<TransactionModel>? transactions,
    TransactionsError? error,
  }) {
    return TransactionsState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, transactions, error];
}
