import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';

int balanceOf(AccountModel account, Iterable<TransactionModel> transactions) {
  var balance = account.openingBalanceMinor;
  for (final transaction in transactions) {
    final delta = switch (transaction.type) {
      TransactionType.expense when transaction.accountId == account.id =>
        -transaction.amountMinor,
      TransactionType.income when transaction.accountId == account.id =>
        transaction.amountMinor,
      TransactionType.transfer when transaction.toAccountId == account.id =>
        transaction.amountMinor,
      TransactionType.transfer when transaction.fromAccountId == account.id =>
        -transaction.amountMinor,
      _ => 0,
    };
    balance += account.type == AccountType.credit ? -delta : delta;
  }
  return balance;
}

int netWorthOf(
  Iterable<AccountModel> accounts,
  Iterable<TransactionModel> transactions,
) {
  var total = 0;
  for (final account in accounts.where((item) => !item.archived)) {
    final balance = balanceOf(account, transactions);
    total += account.type == AccountType.credit ? -balance : balance;
  }
  return total;
}
