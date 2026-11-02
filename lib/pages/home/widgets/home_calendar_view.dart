import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/utils/money_format.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/enums/week_start.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/themes/ledger_palette.dart';
import 'package:money_manager/widgets/ledger_calendar.dart';
import 'package:money_manager/widgets/transaction_item.dart';

class HomeCalendarView extends StatelessWidget {
  const HomeCalendarView({
    required this.month,
    required this.transactions,
    required this.categories,
    required this.accounts,
    required this.selectedDay,
    required this.weekStart,
    required this.locale,
    required this.onSelect,
    super.key,
  });

  final DateTime month;
  final List<TransactionModel> transactions;
  final List<CategoryModel> categories;
  final List<AccountModel> accounts;
  final DateTime? selectedDay;
  final WeekStart weekStart;
  final String locale;
  final ValueChanged<DateTime> onSelect;

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
    final days = _indexDays(transactions);
    final dayItems = selected == null
        ? const <TransactionModel>[]
        : days.items[DateTime(selected.year, selected.month, selected.day)] ??
              const <TransactionModel>[];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          child: SizedBox(
            height: LedgerCalendar.extent(context, header: false),
            child: LedgerCalendar(
              focusedDay: focused,
              selectedDay: selected,
              weekStart: weekStart,
              enableSwipe: false,
              onDaySelected: (day, _) =>
                  onSelect(DateTime(day.year, day.month, day.day)),
              dayDetail: (context, day) {
                final net =
                    days.nets[DateTime(day.year, day.month, day.day)] ?? 0;
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

class _MonthDays {
  final nets = <DateTime, int>{};
  final items = <DateTime, List<TransactionModel>>{};
}

_MonthDays _indexDays(List<TransactionModel> transactions) {
  final days = _MonthDays();
  for (final transaction in transactions) {
    final day = DateTime(
      transaction.date.year,
      transaction.date.month,
      transaction.date.day,
    );
    (days.items[day] ??= []).add(transaction);
    final delta = switch (transaction.type) {
      TransactionType.income => transaction.amountMinor,
      TransactionType.expense => -transaction.amountMinor,
      _ => 0,
    };
    if (delta == 0) {
      continue;
    }
    days.nets[day] = (days.nets[day] ?? 0) + delta;
  }
  return days;
}
