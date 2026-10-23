import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_bloc.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/core/utils/ledger_balance.dart';
import 'package:money_manager/models/app_setting.dart';
import 'package:money_manager/core/utils/money_format.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/routes/app_routes.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/themes/ledger_palette.dart';

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
    final weekStart = context.watch<AppSettingBloc>().state.setting.weekStart;
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
          ? _SummaryView(
              figures: figures,
              transactions: inMonth,
              categories: categories,
              locale: locale,
            )
          : _CalendarView(
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

class _SummaryView extends StatelessWidget {
  const _SummaryView({
    required this.figures,
    required this.transactions,
    required this.categories,
    required this.locale,
  });

  final MonthFigures figures;
  final List<TransactionModel> transactions;
  final List<CategoryModel> categories;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.s,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.income,
                      style: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    Text(
                      formatMinor(figures.incomeMinor, locale: locale),
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(color: LedgerPalette.green),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 36, color: scheme.outline),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.expense,
                      style: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    Text(
                      formatMinor(figures.expenseMinor, locale: locale),
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(color: scheme.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _MonthDonut(
          income: figures.incomeMinor,
          expense: figures.expenseMinor,
          label: l10n.monthBalance,
          amount: formatMinor(figures.balanceMinor, locale: locale),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.xl,
            AppSpacing.l,
            AppSpacing.s,
          ),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              l10n.recent,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        Expanded(
          child: transactions.isEmpty
              ? Center(child: Text(l10n.emptyMonth))
              : ListView.separated(
                  itemCount: transactions.length,
                  separatorBuilder: (_, _) =>
                      Divider(height: 1, color: scheme.outline),
                  itemBuilder: (context, index) {
                    return _TransactionTile(
                      transaction: transactions[index],
                      categories: categories,
                      locale: locale,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _MonthDonut extends StatelessWidget {
  const _MonthDonut({
    required this.income,
    required this.expense,
    required this.label,
    required this.amount,
  });

  final int income;
  final int expense;
  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: CustomPaint(
        painter: _DonutPainter(
          income: income,
          expense: expense,
          incomeColor: LedgerPalette.green,
          expenseColor: Theme.of(context).colorScheme.primary,
          trackColor: Theme.of(context).colorScheme.outline,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(amount, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.income,
    required this.expense,
    required this.incomeColor,
    required this.expenseColor,
    required this.trackColor,
  });

  final int income;
  final int expense;
  final Color incomeColor;
  final Color expenseColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.butt;
    final center = rect.center;
    final radius = size.shortestSide / 2 - 16;
    final arc = Rect.fromCircle(center: center, radius: radius);
    final total = income + expense;
    if (total == 0) {
      paint.color = trackColor;
      canvas.drawCircle(center, radius, paint);
      return;
    }
    final incomeSweep = (income / total) * math.pi * 2;
    paint.color = incomeColor;
    canvas.drawArc(arc, -math.pi / 2, incomeSweep, false, paint);
    paint.color = expenseColor;
    canvas.drawArc(
      arc,
      -math.pi / 2 + incomeSweep,
      math.pi * 2 - incomeSweep,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.income != income || oldDelegate.expense != expense;
  }
}

class _CalendarView extends StatelessWidget {
  const _CalendarView({
    required this.month,
    required this.transactions,
    required this.categories,
    required this.selectedDay,
    required this.weekStart,
    required this.locale,
    required this.onSelect,
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
    final first = DateTime(month.year, month.month);
    final days = DateTime(month.year, month.month + 1, 0).day;
    final leading = leadingCalendarBlanks(first, weekStart);
    final selected = selectedDay;
    final dayItems = selected == null
        ? const <TransactionModel>[]
        : transactions.where((item) => sameDay(item.date, selected)).toList();
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.l),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
            ),
            itemCount: leading + days,
            itemBuilder: (context, index) {
              if (index < leading) {
                return const SizedBox.shrink();
              }
              final day = index - leading + 1;
              final date = DateTime(month.year, month.month, day);
              final net = _dayNet(date);
              final isSelected = selected != null && sameDay(selected, date);
              return InkWell(
                onTap: () => onSelect(date),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: isSelected
                          ? scheme.primary
                          : scheme.surface,
                      child: Text(
                        '$day',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: isSelected
                                  ? scheme.onPrimary
                                  : scheme.onSurface,
                            ),
                      ),
                    ),
                    if (net != 0)
                      Text(
                        formatMinor(net, locale: locale, signed: true),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: net > 0
                                  ? LedgerPalette.green
                                  : scheme.primary,
                              height: 1.2,
                            ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        if (selected != null)
          SizedBox(
            height: 160,
            child: dayItems.isEmpty
                ? const SizedBox.shrink()
                : ListView.separated(
                    itemCount: dayItems.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, color: scheme.outline),
                    itemBuilder: (context, index) {
                      return _TransactionTile(
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

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.categories,
    required this.locale,
  });

  final TransactionModel transaction;
  final List<CategoryModel> categories;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final category = categories.where(
      (item) => item.id == transaction.categoryId,
    );
    final title = transaction.note.isNotEmpty
        ? transaction.note
        : (category.isEmpty ? transaction.type.name : category.first.name);
    final color = switch (transaction.type) {
      TransactionType.income => LedgerPalette.green,
      TransactionType.expense => scheme.primary,
      TransactionType.transfer => scheme.onSurface,
    };
    final signed = transaction.type == TransactionType.transfer
        ? formatMinor(transaction.amountMinor, locale: locale)
        : formatMinor(
            transaction.type == TransactionType.expense
                ? -transaction.amountMinor
                : transaction.amountMinor,
            locale: locale,
            signed: true,
          );
    return ListTile(
      onTap: () =>
          context.push('${AppRoutes.record.path}?id=${transaction.id}'),
      title: Text(title),
      subtitle: Text(DateFormat.MMMd(locale).format(transaction.date)),
      trailing: Text(
        signed,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
      ),
    );
  }
}
