import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/core/utils/money_format.dart';
import 'package:money_manager/models/category_defaults.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/analysis/widgets/analysis_frame.dart';
import 'package:money_manager/pages/analysis/widgets/analysis_month_bars.dart';
import 'package:money_manager/pages/analysis/widgets/analysis_total_row.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_event.dart';
import 'package:money_manager/pages/route_reload.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_event.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/themes/ledger_palette.dart';

class AnalysisBody extends StatefulWidget {
  const AnalysisBody({super.key});

  @override
  State<AnalysisBody> createState() => _AnalysisBodyState();
}

class _AnalysisBodyState extends State<AnalysisBody> with RouteReload {
  @override
  void reloadForRoute() {
    context.read<AccountsBloc>().add(const AccountsStarted());
    context.read<TransactionsBloc>().add(const TransactionsStarted());
    context.read<CategoriesBloc>().add(CategoriesStarted(defaultCategories()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final kind = AnalysisFrame.of(context).kind;
    final now = DateTime.now();
    final month = DateTime(now.year, now.month);
    final transactions = context.watch<TransactionsBloc>().state.transactions;
    final categories = context.watch<CategoriesBloc>().state.categories;
    final accounts = context.watch<AccountsBloc>().state.active;
    final rollup = _rollup(transactions, month, kind);
    final current = rollup.current;
    final previous = rollup.previous;
    final delta = current - previous;
    final months = rollup.months;
    final monthValues = rollup.monthValues;
    final maxValue = monthValues.fold<int>(
      1,
      (max, value) => value > max ? value : max,
    );
    final byCategory = rollup.byCategory;
    final byAccount = rollup.byAccount;
    final categoriesById = _firstById(categories, (category) => category.id);
    final accountsById = _firstById(accounts, (account) => account.id);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        Text(
          l10n.comparedWithLastMonth,
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        Text(
          formatMinor(current, locale: locale),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text(
          '${formatMinor(delta, locale: locale, signed: true)} · ${l10n.lastMonth} ${formatMinor(previous, locale: locale)}',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          l10n.lastSixMonths,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.m),
        AnalysisMonthBars(
          months: months,
          values: monthValues,
          maxValue: maxValue,
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(l10n.categories, style: Theme.of(context).textTheme.titleMedium),
        for (final entry in byCategory.entries)
          AnalysisTotalRow(
            color: LedgerPalette.color(
              categoriesById[entry.key]?.color ?? 'slate',
            ),
            title:
                categoriesById[entry.key]?.labelFor(
                  context.categoryLanguageCode,
                ) ??
                '',
            amount: formatMinor(entry.value, locale: locale),
            share: current == 0
                ? ''
                : '${(entry.value * 100 / current).round()}%',
          ),
        const SizedBox(height: AppSpacing.xl),
        Text(l10n.accounts, style: Theme.of(context).textTheme.titleMedium),
        for (final entry in byAccount.entries)
          AnalysisTotalRow(
            color: Theme.of(context).colorScheme.primary,
            title:
                accountsById[entry.key]?.labelFor(
                  context.categoryLanguageCode,
                ) ??
                '',
            amount: formatMinor(entry.value, locale: locale),
          ),
      ],
    );
  }
}

class _Rollup {
  _Rollup(this.months, this.monthValues, this.byCategory, this.byAccount);

  final List<DateTime> months;
  final List<int> monthValues;
  final Map<String?, int> byCategory;
  final Map<String?, int> byAccount;

  int get current => monthValues.last;

  int get previous => monthValues[monthValues.length - 2];
}

_Rollup _rollup(
  List<TransactionModel> transactions,
  DateTime month,
  CategoryKind kind,
) {
  final months = [
    for (var offset = 5; offset >= 0; offset--)
      DateTime(month.year, month.month - offset),
  ];
  final income = List<int>.filled(months.length, 0);
  final expense = List<int>.filled(months.length, 0);
  final indexByMonth = <int, int>{
    for (var index = 0; index < months.length; index++)
      months[index].year * 12 + months[index].month: index,
  };
  final currentKey = month.year * 12 + month.month;
  final byCategory = <String?, int>{};
  final byAccount = <String?, int>{};
  final wantExpense = kind == CategoryKind.expense;
  for (final transaction in transactions) {
    final index =
        indexByMonth[transaction.date.year * 12 + transaction.date.month];
    if (index == null) {
      continue;
    }
    if (transaction.type == TransactionType.income) {
      income[index] += transaction.amountMinor;
    } else if (transaction.type == TransactionType.expense) {
      expense[index] += transaction.amountMinor;
    } else {
      continue;
    }
    final matches = wantExpense
        ? transaction.type == TransactionType.expense
        : transaction.type == TransactionType.income;
    if (!matches ||
        transaction.date.year * 12 + transaction.date.month != currentKey) {
      continue;
    }
    final categoryId = transaction.categoryId;
    final accountId = transaction.accountId;
    byCategory[categoryId] =
        (byCategory[categoryId] ?? 0) + transaction.amountMinor;
    byAccount[accountId] =
        (byAccount[accountId] ?? 0) + transaction.amountMinor;
  }
  final totals = wantExpense ? expense : income;
  return _Rollup(
    months,
    totals,
    _sortedTotals(byCategory),
    _sortedTotals(byAccount),
  );
}

Map<String?, int> _sortedTotals(Map<String?, int> totals) {
  final entries = totals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return {for (final entry in entries) entry.key: entry.value};
}

Map<String, T> _firstById<T>(List<T> items, String Function(T item) idOf) {
  final index = <String, T>{};
  for (final item in items) {
    index.putIfAbsent(idOf(item), () => item);
  }
  return index;
}
