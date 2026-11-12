import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/models/account_book_model.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/home/bloc/home_event.dart';
import 'package:money_manager/pages/home/bloc/home_state.dart';
import 'package:money_manager/pages/home/models/home_figures.dart';
import 'package:money_manager/services/account_book_service.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AccountBookService _accountBookService;
  var _failed = false;
  List<AccountModel> _accountRows = const [];
  List<TransactionModel> _transactionRows = const [];
  List<CategoryModel> _categoryRows = const [];

  HomeBloc({required this._accountBookService}) : super(HomeState.initial()) {
    on<HomeInitialized>(_onInitialized);
    on<HomeMonthShifted>(_onMonthShifted);
    on<HomeViewToggled>(_onViewToggled);
    on<HomeDaySelected>(_onDaySelected);
    on<HomeAccountSelected>(_onAccountSelected);
  }

  Future<void> _onInitialized(
    HomeInitialized event,
    Emitter<HomeState> emit,
  ) async {
    await _load();
    _publish(emit, state);
  }

  Future<void> _load() async {
    try {
      final loaded = await _accountBookService.loadAccounts();
      _accountRows = [for (final book in loaded) book.account];
      _transactionRows = transactionsOnce(loaded);
      _categoryRows = await _accountBookService.loadCategories();
      _failed = false;
    } catch (_) {
      _failed = true;
    }
  }

  void _onMonthShifted(HomeMonthShifted event, Emitter<HomeState> emit) {
    final month = DateTime(state.month.year, state.month.month + event.delta);
    final today = DateTime.now();
    final selected = today.year == month.year && today.month == month.month
        ? DateTime(today.year, today.month, today.day)
        : null;
    _publish(
      emit,
      state.copyWith(
        month: month,
        selectedDay: selected,
        clearSelectedDay: selected == null,
      ),
    );
  }

  void _onViewToggled(HomeViewToggled event, Emitter<HomeState> emit) {
    emit(
      state.copyWith(
        view: state.view == HomeView.summary
            ? HomeView.calendar
            : HomeView.summary,
      ),
    );
  }

  void _onDaySelected(HomeDaySelected event, Emitter<HomeState> emit) {
    final day = DateTime(event.day.year, event.day.month, event.day.day);
    _publish(emit, state.copyWith(selectedDay: day));
  }

  void _onAccountSelected(HomeAccountSelected event, Emitter<HomeState> emit) {
    _publish(
      emit,
      state.copyWith(
        selectedAccountId: event.accountId,
        clearSelectedAccount: event.accountId == null,
      ),
    );
  }

  void _publish(Emitter<HomeState> emit, HomeState base) {
    final month = base.month;
    final inMonth = [
      for (final item in _transactionRows)
        if (item.date.year == month.year && item.date.month == month.month)
          item,
    ];
    final accountId = _activeAccountId(base.selectedAccountId);
    final transactions = _forAccount(inMonth, accountId);
    final days = daysOf(transactions);
    emit(
      base.copyWith(
        status: _failed ? HomeStatus.failure : HomeStatus.success,
        selectedAccountId: accountId,
        clearSelectedAccount: accountId == null,
        transactions: transactions,
        figures: monthFigures(transactions, month),
        days: days,
        selectedTransactions: transactionsOn(days, base.selectedDay),
        categories: _categoryRows,
        accounts: _accountRows,
      ),
    );
  }

  int? _activeAccountId(int? accountId) {
    if (accountId == null) {
      return null;
    }
    for (final account in _accountRows) {
      if (account.id == accountId && account.isActive) {
        return accountId;
      }
    }
    return null;
  }
}

List<TransactionModel> _forAccount(
  List<TransactionModel> transactions,
  int? accountId,
) {
  if (accountId == null) {
    return transactions;
  }
  return [
    for (final item in transactions)
      if (item.accountId == accountId ||
          item.fromAccountId == accountId ||
          item.toAccountId == accountId)
        item,
  ];
}
