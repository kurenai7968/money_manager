import 'package:equatable/equatable.dart';

sealed class AccountDetailEvent extends Equatable {
  const AccountDetailEvent();

  @override
  List<Object?> get props => [];
}

class AccountDetailStarted extends AccountDetailEvent {
  const AccountDetailStarted();
}

class AccountDetailSourcesChanged extends AccountDetailEvent {
  const AccountDetailSourcesChanged();
}
