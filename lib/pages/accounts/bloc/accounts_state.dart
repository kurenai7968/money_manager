import 'package:equatable/equatable.dart';
import 'package:money_manager/core/utils/ledger_balance.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/accounts/models/account_line.dart';

enum AccountsStatus { initial, loading, success, failure }

enum AccountsError { none, saveFailed, archiveBlocked, nameRequired }

class AccountsState extends Equatable {
  final AccountsStatus status;
  final List<AccountModel> accounts;
  final List<TransactionModel> transactions;
  final AccountsError error;

  const AccountsState({
    this.status = AccountsStatus.initial,
    this.accounts = const [],
    this.transactions = const [],
    this.error = AccountsError.none,
  });

  List<AccountModel> get active =>
      accounts.where((account) => !account.archived).toList();

  int get netWorth => netWorthOf(active, transactions);

  List<AccountLine> get assets => _lines(credit: false);

  List<AccountLine> get liabilities => _lines(credit: true);

  List<AccountLine> _lines({required bool credit}) {
    final open = active;
    final balances = balancesOf(open, transactions);
    return [
      for (final account in open)
        if ((account.type == AccountType.credit) == credit)
          AccountLine(
            account: account,
            balanceMinor: balances[account.id] ?? account.openingBalanceMinor,
          ),
    ];
  }

  AccountsState copyWith({
    AccountsStatus? status,
    List<AccountModel>? accounts,
    List<TransactionModel>? transactions,
    AccountsError? error,
  }) {
    return AccountsState(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      transactions: transactions ?? this.transactions,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, accounts, transactions, error];
}
