import 'package:money_manager/core/utils/id.dart';
import 'package:money_manager/core/utils/opening_transaction.dart';
import 'package:money_manager/models/account_defaults.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_defaults.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/repositories/account_repository.dart';
import 'package:money_manager/repositories/category_repository.dart';
import 'package:money_manager/repositories/transaction_repository.dart';

Future<({List<AccountModel> accounts, List<TransactionModel> transactions})>
loadAccounts(
  AccountRepository accounts,
  TransactionRepository transactions,
) async {
  if (await accounts.isEmpty()) {
    await accounts.save(defaultAccount());
  }
  final loaded = await accounts.getAll();
  await syncOpeningTransactions(transactions, loaded);
  return (
    accounts: await accounts.getAll(),
    transactions: await transactions.getAll(),
  );
}

Future<List<CategoryModel>> loadCategories(
  CategoryRepository categories,
) async {
  if (await categories.isEmpty()) {
    for (final category in defaultCategories()) {
      await categories.save(category);
    }
  }
  return categories.getAll();
}

Future<void> syncOpeningTransactions(
  TransactionRepository transactions,
  List<AccountModel> accounts,
) async {
  final existing = await transactions.getAll();
  for (final account in accounts) {
    final id = openingTransactionId(account.id);
    final prior = existing.where((item) => item.id == id).toList();
    if (account.openingBalanceMinor == 0) {
      for (final item in prior) {
        await transactions.delete(item.id);
      }
      continue;
    }
    final previous = prior.isEmpty ? null : prior.first;
    final type = account.openingBalanceMinor > 0
        ? TransactionType.income
        : TransactionType.expense;
    final sameType = previous != null && previous.type == type;
    await transactions.save(
      TransactionModel(
        id: id,
        type: type,
        amountMinor: account.openingBalanceMinor.abs(),
        date: previous?.date ?? DateTime.now(),
        note: previous?.note ?? '',
        accountId: account.id,
        categoryId: sameType ? previous?.categoryId : null,
      ),
    );
  }
}

Future<void> saveLedgerTransaction(
  TransactionRepository transactions,
  AccountRepository accounts,
  TransactionModel transaction,
) async {
  final openingAccountId = accountIdFromOpeningTransaction(transaction.id);
  if (openingAccountId != null && isOpeningBalanceTransaction(transaction)) {
    final signed = transaction.type == TransactionType.income
        ? transaction.amountMinor
        : -transaction.amountMinor;
    await _writeOpeningBalance(accounts, openingAccountId, signed);
    await transactions.save(transaction);
    return;
  }
  if (openingAccountId != null) {
    await _writeOpeningBalance(accounts, openingAccountId, 0);
    await transactions.save(transaction.copyWith(id: createId()));
    await transactions.delete(transaction.id);
    return;
  }
  await transactions.save(transaction);
}

Future<void> deleteLedgerTransaction(
  TransactionRepository transactions,
  AccountRepository accounts,
  String id,
) async {
  final openingAccountId = accountIdFromOpeningTransaction(id);
  if (openingAccountId != null) {
    await _writeOpeningBalance(accounts, openingAccountId, 0);
  }
  await transactions.delete(id);
}

Future<void> _writeOpeningBalance(
  AccountRepository accounts,
  String accountId,
  int openingBalanceMinor,
) async {
  final loaded = await accounts.getAll();
  final matches = loaded.where((account) => account.id == accountId);
  if (matches.isEmpty) {
    return;
  }
  final account = matches.first;
  if (account.openingBalanceMinor == openingBalanceMinor) {
    return;
  }
  await accounts.save(
    account.copyWith(openingBalanceMinor: openingBalanceMinor),
  );
}
