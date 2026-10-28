import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/core/utils/ledger_balance.dart';
import 'package:money_manager/core/utils/money_format.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/home/widgets/home_month_donut.dart';
import 'package:money_manager/pages/home/widgets/home_transaction_tile.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/themes/ledger_palette.dart';

class HomeSummaryView extends StatelessWidget {
  const HomeSummaryView({
    required this.figures,
    required this.transactions,
    required this.categories,
    required this.locale,
    super.key,
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
        HomeMonthDonut(
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
                    return HomeTransactionTile(
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
