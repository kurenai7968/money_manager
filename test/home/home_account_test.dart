import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/account_book_kinds.dart';

import '../support/pump_app.dart';

void main() {
  useAppTestBinding();

  testWidgets('Home selects one account or all accounts', (tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('en');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester);
    await tester.pumpAndSettle();

    expect(find.text('All'), findsOneWidget);
    _expectAccountBeforeMonth(tester, 'All');
    _expectMonthGroupCentered(tester);
    expect(
      tester.getSize(find.byTooltip('Previous month')).width,
      lessThanOrEqualTo(32),
    );

    await tester.tap(find.byTooltip('Choose account'));
    await tester.pumpAndSettle();
    expect(find.text('All'), findsWidgets);
    expect(find.text('Cash'), findsOneWidget);
    expect(
      tester.getSize(find.byType(BottomSheet)).height,
      lessThan(844 * 0.5),
    );

    await tester.tap(find.text('Cash'));
    await tester.pumpAndSettle();
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('All'), findsNothing);

    await tester.tap(find.byTooltip('Choose account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All').last);
    await tester.pumpAndSettle();
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Cash'), findsNothing);
  });

  testWidgets('account sheet stays within half the screen', (tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('en');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(
      tester,
      accounts: [
        for (var index = 0; index < 40; index++)
          AccountModel(
            id: index + 1,
            name: 'Account $index',
            type: AccountType.cash,
            icon: 'other',
            sortOrder: index,
          ),
      ],
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Choose account'));
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byType(BottomSheet)).height,
      lessThanOrEqualTo(844 * 0.5),
    );
    expect(find.text('Account 0'), findsOneWidget);
    expect(find.text('Account 39'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Account 39'),
      300,
      scrollable: find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('Account 39'), findsOneWidget);
  });

  testWidgets('a long account name keeps its beginning', (tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('en');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const name = 'North Station cash wallet extra';
    await pumpApp(
      tester,
      accounts: const [
        AccountModel(
          id: 1,
          name: name,
          type: AccountType.cash,
          icon: 'other',
          sortOrder: 0,
        ),
      ],
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Choose account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();

    final label = tester.widget<Text>(find.text(name));
    expect(label.maxLines, 1);
    expect(label.overflow, TextOverflow.ellipsis);
    expect(label.softWrap, isFalse);
    _expectAccountBeforeMonth(tester, name);
    _expectMonthGroupCentered(tester);
    expect(tester.getSize(find.text(name)).width, lessThan(160));
  });
}

Finder get _yearMonth {
  return find.byWidgetPredicate((widget) {
    final text = widget is Text ? widget.data : null;
    return text != null && RegExp(r'^\d{4}-\d{2}$').hasMatch(text);
  });
}

void _expectAccountBeforeMonth(WidgetTester tester, String label) {
  final account = tester.getRect(find.text(label));
  final month = tester.getRect(_yearMonth);
  expect(account.left, lessThan(24));
  expect(account.width, greaterThan(12));
  expect(account.right, lessThanOrEqualTo(month.left));
}

void _expectMonthGroupCentered(WidgetTester tester) {
  final account = tester.getRect(find.byTooltip('Choose account'));
  final previous = tester.getRect(find.byTooltip('Previous month'));
  final next = tester.getRect(find.byTooltip('Next month'));
  final calendar = tester.getRect(find.byTooltip('Calendar'));
  final month = tester.getRect(_yearMonth);
  final bar = tester.getRect(find.byType(AppBar));
  expect(account.left - bar.left, lessThanOrEqualTo(8));
  expect(bar.right - calendar.right, lessThanOrEqualTo(8));
  expect(month.left - previous.right, lessThanOrEqualTo(4));
  expect(next.left - month.right, lessThanOrEqualTo(4));
  expect(
    ((previous.left - account.right) - (calendar.left - next.right)).abs(),
    lessThan(8),
  );
}
