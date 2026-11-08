import 'package:equatable/equatable.dart';
import 'package:money_manager/pages/home/models/home_figures.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/transaction_model.dart';

enum HomeView { summary, calendar }

enum HomeStatus { initial, success, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final HomeView view;
  final DateTime month;
  final DateTime? selectedDay;
  final List<TransactionModel> transactions;
  final MonthFigures figures;
  final List<DayLedger> days;
  final List<TransactionModel> selectedTransactions;
  final List<CategoryModel> categories;
  final List<AccountModel> accounts;
  final String? selectedAccountId;

  const HomeState({
    required this.month,
    required this.selectedDay,
    this.status = HomeStatus.initial,
    this.view = HomeView.summary,
    this.transactions = const [],
    this.figures = const MonthFigures(incomeMinor: 0, expenseMinor: 0),
    this.days = const [],
    this.selectedTransactions = const [],
    this.categories = const [],
    this.accounts = const [],
    this.selectedAccountId,
  });

  HomeState copyWith({
    HomeStatus? status,
    HomeView? view,
    DateTime? month,
    DateTime? selectedDay,
    bool clearSelectedDay = false,
    List<TransactionModel>? transactions,
    MonthFigures? figures,
    List<DayLedger>? days,
    List<TransactionModel>? selectedTransactions,
    List<CategoryModel>? categories,
    List<AccountModel>? accounts,
    String? selectedAccountId,
    bool clearSelectedAccount = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      view: view ?? this.view,
      month: month ?? this.month,
      selectedDay: clearSelectedDay ? null : selectedDay ?? this.selectedDay,
      transactions: transactions ?? this.transactions,
      figures: figures ?? this.figures,
      days: days ?? this.days,
      selectedTransactions: selectedTransactions ?? this.selectedTransactions,
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
    figures,
    days,
    selectedTransactions,
    categories,
    accounts,
    selectedAccountId,
  ];
}
