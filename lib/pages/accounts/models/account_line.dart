import 'package:equatable/equatable.dart';
import 'package:money_manager/models/account_model.dart';

class AccountLine extends Equatable {
  final AccountModel account;
  final int balanceMinor;

  const AccountLine({required this.account, required this.balanceMinor});

  @override
  List<Object?> get props => [account, balanceMinor];
}
