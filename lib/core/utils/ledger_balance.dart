import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';

Map<String, int> balancesOf(
  Iterable<AccountModel> accounts,
  Iterable<TransactionModel> transactions,
) {
  final byId = <String, AccountModel>{};
  final balances = <String, int>{};
  for (final account in accounts) {
    byId[account.id] = account;
    balances[account.id] = account.openingBalanceMinor;
  }
  for (final transaction in transactions) {
    switch (transaction.type) {
      case TransactionType.expense:
        _apply(byId, balances, transaction.accountId, -transaction.amountMinor);
      case TransactionType.income:
        _apply(byId, balances, transaction.accountId, transaction.amountMinor);
      case TransactionType.transfer:
        _apply(
          byId,
          balances,
          transaction.toAccountId,
          transaction.amountMinor,
        );
        _apply(
          byId,
          balances,
          transaction.fromAccountId,
          -transaction.amountMinor,
        );
      case TransactionType.opening:
        break;
    }
  }
  return balances;
}

int balanceOf(AccountModel account, Iterable<TransactionModel> transactions) {
  return balancesOf([account], transactions)[account.id]!;
}

int netWorthOf(
  Iterable<AccountModel> accounts,
  Iterable<TransactionModel> transactions,
) {
  final active = [
    for (final account in accounts)
      if (!account.archived) account,
  ];
  final balances = balancesOf(active, transactions);
  var total = 0;
  for (final account in active) {
    final balance = balances[account.id]!;
    total += account.type == AccountType.credit ? -balance : balance;
  }
  return total;
}

void _apply(
  Map<String, AccountModel> byId,
  Map<String, int> balances,
  String? accountId,
  int signed,
) {
  if (accountId == null) {
    return;
  }
  final account = byId[accountId];
  if (account == null) {
    return;
  }
  final delta = account.type == AccountType.credit ? -signed : signed;
  balances[accountId] = balances[accountId]! + delta;
}

class MonthFigures {
  const MonthFigures({required this.incomeMinor, required this.expenseMinor});

  final int incomeMinor;
  final int expenseMinor;

  int get balanceMinor => incomeMinor - expenseMinor;
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

bool sameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
