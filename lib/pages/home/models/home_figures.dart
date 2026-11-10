import 'package:equatable/equatable.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';

class MonthFigures extends Equatable {
  final int incomeMinor;
  final int expenseMinor;

  const MonthFigures({required this.incomeMinor, required this.expenseMinor});

  int get balanceMinor => incomeMinor - expenseMinor;

  @override
  List<Object?> get props => [incomeMinor, expenseMinor];
}

MonthFigures monthFigures(
  Iterable<TransactionModel> transactions,
  DateTime month,
) {
  var income = 0;
  var expense = 0;
  for (final transaction in transactions) {
    if (transaction.date.year != month.year ||
        transaction.date.month != month.month) {
      continue;
    }
    if (transaction.type == TransactionType.income) {
      income += transaction.amountMinor;
    } else if (transaction.type == TransactionType.expense) {
      expense += transaction.amountMinor;
    }
  }
  return MonthFigures(incomeMinor: income, expenseMinor: expense);
}

class DayLedger extends Equatable {
  final DateTime day;
  final int netMinor;
  final List<TransactionModel> transactions;

  const DayLedger({
    required this.day,
    required this.netMinor,
    required this.transactions,
  });

  @override
  List<Object?> get props => [day, netMinor, transactions];
}

List<DayLedger> daysOf(Iterable<TransactionModel> transactions) {
  final items = <DateTime, List<TransactionModel>>{};
  final nets = <DateTime, int>{};
  for (final transaction in transactions) {
    final day = DateTime(
      transaction.date.year,
      transaction.date.month,
      transaction.date.day,
    );
    (items[day] ??= []).add(transaction);
    final delta = switch (transaction.type) {
      TransactionType.income => transaction.amountMinor,
      TransactionType.expense => -transaction.amountMinor,
      TransactionType.transfer => 0,
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
        netMinor: nets[entry.key] ?? 0,
        transactions: entry.value,
      ),
  ];
}

int netOn(List<DayLedger> days, DateTime day) {
  final key = DateTime(day.year, day.month, day.day);
  for (final item in days) {
    if (item.day == key) {
      return item.netMinor;
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
