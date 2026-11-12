import 'package:equatable/equatable.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';

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

class DayLedger extends Equatable {
  final DateTime day;
  final double net;
  final List<TransactionModel> transactions;

  const DayLedger({
    required this.day,
    required this.net,
    required this.transactions,
  });

  @override
  List<Object?> get props => [day, net, transactions];
}

List<DayLedger> daysOf(Iterable<TransactionModel> transactions) {
  final items = <DateTime, List<TransactionModel>>{};
  final nets = <DateTime, double>{};
  for (final transaction in transactions) {
    final day = DateTime(
      transaction.date.year,
      transaction.date.month,
      transaction.date.day,
    );
    (items[day] ??= []).add(transaction);
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
      DayLedger(
        day: entry.key,
        net: nets[entry.key] ?? 0,
        transactions: entry.value,
      ),
  ];
}

double netOn(List<DayLedger> days, DateTime day) {
  final key = DateTime(day.year, day.month, day.day);
  for (final item in days) {
    if (item.day == key) {
      return item.net;
    }
  }
  return 0;
}

List<TransactionModel> transactionsOn(List<DayLedger> days, DateTime? day) {
  if (day == null) {
    return const [];
  }
  final key = DateTime(day.year, day.month, day.day);
  for (final item in days) {
    if (item.day == key) {
      return item.transactions;
    }
  }
  return const [];
}
