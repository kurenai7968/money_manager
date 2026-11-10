import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/models/enums/first_day_of_week.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:table_calendar/table_calendar.dart';

class AccountBookCalendar extends StatelessWidget {
  static final firstDay = DateTime(2000);
  static final lastDay = DateTime(2100, 12, 31);
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final FirstDayOfWeek firstDayOfWeek;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final ValueChanged<DateTime>? onPageChanged;
  final Widget? Function(BuildContext context, DateTime day)? dayDetail;
  final bool headerVisible;
  final bool enableSwipe;

  const AccountBookCalendar({
    required this.focusedDay,
    required this.selectedDay,
    required this.firstDayOfWeek,
    required this.onDaySelected,
    this.onPageChanged,
    this.dayDetail,
    this.headerVisible = false,
    this.enableSwipe = true,
    super.key,
  });

  static double extent(BuildContext context, {required bool header}) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final metrics = _metrics(scale, header: header);
    return metrics.height;
  }

  static ({double height, double dow, double row}) _metrics(
    double scale, {
    required bool header,
  }) {
    final row = AppSpacing.xl * 2 * scale;
    final dow = AppSpacing.xl * scale;
    final headerHeight = header ? AppSpacing.xl * 3 * scale : 0.0;
    return (height: headerHeight + dow + row * 6, dow: dow, row: row);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final weekday = textTheme.labelMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final metrics = _metrics(scale, header: headerVisible);
    final focused = _clamp(focusedDay);

    return TableCalendar<void>(
      locale: locale,
      firstDay: firstDay,
      lastDay: lastDay,
      focusedDay: focused,
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: ''},
      headerVisible: headerVisible,
      sixWeekMonthsEnforced: true,
      shouldFillViewport: true,
      pageAnimationEnabled: !MediaQuery.disableAnimationsOf(context),
      pageAnimationDuration: const Duration(milliseconds: 250),
      pageAnimationCurve: Curves.easeOut,
      formatAnimationCurve: Curves.easeOut,
      availableGestures: enableSwipe
          ? AvailableGestures.horizontalSwipe
          : AvailableGestures.none,
      rangeSelectionMode: RangeSelectionMode.disabled,
      startingDayOfWeek: firstDayOfWeek.toStartingDayOfWeek(),
      selectedDayPredicate: (day) =>
          selectedDay != null && isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,
      onPageChanged: onPageChanged,
      rowHeight: metrics.row,
      daysOfWeekHeight: metrics.dow,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: textTheme.titleMedium ?? const TextStyle(),
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: scheme.onSurface,
          semanticLabel: l10n.previousMonth,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: scheme.onSurface,
          semanticLabel: l10n.nextMonth,
        ),
        leftChevronPadding: const EdgeInsets.all(AppSpacing.s),
        rightChevronPadding: const EdgeInsets.all(AppSpacing.s),
        leftChevronMargin: EdgeInsets.zero,
        rightChevronMargin: EdgeInsets.zero,
        headerPadding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: weekday ?? const TextStyle(),
        weekendStyle: weekday ?? const TextStyle(),
      ),
      calendarStyle: const CalendarStyle(
        outsideDaysVisible: false,
        isTodayHighlighted: false,
        cellMargin: EdgeInsets.all(AppSpacing.xs),
      ),
      calendarBuilders: CalendarBuilders(
        prioritizedBuilder: (context, day, visibleMonth) {
          if (day.month != visibleMonth.month ||
              day.year != visibleMonth.year) {
            return const SizedBox.shrink();
          }
          return _DayCell(
            day: day,
            selected: selectedDay != null && isSameDay(selectedDay, day),
            detail: dayDetail?.call(context, day),
            reserveDetail: dayDetail != null,
          );
        },
      ),
    );
  }

  DateTime _clamp(DateTime day) {
    if (day.isBefore(firstDay)) {
      return firstDay;
    }
    if (day.isAfter(lastDay)) {
      return lastDay;
    }
    return day;
  }
}

class _DayCell extends StatelessWidget {
  final DateTime day;
  final bool selected;
  final Widget? detail;
  final bool reserveDetail;

  const _DayCell({
    required this.day,
    required this.selected,
    required this.detail,
    required this.reserveDetail,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = Padding(
      padding: const EdgeInsets.all(AppSpacing.s),
      child: Text(
        '${day.day}',
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: selected ? scheme.onPrimary : scheme.onSurface),
      ),
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: selected
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: label,
                )
              : label,
        ),
        if (reserveDetail)
          SizedBox(
            height: _detailExtent(context),
            child: detail == null
                ? null
                : FittedBox(fit: BoxFit.scaleDown, child: detail),
          ),
      ],
    );
  }
}

double _detailExtent(BuildContext context) {
  final style = Theme.of(context).textTheme.labelMedium!;
  return MediaQuery.textScalerOf(context)
      .scale(style.fontSize! * style.height!);
}
