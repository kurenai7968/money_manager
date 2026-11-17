import 'package:material_ui/material_ui.dart';
import 'package:money_manager/models/day_account_book.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/core/utils/money_format.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/enums/first_day_of_week.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/widgets/account_book_calendar.dart';
import 'package:money_manager/widgets/transaction_item.dart';

class HomeCalendarView extends StatelessWidget {
  final DateTime month;
  final List<DayAccountBook> days;
  final List<CategoryModel> categories;
  final List<AccountModel> accounts;
  final DateTime? selectedDay;
  final FirstDayOfWeek firstDayOfWeek;
  final String locale;
  final ValueChanged<DateTime> onSelect;
  final EdgeInsets listPadding;
  final VoidCallback onRecordReturned;

  const HomeCalendarView({
    required this.month,
    required this.days,
    required this.categories,
    required this.accounts,
    required this.selectedDay,
    required this.firstDayOfWeek,
    required this.locale,
    required this.onSelect,
    required this.listPadding,
    required this.onRecordReturned,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final selected = selectedDay;
    final selectedAccountBook = _accountBookOn(days, selected);
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
            height: AccountBookCalendar.extent(context, header: false),
            child: AccountBookCalendar(
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
                  formatAmount(net, locale: locale, signed: true),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: context.accountBookColor(income: net > 0),
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          child: selectedAccountBook == null
              ? const SizedBox.shrink()
              : TransactionList(
                  days: [selectedAccountBook],
                  categories: categories,
                  accounts: accounts,
                  locale: locale,
                  padding: listPadding,
                  onReturned: onRecordReturned,
                ),
        ),
      ],
    );
  }
}

DayAccountBook? _accountBookOn(List<DayAccountBook> days, DateTime? day) {
  if (day == null) {
    return null;
  }
  final key = DateTime(day.year, day.month, day.day);
  for (final item in days) {
    if (item.day == key) {
      return item;
    }
  }
  return null;
}
