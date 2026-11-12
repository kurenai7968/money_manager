import 'package:equatable/equatable.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';

class AccountBookModel extends Equatable {
  final AccountModel account;
  final double balance;
  final List<TransactionModel> transactions;

  const AccountBookModel({
    required this.account,
    required this.balance,
    required this.transactions,
  });

  AccountBookModel copyWith({
    AccountModel? account,
    double? balance,
    List<TransactionModel>? transactions,
  }) {
    return AccountBookModel(
      account: account ?? this.account,
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
    );
  }

  @override
  List<Object?> get props => [account, balance, transactions];
}

double accountBookNetWorth(Iterable<AccountBookModel> books) {
  var total = 0.0;
  for (final book in books) {
    if (!book.account.isActive) {
      continue;
    }
    final balance = book.balance;
    total += book.account.type == AccountType.credit ? -balance : balance;
  }
  return total;
}

List<TransactionModel> transactionsOnce(Iterable<AccountBookModel> books) {
  final seen = <int>{};
  final transactions = <TransactionModel>[];
  for (final book in books) {
    for (final transaction in book.transactions) {
      final id = transaction.id;
      if (id != null && !seen.add(id)) {
        continue;
      }
      transactions.add(transaction);
    }
  }
  transactions.sort((a, b) {
    final byDate = b.date.compareTo(a.date);
    if (byDate != 0) {
      return byDate;
    }
    return (b.id ?? 0).compareTo(a.id ?? 0);
  });
  return transactions;
}
