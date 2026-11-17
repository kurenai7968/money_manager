import 'package:equatable/equatable.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/day_ledger.dart';
import 'package:money_manager/models/transaction_model.dart';

enum HomeView { summary, calendar }

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final HomeView view;
  final DateTime month;
  final DateTime? selectedDay;
  final List<TransactionModel> transactions;
  final double income;
  final double expense;
  final double balance;
  final List<DayLedger> days;
  final List<CategoryModel> categories;
  final List<AccountModel> accounts;
  final int? selectedAccountId;

  const HomeState({
    required this.month,
    required this.selectedDay,
    required this.status,
    required this.view,
    required this.transactions,
    required this.income,
    required this.expense,
    required this.days,
    required this.categories,
    required this.accounts,
    required this.selectedAccountId,
  }) : balance = income - expense;

  static HomeState initial() {
    final today = DateTime.now();

    return HomeState(
      month: DateTime(today.year, today.month),
      selectedDay: DateTime(today.year, today.month, today.day),
      status: HomeStatus.initial,
      view: HomeView.summary,
      transactions: const [],
      income: 0,
      expense: 0,
      days: const [],
      categories: const [],
      accounts: const [],
      selectedAccountId: null,
    );
  }

  HomeState copyWith({
    HomeStatus? status,
    HomeView? view,
    DateTime? month,
    DateTime? selectedDay,
    List<TransactionModel>? transactions,
    double? income,
    double? expense,
    List<DayLedger>? days,
    List<CategoryModel>? categories,
    List<AccountModel>? accounts,
    int? selectedAccountId,
    bool clearSelectedAccount = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      view: view ?? this.view,
      month: month ?? this.month,
      selectedDay: selectedDay ?? this.selectedDay,
      transactions: transactions ?? this.transactions,
      income: income ?? this.income,
      expense: expense ?? this.expense,
      days: days ?? this.days,
      categories: categories ?? this.categories,
      accounts: accounts ?? this.accounts,
      selectedAccountId: clearSelectedAccount
          ? null
          : selectedAccountId ?? this.selectedAccountId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    view,
    month,
    selectedDay,
    transactions,
    income,
    expense,
    balance,
    days,
    categories,
    accounts,
    selectedAccountId,
  ];
}
