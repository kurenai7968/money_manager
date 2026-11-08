import 'package:material_ui/material_ui.dart';
import 'package:money_manager/pages/home/models/home_figures.dart';
import 'package:money_manager/core/utils/money_format.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/enums/first_day_of_week.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/themes/ledger_palette.dart';
import 'package:money_manager/widgets/ledger_calendar.dart';
import 'package:money_manager/widgets/transaction_item.dart';

class HomeCalendarView extends StatelessWidget {
  final DateTime month;
  final List<DayLedger> days;
  final List<TransactionModel> dayItems;
  final List<CategoryModel> categories;
  final List<AccountModel> accounts;
  final DateTime? selectedDay;
  final FirstDayOfWeek firstDayOfWeek;
  final String locale;
  final ValueChanged<DateTime> onSelect;

  const HomeCalendarView({
    required this.month,
    required this.days,
    required this.dayItems,
    required this.categories,
    required this.accounts,
    required this.selectedDay,
    required this.firstDayOfWeek,
    required this.locale,
    required this.onSelect,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selected = selectedDay;
    final focused =
        selected != null &&
            selected.year == month.year &&
            selected.month == month.month
        ? selected
        : DateTime(month.year, month.month);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          child: SizedBox(
            height: LedgerCalendar.extent(context, header: false),
            child: LedgerCalendar(
              focusedDay: focused,
              selectedDay: selected,
              firstDayOfWeek: firstDayOfWeek,
              enableSwipe: false,
              onDaySelected: (day, _) =>
                  onSelect(DateTime(day.year, day.month, day.day)),
              dayDetail: (context, day) {
                final net = netOn(days, day);
                if (net == 0) {
                  return null;
                }
                return Text(
                  formatMinor(net, locale: locale, signed: true),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: net > 0 ? LedgerPalette.green : scheme.primary,
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          child: dayItems.isEmpty
              ? const SizedBox.shrink()
              : TransactionList(
                  transactions: dayItems,
                  categories: categories,
                  accounts: accounts,
                  locale: locale,
                  showDayHeaders: false,
                ),
        ),
      ],
    );
  }
}
