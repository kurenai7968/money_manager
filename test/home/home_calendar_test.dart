import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/app.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:table_calendar/table_calendar.dart';

import '../support/memory_account_repository.dart';
import '../support/memory_app_setting_repository.dart';
import '../support/memory_category_repository.dart';
import '../support/memory_transaction_repository.dart';

void main() {
  testWidgets('Home calendar uses TableCalendar and shows the day net', (
    tester,
  ) async {
    tester.platformDispatcher.localeTestValue = const Locale('en');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    final now = DateTime.now();
    final transactions = MemoryTransactionRepository()
      ..transactions.add(
        TransactionModel(
          id: 'lunch',
          type: TransactionType.expense,
          amountMinor: 20,
          date: DateTime(now.year, now.month, now.day),
          note: 'Lunch',
        ),
      );

    await tester.pumpWidget(
      App(
        accounts: MemoryAccountRepository(),
        categories: MemoryCategoryRepository(),
        transactions: transactions,
        settings: MemoryAppSettingRepository(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Calendar'));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate((widget) => widget is TableCalendar),
      findsOneWidget,
    );
    expect(find.text('-0.20'), findsWidgets);
    expect(find.text('Lunch'), findsOneWidget);
    final calendar = find.byWidgetPredicate(
      (widget) => widget is TableCalendar,
    );
    final height = tester.getSize(calendar).height;

    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.text('Lunch'), findsNothing);
    expect(tester.getSize(calendar).height, height);

    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(find.text('Lunch'), findsOneWidget);
    expect(tester.getSize(calendar).height, height);

    final other = now.day == 1 ? 2 : 1;
    await tester.tap(
      find.descendant(of: calendar, matching: find.text('$other')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Lunch'), findsNothing);
    expect(tester.getSize(calendar).height, height);
    expect(tester.takeException(), isNull);
  });
}
