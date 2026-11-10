import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/core/utils/money_format.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/pages/analysis/bloc/analysis_bloc.dart';
import 'package:money_manager/pages/analysis/bloc/analysis_event.dart';
import 'package:money_manager/pages/analysis/widgets/analysis_month_bars.dart';
import 'package:money_manager/pages/analysis/widgets/analysis_total_row.dart';
import 'package:money_manager/pages/route_reload.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/themes/account_book_palette.dart';

class AnalysisBody extends StatefulWidget {
  const AnalysisBody({super.key});

  @override
  State<AnalysisBody> createState() => _AnalysisBodyState();
}

class _AnalysisBodyState extends State<AnalysisBody> with RouteReload {
  @override
  void reloadForRoute() {
    context.read<AnalysisBloc>().add(const AnalysisInitialized());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final state = context.watch<AnalysisBloc>().state;
    final rollup = state.rollup;
    final current = rollup.current;
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
          '${formatMinor(rollup.delta, locale: locale, signed: true)} · ${l10n.lastMonth} ${formatMinor(rollup.previous, locale: locale)}',
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
          months: rollup.months,
          values: rollup.monthValues,
          maxValue: rollup.maxValue,
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(l10n.categories, style: Theme.of(context).textTheme.titleMedium),
        for (final entry in rollup.byCategory)
          AnalysisTotalRow(
            color: AccountBookPalette.color(
              _category(state.categories, entry.id)?.color ?? 'slate',
            ),
            title:
                _category(
                  state.categories,
                  entry.id,
                )?.labelFor(context.categoryLanguageCode) ??
                '',
            amount: formatMinor(entry.amountMinor, locale: locale),
            share: entry.sharePercent == null ? '' : '${entry.sharePercent}%',
          ),
        const SizedBox(height: AppSpacing.xl),
        Text(l10n.accounts, style: Theme.of(context).textTheme.titleMedium),
        for (final entry in rollup.byAccount)
          AnalysisTotalRow(
            color: Theme.of(context).colorScheme.primary,
            title:
                _account(
                  state.accounts,
                  entry.id,
                )?.labelFor(context.categoryLanguageCode) ??
                '',
            amount: formatMinor(entry.amountMinor, locale: locale),
          ),
      ],
    );
  }
}

CategoryModel? _category(List<CategoryModel> categories, String? id) {
  for (final category in categories) {
    if (category.id == id) {
      return category;
    }
  }
  return null;
}

AccountModel? _account(List<AccountModel> accounts, String? id) {
  for (final account in accounts) {
    if (account.id == id) {
      return account;
    }
  }
  return null;
}
