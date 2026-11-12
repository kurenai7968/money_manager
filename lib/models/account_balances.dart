import 'package:money_manager/models/account_model.dart';

class AccountBalances {
  final List<AccountModel> accounts;
  final Map<int, double> balanceById;
  final double netWorth;

  const AccountBalances({
    required this.accounts,
    required this.balanceById,
    required this.netWorth,
  });
}
