import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/pages/home/widgets/home_frame.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final frame = HomeFrame.of(context);
    final l10n = context.l10n;
    final showingSummary = frame.view == HomeView.summary;
    final locale = Localizations.localeOf(context).toString();
    final monthLabel = DateFormat.yMMMM(locale).format(frame.month);
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: l10n.previousMonth,
            onPressed: () => frame.shiftMonth(-1),
            icon: const Icon(Icons.chevron_left),
          ),
          Flexible(child: Text(monthLabel, overflow: TextOverflow.ellipsis)),
          IconButton(
            tooltip: l10n.nextMonth,
            onPressed: () => frame.shiftMonth(1),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: showingSummary ? l10n.showCalendar : l10n.showSummary,
          onPressed: frame.toggleView,
          icon: Icon(
            showingSummary ? Icons.calendar_today_outlined : Icons.bar_chart,
          ),
        ),
      ],
    );
  }
}
