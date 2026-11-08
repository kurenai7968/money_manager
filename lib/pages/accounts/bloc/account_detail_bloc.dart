import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/core/utils/ledger_balance.dart';
import 'package:money_manager/core/utils/ledger_commands.dart';
import 'package:money_manager/core/utils/queued_bloc.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/accounts/bloc/account_detail_event.dart';
import 'package:money_manager/pages/accounts/bloc/account_detail_state.dart';
import 'package:money_manager/repositories/account_repository.dart';
import 'package:money_manager/repositories/category_repository.dart';
import 'package:money_manager/repositories/transaction_repository.dart';

class AccountDetailBloc extends Bloc<AccountDetailEvent, AccountDetailState>
    with QueuedBloc<AccountDetailEvent, AccountDetailState> {
  final String accountId;
  final AccountRepository _accounts;
  final TransactionRepository _transactions;
  final CategoryRepository _categories;

  AccountDetailBloc({
    required this.accountId,
    required AccountRepository accounts,
    required TransactionRepository transactions,
    required CategoryRepository categories,
  }) : _accounts = accounts,
       _transactions = transactions,
       _categories = categories,
       super(const AccountDetailState()) {
    on<AccountDetailStarted>(_onStarted);
  }

  Future<void> _onStarted(
    AccountDetailStarted event,
    Emitter<AccountDetailState> emit,
  ) async {
    try {
      final loaded = await loadAccounts(_accounts, _transactions);
      final categories = await loadCategories(_categories);
      _publish(
        emit,
        accounts: loaded.accounts,
        transactions: loaded.transactions,
        categories: categories,
        failed: false,
      );
    } catch (_) {
      _publish(
        emit,
        accounts: const [],
        transactions: const [],
        categories: const [],
        failed: true,
      );
    }
  }

  void _publish(
    Emitter<AccountDetailState> emit, {
    required List<AccountModel> accounts,
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
        balanceMinor: balanceOf(account, history),
        history: history,
        categories: categories,
        accounts: accounts,
      ),
    );
  }
}
