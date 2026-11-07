import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/widgets/app_tab_bar.dart';

import '../support/pump_app.dart';

void main() {
  useAppTestBinding();

  testWidgets('settings sheet matches the background and covers the tab bar', (
    tester,
  ) async {
    tester.platformDispatcher.localeTestValue = const Locale('en');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);

    await pumpApp(tester);
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
    final sheet = tester.widget<BottomSheet>(find.byType(BottomSheet));
    expect(sheet.backgroundColor, AppThemes.light.scaffoldBackgroundColor);
    final theme = Theme.of(tester.element(find.byType(BottomSheet)))
        .bottomSheetTheme;
    expect(theme.elevation, 0);
    expect(theme.modalElevation, 0);
    expect(
      theme.shape,
      const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.m)),
      ),
    );
  });
}
