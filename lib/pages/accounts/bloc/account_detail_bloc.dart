import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/services/account_book_service.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/accounts/bloc/account_detail_event.dart';
import 'package:money_manager/pages/accounts/bloc/account_detail_state.dart';

class AccountDetailBloc extends Bloc<AccountDetailEvent, AccountDetailState> {
  final String accountId;
  final AccountBookService _accountBook;

  AccountDetailBloc({
    required this.accountId,
    required AccountBookService accountBook,
  }) : _accountBook = accountBook,
       super(const AccountDetailState()) {
    on<AccountDetailInitialized>(_onInitialized);
  }

  Future<void> _onInitialized(
    AccountDetailInitialized event,
    Emitter<AccountDetailState> emit,
  ) async {
    try {
      final loaded = await _accountBook.loadAccounts();
      final categories = await _accountBook.loadCategories();
      _publish(
        emit,
        accounts: loaded.accounts,
        balances: loaded.balances,
        transactions: loaded.transactions,
        categories: categories,
        failed: false,
      );
    } catch (_) {
      _publish(
        emit,
        accounts: const [],
        balances: const {},
        transactions: const [],
        categories: const [],
        failed: true,
      );
    }
  }

  void _publish(
    Emitter<AccountDetailState> emit, {
    required List<AccountModel> accounts,
    required Map<String, int> balances,
    required List<TransactionModel> transactions,
    required List<CategoryModel> categories,
    required bool failed,
  }) {
    AccountModel? account;
    for (final item in accounts) {
      if (item.id == accountId) {
        account = item;
        break;
      }
    }
    final status = failed
        ? AccountDetailStatus.failure
        : AccountDetailStatus.success;
    if (account == null) {
      emit(
        AccountDetailState(
          status: status,
          categories: categories,
          accounts: accounts,
        ),
      );
      return;
    }
    final history = [
      for (final item in transactions)
        if (item.accountId == account.id ||
            item.fromAccountId == account.id ||
            item.toAccountId == account.id)
          item,
    ];
    emit(
      AccountDetailState(
        status: status,
        account: account,
        balanceMinor: balances[account.id] ?? account.openingBalanceMinor,
        history: history,
        categories: categories,
        accounts: accounts,
      ),
    );
  }
}
