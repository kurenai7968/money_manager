import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/themes/account_book_palette.dart';
import 'package:money_manager/widgets/app_tab_bar.dart';
import 'package:money_manager/widgets/transaction_item.dart';

import '../support/pump_app.dart';

void main() {
  useAppTestBinding();

  testWidgets('income and expense colors change as one pair', (tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('en');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    final now = DateTime.now();
    await pumpApp(
      tester,
      accounts: const [
        AccountModel(
          id: 2,
          name: 'Wallet',
          type: AccountType.cash,
          icon: 'other',
          sortOrder: 0,
        ),
      ],
      categories: const [
        CategoryModel(
          id: 1,
          name: 'Food',
          icon: 'food',
          type: CategoryKind.expense,
          sortOrder: 0,
        ),
        CategoryModel(
          id: 3,
          name: 'Salary',
          icon: 'salary',
          type: CategoryKind.income,
          sortOrder: 0,
        ),
      ],
      transactions: [
        TransactionModel(
          id: 4,
          type: TransactionType.expense,
          amount: 41,
          date: DateTime(now.year, now.month, now.day),
          accountId: 2,
          categoryId: 1,
        ),
        TransactionModel(
          id: 5,
          type: TransactionType.income,
          amount: 17,
          date: DateTime(now.year, now.month, now.day),
          accountId: 2,
          categoryId: 3,
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(_rowAmountColor(tester, '-41'), AccountBookPalette.red);
    expect(_rowAmountColor(tester, '+17'), AccountBookPalette.green);

    await tester.tap(
      find.descendant(
        of: find.byType(AppTabBar),
        matching: find.text('Settings'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Color'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Coral / Teal'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: find.byType(AppTabBar), matching: find.text('Home')),
    );
    await tester.pumpAndSettle();

    expect(_rowAmountColor(tester, '-41'), AccountBookPalette.coral);
    expect(_rowAmountColor(tester, '+17'), AccountBookPalette.teal);
  });
}

Color? _rowAmountColor(WidgetTester tester, String amount) {
  return tester
      .widget<Text>(
        find.descendant(
          of: find.byType(TransactionItem),
          matching: find.text(amount),
        ),
      )
      .style
      ?.color;
}
