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
  const AccountSavePressed(this.account);

  final AccountModel account;

  @override
  List<Object?> get props => [account];
}

class AccountArchivePressed extends AccountsEvent {
  const AccountArchivePressed(this.account);

  final AccountModel account;

  @override
  List<Object?> get props => [account];
}

class AccountsReorderPressed extends AccountsEvent {
  const AccountsReorderPressed(this.ids);

  final List<String> ids;

  @override
  List<Object?> get props => [ids];
}
