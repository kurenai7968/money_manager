import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/home/models/home_figures.dart';

void main() {
  test('month balance ignores transfers', () {
    final figures = monthFigures([
      TransactionModel(
        id: 'pay',
        type: TransactionType.income,
        amountMinor: 5000,
        date: DateTime(2026, 10, 1),
      ),
      TransactionModel(
        id: 'meal',
        type: TransactionType.expense,
        amountMinor: 1200,
        date: DateTime(2026, 10, 2),
      ),
      TransactionModel(
        id: 'move',
        type: TransactionType.transfer,
        amountMinor: 9000,
        date: DateTime(2026, 10, 3),
        fromAccountId: 'bank',
        toAccountId: 'cash',
      ),
    ], DateTime(2026, 10));
    expect(figures.incomeMinor, 5000);
    expect(figures.expenseMinor, 1200);
    expect(figures.balanceMinor, 3800);
  });

  test('opening income is included in the month', () {
    final opening = TransactionModel(
      id: 'opening-cash',
      type: TransactionType.income,
      amountMinor: 10000,
      date: DateTime(2026, 10, 1),
      accountId: 'cash',
    );
    final expense = TransactionModel(
      id: 'meal',
      type: TransactionType.expense,
      amountMinor: 2000,
      date: DateTime(2026, 10, 2),
      accountId: 'cash',
      categoryId: 'food',
    );

    final figures = monthFigures([opening, expense], DateTime(2026, 10));
    expect(figures.incomeMinor, 10000);
    expect(figures.expenseMinor, 2000);
    expect(figures.balanceMinor, 8000);
  });

  test('negative opening expense is included in the month', () {
    final opening = TransactionModel(
      id: 'opening-cash',
      type: TransactionType.expense,
      amountMinor: 500,
      date: DateTime(2026, 10, 1),
      accountId: 'cash',
    );

    final figures = monthFigures([opening], DateTime(2026, 10));
    expect(figures.incomeMinor, 0);
    expect(figures.expenseMinor, 500);
  });
}
