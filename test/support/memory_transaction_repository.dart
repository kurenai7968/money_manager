import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/repositories/transaction_repository.dart';

class MemoryTransactionRepository implements TransactionRepository {
  final List<TransactionModel> transactions = [];
  final Set<int> usedCategories = {};
  var _nextId = 1;

  @override
  Future<int> countForCategory(int categoryId) async {
    return usedCategories.contains(categoryId) ? 1 : 0;
  }

  @override
  Future<void> delete(int id) async {
    transactions.removeWhere((item) => item.id == id);
  }

  @override
  Future<List<TransactionModel>> getAll() async => [...transactions];

  @override
  Future<int> save(TransactionModel transaction) async {
    final id = transaction.id ?? _nextId++;
    if (id >= _nextId) {
      _nextId = id + 1;
    }
    final saved = transaction.copyWith(id: id);
    transactions.removeWhere((item) => item.id == id);
    transactions.add(saved);
    return id;
  }
}
