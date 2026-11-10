import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';

const openingTransactionPrefix = 'opening-';

String openingTransactionId(String accountId) =>
    '$openingTransactionPrefix$accountId';

String? accountIdFromOpeningTransaction(String transactionId) {
  if (!transactionId.startsWith(openingTransactionPrefix)) {
    return null;
  }
  final accountId = transactionId.substring(openingTransactionPrefix.length);
  if (accountId.isEmpty) {
    return null;
  }
  return accountId;
}

bool isOpeningBalanceTransaction(TransactionModel transaction) {
  final accountId = transaction.accountId;
  if (accountId == null) {
    return false;
  }
  if (transaction.id != openingTransactionId(accountId)) {
    return false;
  }
  return transaction.type == TransactionType.income ||
      transaction.type == TransactionType.expense;
}
