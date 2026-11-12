import 'package:equatable/equatable.dart';
import 'package:money_manager/models/account_model.dart';

sealed class AccountsEvent extends Equatable {
  const AccountsEvent();

  @override
  List<Object?> get props => [];
}

class AccountsInitialized extends AccountsEvent {
  const AccountsInitialized();
}

class AccountSavePressed extends AccountsEvent {
  final AccountModel account;

  const AccountSavePressed(this.account);

  @override
  List<Object?> get props => [account];
}

class AccountArchivePressed extends AccountsEvent {
  final AccountModel account;
  final double balance;

  const AccountArchivePressed(this.account, {required this.balance});

  @override
  List<Object?> get props => [account, balance];
}

class AccountsReorderPressed extends AccountsEvent {
  final List<int> ids;

  const AccountsReorderPressed(this.ids);

  @override
  List<Object?> get props => [ids];
}
