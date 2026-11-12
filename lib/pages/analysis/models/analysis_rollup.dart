import 'package:equatable/equatable.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';

class AnalysisTotal extends Equatable {
  final int? id;
  final double amount;
  final int? sharePercent;

  const AnalysisTotal({
    required this.id,
    required this.amount,
    this.sharePercent,
  });

  @override
  List<Object?> get props => [id, amount, sharePercent];
}

class AnalysisRollup extends Equatable {
  final List<DateTime> months;
  final List<double> monthValues;
  final List<AnalysisTotal> byCategory;
  final List<AnalysisTotal> byAccount;

  const AnalysisRollup({
    required this.months,
    required this.monthValues,
    required this.byCategory,
    required this.byAccount,
  });

  double get current => monthValues.last;

  double get previous => monthValues[monthValues.length - 2];

  double get delta => current - previous;

  double get maxValue {
    var max = 1.0;
    for (final value in monthValues) {
      if (value > max) {
        max = value;
      }
    }
    return max;
  }

  @override
  List<Object?> get props => [months, monthValues, byCategory, byAccount];
}

AnalysisRollup analysisRollup(
  List<TransactionModel> transactions,
  DateTime month,
  CategoryKind kind,
) {
  final months = [
    for (var offset = 5; offset >= 0; offset--)
      DateTime(month.year, month.month - offset),
  ];
  final income = List<double>.filled(months.length, 0);
  final expense = List<double>.filled(months.length, 0);
  final indexByMonth = <int, int>{
    for (var index = 0; index < months.length; index++)
      months[index].year * 12 + months[index].month: index,
  };
  final currentKey = month.year * 12 + month.month;
  final byCategory = <int?, double>{};
  final byAccount = <int?, double>{};
  final wantExpense = kind == CategoryKind.expense;
  for (final transaction in transactions) {
    final index =
        indexByMonth[transaction.date.year * 12 + transaction.date.month];
    if (index == null) {
      continue;
    }
    if (transaction.type == TransactionType.income) {
      income[index] += transaction.amount;
    } else if (transaction.type == TransactionType.expense) {
      expense[index] += transaction.amount;
    } else {
      continue;
    }
    final matches = wantExpense
        ? transaction.type == TransactionType.expense
        : transaction.type == TransactionType.income;
    if (!matches ||
        transaction.date.year * 12 + transaction.date.month != currentKey) {
      continue;
    }
    final categoryId = transaction.categoryId;
    final accountId = transaction.accountId;
    byCategory[categoryId] = (byCategory[categoryId] ?? 0) + transaction.amount;
    byAccount[accountId] = (byAccount[accountId] ?? 0) + transaction.amount;
  }
  final totals = wantExpense ? expense : income;
  final current = totals.last;
  return AnalysisRollup(
    months: months,
    monthValues: totals,
    byCategory: _totals(byCategory, current),
    byAccount: _totals(byAccount, null),
  );
}

List<AnalysisTotal> _totals(Map<int?, double> totals, double? current) {
  final entries = totals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return [
    for (final entry in entries)
      AnalysisTotal(
        id: entry.key,
        amount: entry.value,
        sharePercent: current == null || current == 0
            ? null
            : (entry.value * 100 / current).round(),
      ),
  ];
}
