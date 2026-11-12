import 'package:equatable/equatable.dart';
import 'package:money_manager/models/account_model.dart';

class AccountLine extends Equatable {
  final AccountModel account;
  final double balance;

  const AccountLine({required this.account, required this.balance});

  @override
  List<Object?> get props => [account, balance];
}
