import 'package:money_manager/core/utils/id.dart';
import 'package:money_manager/core/utils/opening_transaction.dart';
import 'package:money_manager/models/account_book_model.dart';
import 'package:money_manager/models/account_defaults.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_defaults.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/repositories/account_repository.dart';
import 'package:money_manager/repositories/category_repository.dart';
import 'package:money_manager/repositories/transaction_repository.dart';

abstract interface class AccountBookService {
  Future<List<AccountBookModel>> loadAccounts();

  Future<List<CategoryModel>> loadCategories();

  Future<void> syncOpeningTransactions(List<AccountModel> accounts);

  Future<void> saveTransaction(TransactionModel transaction);

  Future<void> deleteTransaction(String id);
}

class AccountBookServiceImpl implements AccountBookService {
  final AccountRepository _accounts;
  final CategoryRepository _categories;
  final TransactionRepository _transactions;

  AccountBookServiceImpl({
    required this._accounts,
    required this._categories,
    required this._transactions,
  });

  @override
  Future<List<AccountBookModel>> loadAccounts() async {
    if (await _accounts.isEmpty()) {
      await _accounts.save(defaultAccount());
    }
    final loaded = await _accounts.getAll();
    await syncOpeningTransactions(loaded);
    final balances = await _accounts.balances();
    final transactions = await _transactions.getAll();
    return [
      for (final account in balances.accounts)
        AccountBookModel(
          account: account,
          balance:
              balances.balanceById[account.id] ?? account.openingBalanceMinor,
          transactions: [
            for (final item in transactions)
              if (item.accountId == account.id ||
                  item.fromAccountId == account.id ||
                  item.toAccountId == account.id)
                item,
          ],
        ),
    ];
  }

  @override
  Future<List<CategoryModel>> loadCategories() async {
    if (await _categories.isEmpty()) {
      for (final category in defaultCategories()) {
        await _categories.save(category);
      }
    }
    return _categories.getAll();
  }

  @override
  Future<void> syncOpeningTransactions(List<AccountModel> accounts) async {
    final existing = await _transactions.getAll();
    for (final account in accounts) {
      final id = openingTransactionId(account.id);
      final prior = existing.where((item) => item.id == id).toList();
      if (account.openingBalanceMinor == 0) {
        for (final item in prior) {
          await _transactions.delete(item.id);
        }
        continue;
      }
      final previous = prior.isEmpty ? null : prior.first;
      final type = account.openingBalanceMinor > 0
          ? TransactionType.income
          : TransactionType.expense;
      final sameType = previous != null && previous.type == type;
      await _transactions.save(
        TransactionModel(
          id: id,
          type: type,
          amountMinor: account.openingBalanceMinor.abs(),
          date: previous?.date ?? DateTime.now(),
          note: previous?.note ?? '',
          accountId: account.id,
          categoryId: sameType ? previous.categoryId : null,
        ),
      );
    }
  }

  @override
  Future<void> saveTransaction(TransactionModel transaction) async {
    final openingAccountId = accountIdFromOpeningTransaction(transaction.id);
    if (openingAccountId != null && isOpeningBalanceTransaction(transaction)) {
      final signed = transaction.type == TransactionType.income
          ? transaction.amountMinor
          : -transaction.amountMinor;
      await _writeOpeningBalance(openingAccountId, signed);
      await _transactions.save(transaction);
      return;
    }
    if (openingAccountId != null) {
      await _writeOpeningBalance(openingAccountId, 0);
      await _transactions.save(transaction.copyWith(id: createId()));
      await _transactions.delete(transaction.id);
      return;
    }
    await _transactions.save(transaction);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final openingAccountId = accountIdFromOpeningTransaction(id);
    if (openingAccountId != null) {
      await _writeOpeningBalance(openingAccountId, 0);
    }
    await _transactions.delete(id);
  }

  Future<void> _writeOpeningBalance(
    String accountId,
    int openingBalanceMinor,
  ) async {
    final loaded = await _accounts.getAll();
    final matches = loaded.where((account) => account.id == accountId);
    if (matches.isEmpty) {
      return;
    }
    final account = matches.first;
    if (account.openingBalanceMinor == openingBalanceMinor) {
      return;
    }
    await _accounts.save(
      account.copyWith(openingBalanceMinor: openingBalanceMinor),
    );
  }
}
