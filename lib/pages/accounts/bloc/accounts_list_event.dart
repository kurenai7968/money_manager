import 'package:equatable/equatable.dart';

sealed class AccountsListEvent extends Equatable {
  const AccountsListEvent();

  @override
  List<Object?> get props => [];
}

class AccountsListStarted extends AccountsListEvent {
  const AccountsListStarted();
}

class AccountsListSourcesChanged extends AccountsListEvent {
  const AccountsListSourcesChanged();
}
