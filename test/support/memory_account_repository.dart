import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/repositories/account_repository.dart';

class MemoryAccountRepository implements AccountRepository {
  final List<AccountModel> accounts = [];
  final Map<String, int> balanceById = {};

  @override
  Future<void> archive(String id) async {
    final index = accounts.indexWhere((account) => account.id == id);
    accounts[index] = accounts[index].copyWith(archived: true);
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
        account.id: balanceById[account.id] ?? account.openingBalanceMinor,
    };
    var netWorth = 0;
    for (final account in loaded) {
      if (account.archived) {
        continue;
      }
      final balance = balances[account.id]!;
      netWorth += account.type == AccountType.credit ? -balance : balance;
    }
    return AccountBalances(
      accounts: loaded,
      balanceById: balances,
      netWorth: netWorth,
    );
  }

  @override
  Future<void> reorder(List<String> ids) async {
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
  Future<void> save(AccountModel account) async {
    accounts.removeWhere((item) => item.id == account.id);
    accounts.add(account);
  }
}
