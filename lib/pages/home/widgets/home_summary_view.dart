import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/core/utils/money_format.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/day_account_book.dart';
import 'package:money_manager/pages/home/widgets/home_month_donut.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/widgets/transaction_item.dart';

class HomeSummaryView extends StatelessWidget {
  final double income;
  final double expense;
  final double balance;
  final List<DayAccountBook> days;
  final List<CategoryModel> categories;
  final List<AccountModel> accounts;
  final String locale;
  final EdgeInsets listPadding;
  final VoidCallback onRecordReturned;

  const HomeSummaryView({
    required this.income,
    required this.expense,
    required this.balance,
    required this.days,
    required this.categories,
    required this.accounts,
    required this.locale,
    required this.listPadding,
    required this.onRecordReturned,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
                      context.l10n.income,
                      style: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    Text(
                      formatAmount(income, locale: locale),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: context.accountBookColor(income: true),
                      ),
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
                      context.l10n.expense,
                      style: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    Text(
                      formatAmount(expense, locale: locale),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: context.accountBookColor(income: false),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        HomeMonthDonut(
          income: income,
          expense: expense,
          label: context.l10n.monthBalance,
          amount: formatAmount(balance, locale: locale),
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
              context.l10n.recent,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        Expanded(
          child: days.isEmpty
              ? Center(child: Text(context.l10n.emptyMonth))
              : TransactionList(
                  days: days,
                  categories: categories,
                  accounts: accounts,
                  locale: locale,
                  padding: listPadding,
                  onReturned: onRecordReturned,
                ),
        ),
      ],
    );
  }
}
