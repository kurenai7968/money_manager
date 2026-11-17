import 'package:equatable/equatable.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';

class DayAccountBook extends Equatable {
  final DateTime day;
  final double net;
  final double expense;
  final List<TransactionModel> transactions;

  const DayAccountBook({
    required this.day,
    required this.net,
    required this.expense,
    required this.transactions,
  });

  @override
  List<Object?> get props => [day, net, expense, transactions];
}

List<DayAccountBook> daysOf(Iterable<TransactionModel> transactions) {
  final items = <DateTime, List<TransactionModel>>{};
  final nets = <DateTime, double>{};
  final expenses = <DateTime, double>{};
  for (final transaction in transactions) {
    final day = DateTime(
      transaction.date.year,
      transaction.date.month,
      transaction.date.day,
    );
    (items[day] ??= []).add(transaction);
    if (transaction.type == TransactionType.expense) {
      expenses[day] = (expenses[day] ?? 0) + transaction.amount;
    }
    final delta = switch (transaction.type) {
      TransactionType.income => transaction.amount,
      TransactionType.expense => -transaction.amount,
      TransactionType.transfer => 0.0,
    };
    if (delta == 0) {
      continue;
    }
    nets[day] = (nets[day] ?? 0) + delta;
  }
  return [
    for (final entry in items.entries)
      DayAccountBook(
        day: entry.key,
        net: nets[entry.key] ?? 0,
        expense: expenses[entry.key] ?? 0,
        transactions: entry.value,
      ),
  ];
}

double netOn(List<DayAccountBook> days, DateTime day) {
  final key = DateTime(day.year, day.month, day.day);
  for (final item in days) {
    if (item.day == key) {
      return item.net;
    }
  }
  return 0;
}
