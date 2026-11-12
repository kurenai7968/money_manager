import 'package:equatable/equatable.dart';
import 'package:money_manager/models/account_book_kinds.dart';

sealed class AccountFormEvent extends Equatable {
  const AccountFormEvent();

  @override
  List<Object?> get props => [];
}

class AccountFormInitialized extends AccountFormEvent {
  final int? accountId;
  final String languageCode;
  final String locale;

  const AccountFormInitialized({
    required this.languageCode,
    required this.locale,
    this.accountId,
  });

  @override
  List<Object?> get props => [accountId, languageCode, locale];
}

class AccountFormTypeSelected extends AccountFormEvent {
  final AccountType type;

  const AccountFormTypeSelected(this.type);

  @override
  List<Object?> get props => [type];
}

class AccountFormIconSelected extends AccountFormEvent {
  final String icon;

  const AccountFormIconSelected(this.icon);

  @override
  List<Object?> get props => [icon];
}

class AccountFormSavePressed extends AccountFormEvent {
  final String name;
  final String languageCode;

  const AccountFormSavePressed({
    required this.name,
    required this.languageCode,
  });

  @override
  List<Object?> get props => [name, languageCode];
}

class AccountFormArchivePressed extends AccountFormEvent {
  const AccountFormArchivePressed();
}
