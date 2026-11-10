import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/models/account_book_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/pages/accounts/bloc/account_detail_event.dart';
import 'package:money_manager/pages/accounts/bloc/account_detail_state.dart';
import 'package:money_manager/services/account_book_service.dart';

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
      _publish(emit, books: loaded, categories: categories, failed: false);
    } catch (_) {
      _publish(emit, books: const [], categories: const [], failed: true);
    }
  }

  void _publish(
    Emitter<AccountDetailState> emit, {
    required List<AccountBookModel> books,
    required List<CategoryModel> categories,
    required bool failed,
  }) {
    final accounts = [for (final book in books) book.account];
    AccountBookModel? selected;
    for (final book in books) {
      if (book.account.id == accountId) {
        selected = book;
        break;
      }
    }
    final status = failed
        ? AccountDetailStatus.failure
        : AccountDetailStatus.success;
    if (selected == null) {
      emit(
        AccountDetailState(
          status: status,
          categories: categories,
          accounts: accounts,
        ),
      );
      return;
    }
    emit(
      AccountDetailState(
        status: status,
        account: selected.account,
        balanceMinor: selected.balance,
        history: selected.transactions,
        categories: categories,
        accounts: accounts,
      ),
    );
  }
}
