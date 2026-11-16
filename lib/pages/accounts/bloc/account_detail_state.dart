import 'package:equatable/equatable.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/day_ledger.dart';
import 'package:money_manager/models/transaction_model.dart';

enum AccountDetailStatus { initial, loading, success, failure }

class AccountDetailState extends Equatable {
  final AccountDetailStatus status;
  final AccountModel? account;
  final double balance;
  final List<TransactionModel> history;
  final List<DayLedger> days;
  final List<CategoryModel> categories;
  final List<AccountModel> accounts;

  const AccountDetailState({
    this.status = AccountDetailStatus.initial,
    this.account,
    this.balance = 0,
    this.history = const [],
    this.days = const [],
    this.categories = const [],
    this.accounts = const [],
  });

  AccountDetailState copyWith({
    AccountDetailStatus? status,
    AccountModel? account,
    bool clearAccount = false,
    double? balance,
    List<TransactionModel>? history,
    List<DayLedger>? days,
    List<CategoryModel>? categories,
    List<AccountModel>? accounts,
  }) {
    return AccountDetailState(
      status: status ?? this.status,
      account: clearAccount ? null : account ?? this.account,
      balance: balance ?? this.balance,
      history: history ?? this.history,
      days: days ?? this.days,
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
    days,
    categories,
    accounts,
  ];
}
