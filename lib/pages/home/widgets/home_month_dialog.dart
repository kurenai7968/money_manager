import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/core/utils/cached_date_format.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/widgets/account_book_calendar.dart';

class HomeMonthDialog extends StatefulWidget {
  final DateTime month;

  const HomeMonthDialog({required this.month, super.key});

  @override
  State<HomeMonthDialog> createState() => _HomeMonthDialogState();
}

class _HomeMonthDialogState extends State<HomeMonthDialog> {
  late int _year = widget.month.year;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final scheme = Theme.of(context).colorScheme;
    final firstYear = AccountBookCalendar.firstDay.year;
    final lastYear = AccountBookCalendar.lastDay.year;
    return Dialog(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: context.l10n.previousYear,
                  onPressed: _year <= firstYear
                      ? null
                      : () => setState(() => _year -= 1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    cachedDateFormat(locale, 'y').format(DateTime(_year)),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.nextYear,
                  onPressed: _year >= lastYear
                      ? null
                      : () => setState(() => _year += 1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            for (var row = 0; row < 3; row++) ...[
              const SizedBox(height: AppSpacing.s),
              Row(
                children: [
                  for (var column = 0; column < 4; column++) ...[
                    if (column > 0) const SizedBox(width: AppSpacing.s),
                    Expanded(child: _month(context, row * 4 + column + 1)),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _month(BuildContext context, int month) {
    final locale = Localizations.localeOf(context).toString();
    final scheme = Theme.of(context).colorScheme;
    final selected = _year == widget.month.year && month == widget.month.month;
    final radius = BorderRadius.circular(AppRadius.m);
    return Material(
      color: selected ? scheme.primary : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: selected ? BorderSide.none : BorderSide(color: scheme.outline),
      ),
      child: InkWell(
        onTap: () => Navigator.pop(context, DateTime(_year, month)),
        customBorder: RoundedRectangleBorder(borderRadius: radius),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
          child: Text(
            cachedDateFormat(locale, 'MMM').format(DateTime(_year, month)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: selected ? scheme.onPrimary : scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
