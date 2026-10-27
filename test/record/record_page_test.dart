import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app.dart';
import 'package:money_manager/widgets/app_tab_bar.dart';

import '../support/memory_account_repository.dart';
import '../support/memory_app_setting_repository.dart';
import '../support/memory_category_repository.dart';
import '../support/memory_transaction_repository.dart';

void main() {
  testWidgets('Expense records the selected category and can be edited', (
    tester,
  ) async {
    await pumpLedger(tester);

    await openRecord(tester);
    expect(selectedCategory('Food'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);

    await tester.tap(find.text('Food'));
    await tester.pump();
    expect(selectedCategory('Food'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    await tester.tap(find.text('Transit'));
    await tester.pump();
    expect(selectedCategory('Food'), findsNothing);
    expect(selectedCategory('Transit'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    await tester.tap(find.text('Food'));
    await tester.pump();
    expect(selectedCategory('Food'), findsOneWidget);

    await tester.tap(find.text('Note'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Lunch');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Lunch'), findsOneWidget);

    await tapKey(tester, '1');
    await tapKey(tester, '8');
    expect(find.text('18'), findsOneWidget);
    await commit(tester);

    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('-18'), findsWidgets);
    await openAccounts(tester);
    expect(find.text('-18'), findsWidgets);

    await openTab(tester, 'Home');
    await tester.ensureVisible(find.text('Lunch'));
    await tester.tap(find.text('Lunch'));
    await tester.pumpAndSettle();
    expect(selectedCategory('Food'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('Lunch'), findsOneWidget);

    await tester.tap(find.text('Transit'));
    await tester.pump();
    await tapKey(tester, '←');
    await tapKey(tester, '←');
    await tapKey(tester, '7');
    await commit(tester);

    expect(find.text('-7'), findsWidgets);
    await tester.ensureVisible(find.text('Lunch'));
    await tester.tap(find.text('Lunch'));
    await tester.pumpAndSettle();
    expect(selectedCategory('Transit'), findsOneWidget);
    expect(selectedCategory('Food'), findsNothing);
    expect(find.text('7'), findsWidgets);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('No transactions this month'), findsOneWidget);
    expect(find.text('Lunch'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Income uses an income category and increases the account', (
    tester,
  ) async {
    await pumpLedger(tester);
    await openRecord(tester);

    await tester.tap(find.text('Income'));
    await tester.pump();
    expect(find.text('Food'), findsNothing);
    expect(find.text('Salary'), findsOneWidget);
    expect(selectedCategory('Salary'), findsOneWidget);

    await tester.tap(find.text('Salary'));
    await tester.pump();
    expect(selectedCategory('Salary'), findsOneWidget);
    await tapKey(tester, '4');
    await tapKey(tester, '0');
    await commit(tester);

    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('+40'), findsOneWidget);
    await openAccounts(tester);
    expect(find.text('40'), findsWidgets);
  });

  testWidgets('Transfer moves the amount between two accounts', (tester) async {
    await pumpLedger(tester);
    await openTab(tester, 'Accounts');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Bank');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    await openTab(tester, 'Home');
    await openRecord(tester);
    await tester.tap(find.text('Transfer'));
    await tester.pump();
    expect(find.text('Food'), findsNothing);
    expect(find.text('From'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('Choose account'), findsOneWidget);

    await tapKey(tester, '5');
    await commit(tester);
    expect(find.text('Choose two different accounts'), findsOneWidget);
    await tapKey(tester, 'C');

    await tester.tap(find.text('Choose account'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check), findsOneWidget);
    await tester.tap(find.text('Bank'));
    await tester.pumpAndSettle();
    expect(find.text('Bank'), findsOneWidget);

    await tester.tap(find.text('To'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check), findsNWidgets(2));
    await tester.tap(find.text('Bank').last);
    await tester.pumpAndSettle();

    await tapKey(tester, '2');
    await tapKey(tester, '0');
    await commit(tester);
    expect(find.text('Transfer'), findsWidgets);
    expect(find.text('20'), findsOneWidget);

    await openAccounts(tester);
    expect(find.text('-20'), findsOneWidget);
    expect(find.text('20'), findsWidgets);
  });

  testWidgets('Check explains a missing amount', (tester) async {
    await pumpLedger(tester, size: const Size(320, 568));
    await openRecord(tester);

    await commit(tester);
    expect(find.text('Enter an amount greater than zero'), findsOneWidget);

    await tapKey(tester, '9');
    await tapKey(tester, '9');
    await tapKey(tester, '9');
    await tapKey(tester, '9');
    await tapKey(tester, '9');
    await tapKey(tester, '9');
    expect(find.text('999,999'), findsOneWidget);

    await commit(tester);
    expect(find.text('Choose a category'), findsNothing);
    expect(find.text('Food'), findsWidgets);
    expect(find.text('-999,999'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Traditional Chinese record page names the selected category', (
    tester,
  ) async {
    await pumpLedger(tester, locale: const Locale('zh'));
    await tester.tap(find.byTooltip('記一筆'));
    await tester.pumpAndSettle();

    expect(find.text('飲食'), findsOneWidget);
    expect(find.text('現金'), findsOneWidget);
    expect(selectedCategory('飲食'), findsOneWidget);

    await tester.tap(find.text('飲食'));
    await tester.pump();
    expect(selectedCategory('飲食'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, '8'));
    await tester.pump();
    await tester.tap(find.byTooltip('儲存'));
    await tester.pumpAndSettle();

    expect(find.text('飲食'), findsWidgets);
    expect(find.text('-8'), findsWidgets);
  });

  testWidgets('Equals finishes a calculation before save', (tester) async {
    await pumpLedger(tester);
    await openRecord(tester);

    await tapKey(tester, '8');
    await tapKey(tester, '+');
    expect(find.byTooltip('Save'), findsNothing);
    expect(find.byTooltip('Equals'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);

    await tapKey(tester, '2');
    await tester.tap(find.byTooltip('Equals'));
    await tester.pump();
    expect(find.text('10'), findsOneWidget);
    expect(find.byTooltip('Save'), findsOneWidget);

    await commit(tester);
    expect(find.text('-10'), findsWidgets);
  });

  testWidgets('Divide by zero keeps the equals key', (tester) async {
    await pumpLedger(tester);
    await openRecord(tester);
    await tapKey(tester, '8');
    await tapKey(tester, '÷');
    await tapKey(tester, '0');
    await tester.tap(find.byTooltip('Equals'));
    await tester.pump();
    expect(find.text('Enter an amount greater than zero'), findsOneWidget);
    expect(find.byTooltip('Save'), findsNothing);
  });

  testWidgets('Commit key is taller than wide and category gaps match', (
    tester,
  ) async {
    await pumpLedger(tester);
    await openRecord(tester);

    final button = tester.getSize(find.byType(FilledButton));
    expect(button.height, greaterThan(button.width));

    double centerOf(IconData icon) {
      return tester.getCenter(find.byIcon(icon)).dx;
    }

    final food = centerOf(Icons.restaurant_outlined);
    final transit = centerOf(Icons.directions_transit_outlined);
    final housing = centerOf(Icons.home_outlined);
    final shopping = centerOf(Icons.shopping_bag_outlined);
    final gaps = [transit - food, housing - transit, shopping - housing];
    expect(gaps[0], closeTo(gaps[1], 0.5));
    expect(gaps[1], closeTo(gaps[2], 0.5));
    expect(gaps[0], lessThan(84));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Record page lays out at a larger text scale', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpLedger(tester, size: const Size(360, 640));
    await openRecord(tester);
    expect(selectedCategory('Food'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Record page lays out in dark mode at double text scale', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await pumpLedger(tester, size: const Size(320, 568));
    await openRecord(tester);
    expect(selectedCategory('Food'), findsOneWidget);
    expect(find.byTooltip('Save'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Finder selectedCategory(String label) {
  return find.byWidgetPredicate((widget) {
    return widget is Semantics &&
        widget.properties.label == label &&
        widget.properties.selected == true;
  });
}

Future<void> pumpLedger(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  Size size = const Size(390, 844),
}) async {
  tester.platformDispatcher.localeTestValue = locale;
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(tester.platformDispatcher.clearLocaleTestValue);
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    App(
      accounts: MemoryAccountRepository(),
      categories: MemoryCategoryRepository(),
      transactions: MemoryTransactionRepository(),
      settings: MemoryAppSettingRepository(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> openRecord(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Record'));
  await tester.pumpAndSettle();
}

Future<void> openTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: find.byType(AppTabBar), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
}

Future<void> openAccounts(WidgetTester tester) async {
  await openTab(tester, 'Accounts');
}

Future<void> tapKey(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(TextButton, label));
  await tester.pump();
}

Future<void> commit(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Save'));
  await tester.pumpAndSettle();
}
