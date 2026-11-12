import 'package:equatable/equatable.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/transaction_model.dart';

enum AccountDetailStatus { initial, success, failure }

class AccountDetailState extends Equatable {
  final AccountDetailStatus status;
  final AccountModel? account;
  final double balance;
  final List<TransactionModel> history;
  final List<CategoryModel> categories;
  final List<AccountModel> accounts;

  const AccountDetailState({
    this.status = AccountDetailStatus.initial,
    this.account,
    this.balance = 0,
    this.history = const [],
    this.categories = const [],
    this.accounts = const [],
  });

  AccountDetailState copyWith({
    AccountDetailStatus? status,
    AccountModel? account,
    bool clearAccount = false,
    double? balance,
    List<TransactionModel>? history,
    List<CategoryModel>? categories,
    List<AccountModel>? accounts,
  }) {
    return AccountDetailState(
      status: status ?? this.status,
      account: clearAccount ? null : account ?? this.account,
      balance: balance ?? this.balance,
      history: history ?? this.history,
      categories: categories ?? this.categories,
      accounts: accounts ?? this.accounts,
    );
  }

  @override
  List<Object?> get props => [
    status,
    account,
    balance,
    history,
    categories,
    accounts,
  ];
}
