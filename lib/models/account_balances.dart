import 'package:money_manager/models/account_model.dart';

class AccountBalances {
  final List<AccountModel> accounts;
  final Map<String, int> balanceById;
  final int netWorth;

  const AccountBalances({
    required this.accounts,
    required this.balanceById,
    required this.netWorth,
  });
}
