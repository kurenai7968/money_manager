import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:table_calendar/table_calendar.dart';

import '../support/pump_app.dart';

void main() {
  useAppTestBinding();

  testWidgets('Home calendar uses TableCalendar and shows the day net', (
    tester,
  ) async {
    tester.platformDispatcher.localeTestValue = const Locale('en');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    final now = DateTime.now();
    await pumpApp(
      tester,
      accounts: const [
        AccountModel(
          id: 1,
          name: 'Cash',
          type: AccountType.cash,
          icon: 'other',
          sortOrder: 0,
        ),
      ],
      transactions: [
        TransactionModel(
          id: 2,
          type: TransactionType.expense,
          amount: 0.2,
          date: DateTime(now.year, now.month, now.day),
          note: 'Lunch',
          accountId: 1,
        ),
      ],
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
    final header = DateFormat('M/d (E)', 'en').format(now);
    expect(find.text(header), findsOneWidget);
    expect(find.text('Expense 0.20'), findsOneWidget);
    await tester.tap(find.text(header));
    await tester.pump();
    expect(find.text('Lunch'), findsNothing);
    await tester.tap(find.text(header));
    await tester.pump();
    expect(find.text('Lunch'), findsOneWidget);
    final calendar = find.byWidgetPredicate(
      (widget) => widget is TableCalendar,
    );
    final height = tester.getSize(calendar).height;

    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.text('Lunch'), findsNothing);
    expect(_selectedDay(tester, calendar), 1);
    expect(tester.getSize(calendar).height, height);

    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    expect(_selectedDay(tester, calendar), lastDay);
    expect(
      find.text('Lunch'),
      lastDay == now.day ? findsOneWidget : findsNothing,
    );
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

  testWidgets('month dialog jumps to a later month', (tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('en');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    final now = DateTime.now();
    await pumpApp(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Choose month'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('Jan'), findsOneWidget);
    expect(find.text('Dec'), findsOneWidget);
    expect(find.text('${now.year}'), findsOneWidget);

    await tester.tap(find.byTooltip('Next year'));
    await tester.pump();
    expect(find.text('${now.year + 1}'), findsOneWidget);
    await tester.tap(find.text('Mar'));
    await tester.pumpAndSettle();

    expect(
      find.text(DateFormat('yyyy-MM').format(DateTime(now.year + 1, 3))),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Calendar'));
    await tester.pumpAndSettle();
    expect(
      _selectedDay(
        tester,
        find.byWidgetPredicate((widget) => widget is TableCalendar),
      ),
      1,
    );
  });
}

int _selectedDay(WidgetTester tester, Finder calendar) {
  final selected = tester.widget<Text>(
    find.descendant(
      of: find.descendant(
        of: calendar,
        matching: find.byWidgetPredicate((widget) {
          if (widget is! DecoratedBox) {
            return false;
          }
          final decoration = widget.decoration;
          return decoration is BoxDecoration &&
              decoration.shape == BoxShape.circle;
        }),
      ),
      matching: find.byType(Text),
    ),
  );
  return int.parse(selected.data!);
}
