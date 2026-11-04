import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/core/utils/cached_date_format.dart';
import 'package:money_manager/pages/home/bloc/home_bloc.dart';
import 'package:money_manager/pages/home/bloc/home_event.dart';
import 'package:money_manager/pages/home/bloc/home_state.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomeBloc>().state;
    final l10n = context.l10n;
    final showingSummary = state.view == HomeView.summary;
    final locale = Localizations.localeOf(context).toString();
    final monthLabel = cachedYearMonth(locale).format(state.month);
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: l10n.previousMonth,
            onPressed: () =>
                context.read<HomeBloc>().add(const HomeMonthShifted(-1)),
            icon: const Icon(Icons.chevron_left),
          ),
          Flexible(child: Text(monthLabel, overflow: TextOverflow.ellipsis)),
          IconButton(
            tooltip: l10n.nextMonth,
            onPressed: () =>
                context.read<HomeBloc>().add(const HomeMonthShifted(1)),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: showingSummary ? l10n.showCalendar : l10n.showSummary,
          onPressed: () =>
              context.read<HomeBloc>().add(const HomeViewToggled()),
          icon: Icon(
            showingSummary ? Icons.calendar_today_outlined : Icons.bar_chart,
          ),
        ),
      ],
    );
  }
}
