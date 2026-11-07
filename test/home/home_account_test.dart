import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/app.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';

import '../support/memory_account_repository.dart';
import '../support/memory_app_setting_repository.dart';
import '../support/memory_category_repository.dart';
import '../support/memory_transaction_repository.dart';

void main() {
  testWidgets('Home selects one account or all accounts', (tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('en');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      App(
        accounts: MemoryAccountRepository(),
        categories: MemoryCategoryRepository(),
        transactions: MemoryTransactionRepository(),
        settings: MemoryAppSettingRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('All'), findsOneWidget);

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

    final accounts = MemoryAccountRepository();
    for (var index = 0; index < 40; index++) {
      accounts.accounts.add(
        AccountModel(
          id: 'account-$index',
          name: 'Account $index',
          type: AccountType.cash,
          openingBalanceMinor: 0,
          sortOrder: index,
        ),
      );
    }

    await tester.pumpWidget(
      App(
        accounts: accounts,
        categories: MemoryCategoryRepository(),
        transactions: MemoryTransactionRepository(),
        settings: MemoryAppSettingRepository(),
      ),
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
}
