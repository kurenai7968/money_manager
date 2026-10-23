import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/app.dart';
import 'package:money_manager/widgets/app_tab_bar.dart';

import 'support/memory_account_repository.dart';
import 'support/memory_category_repository.dart';
import 'support/memory_transaction_repository.dart';

void main() {
  testWidgets('Shell opens Home and reaches the other tabs', (tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('en');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);

    await tester.pumpWidget(
      MoneyManagerApp(
        accounts: MemoryAccountRepository(),
        categories: MemoryCategoryRepository(),
        transactions: MemoryTransactionRepository(),
      ),
    );
    await tester.pumpAndSettle();

    final now = DateTime.now();
    final month = DateFormat.yMMMM('en').format(DateTime(now.year, now.month));
    expect(find.text(month), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.byTooltip('Calendar'), findsOneWidget);

    await tester.tap(find.byTooltip('Next month'));
    await tester.pump();
    final nextMonth = DateFormat.yMMMM('en')
        .format(DateTime(now.year, now.month + 1));
    expect(find.text(nextMonth), findsOneWidget);

    await tester.tap(find.byTooltip('Calendar'));
    await tester.pump();
    expect(find.byTooltip('Summary'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(AppTabBar),
        matching: find.text('Analysis'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Analysis')),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(
        of: find.byType(AppTabBar),
        matching: find.text('Accounts'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Accounts')),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(
        of: find.byType(AppTabBar),
        matching: find.text('Settings'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Settings')),
      findsOneWidget,
    );
  });

  testWidgets('Record hides the tab bar', (tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('en');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);

    await tester.pumpWidget(
      MoneyManagerApp(
        accounts: MemoryAccountRepository(),
        categories: MemoryCategoryRepository(),
        transactions: MemoryTransactionRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Record'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsNothing);
    expect(find.byTooltip('Record'), findsNothing);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('Adding an account shows it in the list', (tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('en');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);

    await tester.pumpWidget(
      MoneyManagerApp(
        accounts: MemoryAccountRepository(),
        categories: MemoryCategoryRepository(),
        transactions: MemoryTransactionRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Accounts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Wallet');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Wallet'), findsOneWidget);
  });
}
