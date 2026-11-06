import 'package:equatable/equatable.dart';
import 'package:money_manager/models/account_model.dart';

sealed class AccountsEvent extends Equatable {
  const AccountsEvent();

  @override
  List<Object?> get props => [];
}

class AccountsStarted extends AccountsEvent {
  const AccountsStarted();
}

class AccountSavePressed extends AccountsEvent {
  final AccountModel account;

  const AccountSavePressed(this.account);

  @override
  List<Object?> get props => [account];
}

class AccountArchivePressed extends AccountsEvent {
  final AccountModel account;
  final int balanceMinor;

  const AccountArchivePressed(this.account, {required this.balanceMinor});

  @override
  List<Object?> get props => [account, balanceMinor];
}

class AccountsReorderPressed extends AccountsEvent {
  final List<String> ids;

  const AccountsReorderPressed(this.ids);

  @override
  List<Object?> get props => [ids];
}
