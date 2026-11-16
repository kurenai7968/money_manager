import 'package:equatable/equatable.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';

export 'package:money_manager/models/day_ledger.dart';

class MonthFigures extends Equatable {
  final double income;
  final double expense;

  const MonthFigures({required this.income, required this.expense});

  double get balance => income - expense;

  @override
  List<Object?> get props => [income, expense];
}

MonthFigures monthFigures(
  Iterable<TransactionModel> transactions,
  DateTime month,
) {
  var income = 0.0;
  var expense = 0.0;
  for (final transaction in transactions) {
    if (transaction.date.year != month.year ||
        transaction.date.month != month.month) {
      continue;
    }
    if (transaction.type == TransactionType.income) {
      income += transaction.amount;
    } else if (transaction.type == TransactionType.expense) {
      expense += transaction.amount;
    }
  }
  return MonthFigures(income: income, expense: expense);
}
