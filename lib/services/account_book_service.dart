import 'package:money_manager/models/account_book_model.dart';
import 'package:money_manager/models/account_defaults.dart';
import 'package:money_manager/models/category_defaults.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/repositories/account_repository.dart';
import 'package:money_manager/repositories/category_repository.dart';
import 'package:money_manager/repositories/transaction_repository.dart';

abstract interface class AccountBookService {
  Future<List<AccountBookModel>> loadAccounts();

  Future<List<CategoryModel>> loadCategories();

  Future<int> saveTransaction(TransactionModel transaction);

  Future<void> deleteTransaction(int id);
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
    final balances = await _accounts.balances();
    final transactions = await _transactions.getAll();
    return [
      for (final account in balances.accounts)
        AccountBookModel(
          account: account,
          balance: _balanceOf(balances.balanceById, account.id),
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

  double _balanceOf(Map<int, double> balanceById, int? id) {
    if (id == null) {
      return 0;
    }
    return balanceById[id] ?? 0;
  }

  @override
  Future<int> saveTransaction(TransactionModel transaction) {
    return _transactions.save(transaction);
  }

  @override
  Future<void> deleteTransaction(int id) {
    return _transactions.delete(id);
  }
}
