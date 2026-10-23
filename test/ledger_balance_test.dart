import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/core/utils/ledger_balance.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';

void main() {
  const cash = AccountModel(
    id: 'cash',
    name: 'Cash',
    type: AccountType.cash,
    openingBalanceMinor: 10000,
    sortOrder: 0,
  );
  const card = AccountModel(
    id: 'card',
    name: 'Card',
    type: AccountType.credit,
    openingBalanceMinor: 0,
    sortOrder: 1,
  );

  test('expense and card payment update balances', () {
    final expense = TransactionModel(
      id: 'meal',
      type: TransactionType.expense,
      amountMinor: 2000,
      date: DateTime(2026, 10, 23),
      accountId: 'card',
      categoryId: 'food',
    );
    final payment = TransactionModel(
      id: 'pay',
      type: TransactionType.transfer,
      amountMinor: 2000,
      date: DateTime(2026, 10, 24),
      fromAccountId: 'cash',
      toAccountId: 'card',
    );

    expect(balanceOf(card, [expense]), 2000);
    expect(balanceOf(cash, [payment]), 8000);
    expect(balanceOf(card, [expense, payment]), 0);
    expect(netWorthOf([cash, card], [expense, payment]), 8000);
  });
}
