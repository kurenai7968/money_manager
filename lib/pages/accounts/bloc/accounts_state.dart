import 'package:equatable/equatable.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/pages/accounts/models/account_line.dart';

enum AccountsStatus { initial, loading, success, failure }

enum AccountsError { none, saveFailed, archiveBlocked, nameRequired }

class AccountsState extends Equatable {
  final AccountsStatus status;
  final List<AccountModel> accounts;
  final Map<int, double> balances;
  final double netWorth;
  final AccountsError error;

  const AccountsState({
    this.status = AccountsStatus.initial,
    this.accounts = const [],
    this.balances = const {},
    this.netWorth = 0,
    this.error = AccountsError.none,
  });

  List<AccountModel> get active =>
      accounts.where((account) => account.isActive).toList();

  List<AccountLine> get assets => _lines(credit: false);

  List<AccountLine> get liabilities => _lines(credit: true);

  List<AccountLine> _lines({required bool credit}) {
    return [
      for (final account in active)
        if ((account.type == AccountType.credit) == credit)
          AccountLine(account: account, balance: _balance(account)),
    ];
  }

  double _balance(AccountModel account) {
    final id = account.id;
    if (id == null) {
      return 0;
    }
    return balances[id] ?? 0;
  }

  AccountsState copyWith({
    AccountsStatus? status,
    List<AccountModel>? accounts,
    Map<int, double>? balances,
    double? netWorth,
    AccountsError? error,
  }) {
    return AccountsState(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      balances: balances ?? this.balances,
      netWorth: netWorth ?? this.netWorth,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, accounts, balances, netWorth, error];
}
