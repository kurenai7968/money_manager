import 'package:equatable/equatable.dart';
import 'package:money_manager/models/account_model.dart';

enum AccountsListStatus { initial, success, failure }

class AccountLine extends Equatable {
  const AccountLine({required this.account, required this.balanceMinor});

  final AccountModel account;
  final int balanceMinor;

  @override
  List<Object?> get props => [account, balanceMinor];
}

class AccountsListState extends Equatable {
  const AccountsListState({
    this.status = AccountsListStatus.initial,
    this.assets = const [],
    this.liabilities = const [],
    this.netWorth = 0,
  });

  final AccountsListStatus status;
  final List<AccountLine> assets;
  final List<AccountLine> liabilities;
  final int netWorth;

  AccountsListState copyWith({
    AccountsListStatus? status,
    List<AccountLine>? assets,
    List<AccountLine>? liabilities,
    int? netWorth,
  }) {
    return AccountsListState(
      status: status ?? this.status,
      assets: assets ?? this.assets,
      liabilities: liabilities ?? this.liabilities,
      netWorth: netWorth ?? this.netWorth,
    );
  }

  @override
  List<Object?> get props => [status, assets, liabilities, netWorth];
}
