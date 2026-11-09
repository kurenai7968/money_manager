import 'package:equatable/equatable.dart';

sealed class AccountDetailEvent extends Equatable {
  const AccountDetailEvent();

  @override
  List<Object?> get props => [];
}

class AccountDetailInitialized extends AccountDetailEvent {
  const AccountDetailInitialized();
}
