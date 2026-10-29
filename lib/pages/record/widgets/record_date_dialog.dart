import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/models/enums/week_start.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/widgets/ledger_calendar.dart';

class RecordDateDialog extends StatefulWidget {
  const RecordDateDialog({
    required this.initial,
    required this.weekStart,
    super.key,
  });

  final DateTime initial;
  final WeekStart weekStart;

  @override
  State<RecordDateDialog> createState() => _RecordDateDialogState();
}

class _RecordDateDialogState extends State<RecordDateDialog> {
  late DateTime _day = DateTime(
    widget.initial.year,
    widget.initial.month,
    widget.initial.day,
  );
  late DateTime _focused = _day;

  void _shiftMonth(int delta) {
    final next = DateTime(_focused.year, _focused.month + delta);
    if (next.isBefore(LedgerCalendar.firstDay) ||
        next.isAfter(LedgerCalendar.lastDay)) {
      return;
    }
    setState(() => _focused = next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();
    final screen = MediaQuery.sizeOf(context);
    final cap = AppSpacing.xl * 16;
    final available = screen.width - AppSpacing.l * 2;
    final width = available < cap ? available : cap;
    final maxHeight = screen.height - AppSpacing.xl * 2;
    return Dialog(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      child: SizedBox(
        width: width,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(AppSpacing.l),
            children: [
              Text(
                DateFormat.yMMMEd(locale).format(_day),
                style: textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              Row(
                children: [
                  IconButton(
                    tooltip: l10n.previousMonth,
                    onPressed: () => _shiftMonth(-1),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Text(
                      DateFormat.yMMMM(locale).format(_focused),
                      style: textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.nextMonth,
                    onPressed: () => _shiftMonth(1),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              SizedBox(
                height: LedgerCalendar.extent(context, header: false),
                child: LedgerCalendar(
                  focusedDay: _focused,
                  selectedDay: _day,
                  weekStart: widget.weekStart,
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _day = DateTime(
                        selected.year,
                        selected.month,
                        selected.day,
                      );
                      _focused = focused;
                    });
                  },
                  onPageChanged: (focused) {
                    if (focused.year == _focused.year &&
                        focused.month == _focused.month) {
                      return;
                    }
                    setState(() => _focused = focused);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, _day),
                    child: Text(l10n.done),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
