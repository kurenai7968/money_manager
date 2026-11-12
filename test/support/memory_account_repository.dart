import 'package:money_manager/models/account_balances.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/repositories/account_repository.dart';

class MemoryAccountRepository implements AccountRepository {
  final List<AccountModel> accounts = [];
  final Map<int, double> balanceById = {};
  var _nextId = 1;

  @override
  Future<void> archive(int id) async {
    final index = accounts.indexWhere((account) => account.id == id);
    accounts[index] = accounts[index].copyWith(isActive: false);
  }

  @override
  Future<bool> isEmpty() async => accounts.isEmpty;

  @override
  Future<List<AccountModel>> getAll() async {
    final copy = [...accounts];
    copy.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return copy;
  }

  @override
  Future<AccountBalances> balances() async {
    final loaded = await getAll();
    final balances = {
      for (final account in loaded)
        if (account.id != null) account.id!: balanceById[account.id] ?? 0,
    };
    var netWorth = 0.0;
    for (final account in loaded) {
      if (!account.isActive) {
        continue;
      }
      final id = account.id;
      if (id == null) {
        continue;
      }
      final balance = balances[id]!;
      netWorth += account.type == AccountType.credit ? -balance : balance;
    }
    return AccountBalances(
      accounts: loaded,
      balanceById: balances,
      netWorth: netWorth,
    );
  }

  @override
  Future<void> reorder(List<int> ids) async {
    for (var index = 0; index < ids.length; index++) {
      final accountIndex = accounts.indexWhere(
        (account) => account.id == ids[index],
      );
      accounts[accountIndex] = accounts[accountIndex].copyWith(
        sortOrder: index,
      );
    }
  }

  @override
  Future<int> save(AccountModel account) async {
    final id = account.id ?? _nextId++;
    if (id >= _nextId) {
      _nextId = id + 1;
    }
    final saved = account.copyWith(id: id);
    accounts.removeWhere((item) => item.id == id);
    accounts.add(saved);
    return id;
  }
}
