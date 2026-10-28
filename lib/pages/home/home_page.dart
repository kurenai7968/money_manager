import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_bloc.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/core/utils/ledger_balance.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/home/widgets/home_calendar_view.dart';
import 'package:money_manager/pages/home/widgets/home_summary_view.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';

enum HomeView { summary, calendar }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeView _view = HomeView.summary;
  late DateTime _month;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final showingSummary = _view == HomeView.summary;
    final locale = Localizations.localeOf(context).toString();
    final monthLabel = DateFormat.yMMMM(locale).format(_month);
    final transactions = context.watch<TransactionsBloc>().state.transactions;
    final categories = context.watch<CategoriesBloc>().state.categories;
    final inMonth = transactions
        .where(
          (item) =>
              item.date.year == _month.year && item.date.month == _month.month,
        )
        .toList();
    final weekStart = context
        .watch<AppSettingBloc>()
        .state
        .appSetting
        .weekStart;
    final figures = monthFigures(transactions, _month);

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
            Flexible(child: Text(monthLabel, overflow: TextOverflow.ellipsis)),
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
              showingSummary ? Icons.calendar_today_outlined : Icons.bar_chart,
            ),
          ),
        ],
      ),
      body: showingSummary
          ? HomeSummaryView(
              figures: figures,
              transactions: inMonth,
              categories: categories,
              locale: locale,
            )
          : HomeCalendarView(
              month: _month,
              transactions: inMonth,
              categories: categories,
              selectedDay: _selectedDay,
              weekStart: weekStart,
              locale: locale,
              onSelect: (day) => setState(() => _selectedDay = day),
            ),
    );
  }

  void _shiftMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
      _selectedDay = null;
    });
  }

  void _toggleView() {
    setState(() {
      _view = _view == HomeView.summary ? HomeView.calendar : HomeView.summary;
    });
  }
}
