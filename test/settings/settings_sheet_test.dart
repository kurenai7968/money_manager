import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/app.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/widgets/app_tab_bar.dart';

import '../support/memory_account_repository.dart';
import '../support/memory_app_setting_repository.dart';
import '../support/memory_category_repository.dart';
import '../support/memory_transaction_repository.dart';

void main() {
  testWidgets('settings sheet matches the background and covers the tab bar', (
    tester,
  ) async {
    tester.platformDispatcher.localeTestValue = const Locale('en');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);

    await tester.pumpWidget(
      App(
        accounts: MemoryAccountRepository(),
        categories: MemoryCategoryRepository(),
        transactions: MemoryTransactionRepository(),
        settings: MemoryAppSettingRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(AppTabBar),
        matching: find.text('Settings'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();

    expect(find.text('English'), findsOneWidget);
    expect(
      find
          .descendant(of: find.byType(AppTabBar), matching: find.text('Home'))
          .hitTestable(),
      findsNothing,
    );
    expect(
      tester.widget<BottomSheet>(find.byType(BottomSheet)).backgroundColor,
      AppThemes.light.scaffoldBackgroundColor,
    );
  });
}
