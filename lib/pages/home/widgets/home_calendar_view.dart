import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/utils/ledger_balance.dart';
import 'package:money_manager/core/utils/money_format.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/enums/week_start.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/home/widgets/home_transaction_tile.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/themes/ledger_palette.dart';
import 'package:money_manager/widgets/ledger_calendar.dart';

class HomeCalendarView extends StatelessWidget {
  const HomeCalendarView({
    required this.month,
    required this.transactions,
    required this.categories,
    required this.selectedDay,
    required this.weekStart,
    required this.locale,
    required this.onSelect,
    super.key,
  });

  final DateTime month;
  final List<TransactionModel> transactions;
  final List<CategoryModel> categories;
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
    final dayItems = selected == null
        ? const <TransactionModel>[]
        : transactions.where((item) => sameDay(item.date, selected)).toList();
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            child: LedgerCalendar(
              focusedDay: focused,
              selectedDay: selected,
              weekStart: weekStart,
              enableSwipe: false,
              onDaySelected: (day, _) =>
                  onSelect(DateTime(day.year, day.month, day.day)),
              dayDetail: (context, day) {
                final net = _dayNet(day);
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
        if (selected != null)
          SizedBox(
            height: AppSpacing.xl * 6 + AppSpacing.l,
            child: dayItems.isEmpty
                ? const SizedBox.shrink()
                : ListView.separated(
                    itemCount: dayItems.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, color: scheme.outline),
                    itemBuilder: (context, index) {
                      return HomeTransactionTile(
                        transaction: dayItems[index],
                        categories: categories,
                        locale: locale,
                      );
                    },
                  ),
          ),
      ],
    );
  }

  int _dayNet(DateTime date) {
    var net = 0;
    for (final transaction in transactions.where(
      (item) => sameDay(item.date, date),
    )) {
      if (transaction.type == TransactionType.income) {
        net += transaction.amountMinor;
      } else if (transaction.type == TransactionType.expense) {
        net -= transaction.amountMinor;
      }
    }
    return net;
  }
}
