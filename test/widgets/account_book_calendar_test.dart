import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/models/enums/first_day_of_week.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/widgets/account_book_calendar.dart';

const _delegates = [
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];

void main() {
  testWidgets('day numbers stay aligned when only some days show an amount', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: _delegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppThemes.light,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return SizedBox(
                height: AccountBookCalendar.extent(context, header: false),
                child: AccountBookCalendar(
                  focusedDay: DateTime(2026, 11, 2),
                  selectedDay: DateTime(2026, 11, 2),
                  firstDayOfWeek: FirstDayOfWeek.monday,
                  onDaySelected: (_, _) {},
                  dayDetail: (context, day) {
                    if (day.month != 11) {
                      return null;
                    }
                    if (day.day == 2) {
                      return Text(
                        '+46',
                        style: Theme.of(context).textTheme.labelMedium,
                      );
                    }
                    if (day.day == 4) {
                      return Text(
                        '+123456.78',
                        style: Theme.of(context).textTheme.labelMedium,
                      );
                    }
                    return null;
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final day2 = tester.getTopLeft(find.text('2'));
    final day3 = tester.getTopLeft(find.text('3'));
    final day4 = tester.getTopLeft(find.text('4'));
    expect(day2.dy, closeTo(day3.dy, 0.5));
    expect(day4.dy, closeTo(day3.dy, 0.5));
    expect(tester.getTopLeft(find.text('+46')).dy, greaterThan(day2.dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a calendar without amounts does not reserve an amount line', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: _delegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppThemes.light,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return SizedBox(
                height: AccountBookCalendar.extent(context, header: false),
                child: AccountBookCalendar(
                  focusedDay: DateTime(2026, 11, 2),
                  selectedDay: DateTime(2026, 11, 2),
                  firstDayOfWeek: FirstDayOfWeek.monday,
                  onDaySelected: (_, _) {},
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final withoutSlot = tester.getTopLeft(find.text('2')).dy;
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: _delegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppThemes.light,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return SizedBox(
                height: AccountBookCalendar.extent(context, header: false),
                child: AccountBookCalendar(
                  focusedDay: DateTime(2026, 11, 2),
                  selectedDay: DateTime(2026, 11, 2),
                  firstDayOfWeek: FirstDayOfWeek.monday,
                  onDaySelected: (_, _) {},
                  dayDetail: (_, _) => null,
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('2')).dy, lessThan(withoutSlot - 8));
    expect(tester.takeException(), isNull);
  });
}
