import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/repositories/transaction_repository.dart';

class MemoryTransactionRepository implements TransactionRepository {
  final List<TransactionModel> transactions = [];
  final Set<String> usedCategories = {};

  @override
  Future<int> countForCategory(String categoryId) async {
    return usedCategories.contains(categoryId) ? 1 : 0;
  }

  @override
  Future<void> delete(String id) async {
    transactions.removeWhere((item) => item.id == id);
  }

  @override
  Future<List<TransactionModel>> getAll() async => [...transactions];

  @override
  Future<void> save(TransactionModel transaction) async {
    transactions.removeWhere((item) => item.id == transaction.id);
    transactions.add(transaction);
  }
}
