import 'package:equatable/equatable.dart';
import 'package:money_manager/models/account_model.dart';

enum AccountsStatus { initial, loading, success, failure }

enum AccountsError { none, saveFailed, archiveBlocked, nameRequired }

class AccountsState extends Equatable {
  const AccountsState({
    this.status = AccountsStatus.initial,
    this.accounts = const [],
    this.error = AccountsError.none,
  });

  final AccountsStatus status;
  final List<AccountModel> accounts;
  final AccountsError error;

  List<AccountModel> get active =>
      accounts.where((account) => !account.archived).toList();

  int get netWorth => netWorthMinor(active);

  AccountsState copyWith({
    AccountsStatus? status,
    List<AccountModel>? accounts,
    AccountsError? error,
  }) {
    return AccountsState(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, accounts, error];
}
