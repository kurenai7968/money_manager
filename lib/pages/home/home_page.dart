import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/core/extensions/context_extension.dart';

enum HomeView { summary, calendar }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeView _view = HomeView.summary;
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final showingSummary = _view == HomeView.summary;
    final locale = Localizations.localeOf(context).toString();
    final monthLabel = DateFormat.yMMMM(locale).format(_month);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: l10n.previousMonth,
              onPressed: () => _shiftMonth(-1),
              icon: const Icon(Icons.chevron_left),
            ),
            Flexible(
              child: Text(monthLabel, overflow: TextOverflow.ellipsis),
            ),
            IconButton(
              tooltip: l10n.nextMonth,
              onPressed: () => _shiftMonth(1),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: showingSummary ? l10n.showCalendar : l10n.showSummary,
            onPressed: _toggleView,
            icon: Icon(
              showingSummary
                  ? Icons.calendar_today_outlined
                  : Icons.bar_chart,
            ),
          ),
        ],
      ),
    );
  }

  void _shiftMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
    });
  }

  void _toggleView() {
    setState(() {
      _view = _view == HomeView.summary
          ? HomeView.calendar
          : HomeView.summary;
    });
  }
}
