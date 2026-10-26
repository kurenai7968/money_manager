import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/core/utils/ledger_balance.dart';
import 'package:money_manager/core/utils/money_format.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/themes/ledger_palette.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  CategoryKind _kind = CategoryKind.expense;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final month = DateTime(now.year, now.month);
    final transactions = context.watch<TransactionsBloc>().state.transactions;
    final categories = context.watch<CategoriesBloc>().state.categories;
    final accounts = context.watch<AccountsBloc>().state.active;
    final current = _total(transactions, month);
    final previous = _total(
      transactions,
      DateTime(month.year, month.month - 1),
    );
    final delta = current - previous;
    final months = [
      for (var offset = 5; offset >= 0; offset--)
        DateTime(month.year, month.month - offset),
    ];
    final monthValues = [for (final item in months) _total(transactions, item)];
    final maxValue = monthValues.fold<int>(
      1,
      (max, value) => value > max ? value : max,
    );
    final byCategory = _grouped(transactions, month, (item) => item.categoryId);
    final byAccount = _grouped(transactions, month, (item) => item.accountId);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analysis),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => setState(() => _kind = CategoryKind.expense),
                child: Text(
                  l10n.expense,
                  style: TextStyle(
                    color: _kind == CategoryKind.expense
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _kind = CategoryKind.income),
                child: Text(
                  l10n.income,
                  style: TextStyle(
                    color: _kind == CategoryKind.income
                        ? LedgerPalette.green
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          Text(
            l10n.comparedWithLastMonth,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            formatMinor(current, locale: locale),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            '${formatMinor(delta, locale: locale, signed: true)} · ${l10n.lastMonth} ${formatMinor(previous, locale: locale)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.lastSixMonths,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.m),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var index = 0; index < months.length; index++)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: monthValues[index] / maxValue,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: index == months.length - 1
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text('${months[index].month}'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.categories, style: Theme.of(context).textTheme.titleMedium),
          for (final entry in byCategory.entries)
            _TotalRow(
              color: LedgerPalette.color(_colorKey(categories, entry.key)),
              title: _categoryName(
                categories,
                entry.key,
                context.categoryLanguageCode,
              ),
              amount: formatMinor(entry.value, locale: locale),
              share: current == 0
                  ? ''
                  : '${(entry.value * 100 / current).round()}%',
            ),
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.accounts, style: Theme.of(context).textTheme.titleMedium),
          for (final entry in byAccount.entries)
            _TotalRow(
              color: Theme.of(context).colorScheme.primary,
              title: _accountName(
                accounts,
                entry.key,
                context.categoryLanguageCode,
              ),
              amount: formatMinor(entry.value, locale: locale),
            ),
        ],
      ),
    );
  }

  int _total(List<TransactionModel> transactions, DateTime month) {
    final figures = monthFigures(transactions, month);
    return _kind == CategoryKind.expense
        ? figures.expenseMinor
        : figures.incomeMinor;
  }

  Map<String?, int> _grouped(
    List<TransactionModel> transactions,
    DateTime month,
    String? Function(TransactionModel transaction) keyOf,
  ) {
    final totals = <String?, int>{};
    for (final transaction in transactions) {
      final matchesKind = _kind == CategoryKind.expense
          ? transaction.type == TransactionType.expense
          : transaction.type == TransactionType.income;
      if (!matchesKind ||
          transaction.date.year != month.year ||
          transaction.date.month != month.month) {
        continue;
      }
      final key = keyOf(transaction);
      totals[key] = (totals[key] ?? 0) + transaction.amountMinor;
    }
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return {for (final entry in entries) entry.key: entry.value};
  }
}

String _colorKey(List<CategoryModel> categories, String? id) {
  for (final category in categories) {
    if (category.id == id) {
      return category.color;
    }
  }
  return 'slate';
}

String _categoryName(
  List<CategoryModel> categories,
  String? id,
  String languageCode,
) {
  for (final category in categories) {
    if (category.id == id) {
      return category.labelFor(languageCode);
    }
  }
  return '';
}

String _accountName(
  List<AccountModel> accounts,
  String? id,
  String languageCode,
) {
  for (final account in accounts) {
    if (account.id == id) {
      return account.labelFor(languageCode);
    }
  }
  return '';
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.color,
    required this.title,
    required this.amount,
    this.share = '',
  });

  final Color color;
  final String title;
  final String amount;
  final String share;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.circle, color: color, size: 12),
      title: Text(title),
      trailing: Text(share.isEmpty ? amount : '$share  $amount'),
    );
  }
}
