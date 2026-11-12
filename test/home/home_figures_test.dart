import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/home/models/home_figures.dart';

void main() {
  test('month balance ignores transfers', () {
    final figures = monthFigures([
      TransactionModel(
        id: 1,
        type: TransactionType.income,
        amount: 50.0,
        date: DateTime(2026, 10, 1),
      ),
      TransactionModel(
        id: 2,
        type: TransactionType.expense,
        amount: 12.0,
        date: DateTime(2026, 10, 2),
      ),
      TransactionModel(
        id: 3,
        type: TransactionType.transfer,
        amount: 90.0,
        date: DateTime(2026, 10, 3),
        fromAccountId: 4,
        toAccountId: 5,
      ),
    ], DateTime(2026, 10));
    expect(figures.income, 50.0);
    expect(figures.expense, 12.0);
    expect(figures.balance, 38.0);
  });

  test('opening income is included in the month', () {
    final opening = TransactionModel(
      id: 6,
      type: TransactionType.income,
      amount: 100.0,
      date: DateTime(2026, 10, 1),
      accountId: 5,
    );
    final expense = TransactionModel(
      id: 2,
      type: TransactionType.expense,
      amount: 20.0,
      date: DateTime(2026, 10, 2),
      accountId: 5,
      categoryId: 7,
    );

    final figures = monthFigures([opening, expense], DateTime(2026, 10));
    expect(figures.income, 100.0);
    expect(figures.expense, 20.0);
    expect(figures.balance, 80.0);
  });

  test('negative opening expense is included in the month', () {
    final opening = TransactionModel(
      id: 6,
      type: TransactionType.expense,
      amount: 5.0,
      date: DateTime(2026, 10, 1),
      accountId: 5,
    );

    final figures = monthFigures([opening], DateTime(2026, 10));
    expect(figures.income, 0.0);
    expect(figures.expense, 5.0);
  });
}
