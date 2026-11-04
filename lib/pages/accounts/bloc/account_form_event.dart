import 'package:equatable/equatable.dart';
import 'package:money_manager/models/ledger_kinds.dart';

sealed class AccountFormEvent extends Equatable {
  const AccountFormEvent();

  @override
  List<Object?> get props => [];
}

class AccountFormStarted extends AccountFormEvent {
  const AccountFormStarted({
    required this.languageCode,
    required this.locale,
    this.accountId,
  });

  final String? accountId;
  final String languageCode;
  final String locale;

  @override
  List<Object?> get props => [accountId, languageCode, locale];
}

class AccountFormTypeSelected extends AccountFormEvent {
  const AccountFormTypeSelected(this.type);

  final AccountType type;

  @override
  List<Object?> get props => [type];
}

class AccountFormSavePressed extends AccountFormEvent {
  const AccountFormSavePressed({
    required this.name,
    required this.balanceText,
    required this.languageCode,
  });

  final String name;
  final String balanceText;
  final String languageCode;

  @override
  List<Object?> get props => [name, balanceText, languageCode];
}

class AccountFormArchivePressed extends AccountFormEvent {
  const AccountFormArchivePressed();
}

class AccountFormSourcesChanged extends AccountFormEvent {
  const AccountFormSourcesChanged();
}
