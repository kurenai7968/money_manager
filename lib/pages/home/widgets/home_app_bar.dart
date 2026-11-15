import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/core/utils/cached_date_format.dart';
import 'package:money_manager/pages/home/bloc/home_bloc.dart';
import 'package:money_manager/pages/home/bloc/home_event.dart';
import 'package:money_manager/pages/home/bloc/home_state.dart';
import 'package:money_manager/pages/home/models/home_account_pick.dart';
import 'package:money_manager/pages/home/widgets/home_account_sheet.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/widgets/account_book_sheet.dart';
import 'package:money_manager/widgets/base_app_bar.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomeBloc>().state;
    final l10n = context.l10n;
    final showingSummary = state.view == HomeView.summary;
    final locale = Localizations.localeOf(context).toString();
    final monthLabel = cachedDateFormat(locale, 'yyyy-MM').format(state.month);
    return BaseAppBar(
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _HomeAccountButton(
              label: _accountLabel(context, state),
              tooltip: l10n.chooseAccount,
              onPressed: () => _pickAccount(context, state),
            ),
          ),
          _BarIconButton(
            tooltip: l10n.previousMonth,
            icon: Icons.chevron_left,
            onPressed: () =>
                context.read<HomeBloc>().add(const HomeMonthShifted(-1)),
          ),
          Flexible(
            child: Text(
              monthLabel,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          _BarIconButton(
            tooltip: l10n.nextMonth,
            icon: Icons.chevron_right,
            onPressed: () =>
                context.read<HomeBloc>().add(const HomeMonthShifted(1)),
          ),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: _BarIconButton(
                tooltip: showingSummary ? l10n.showCalendar : l10n.showSummary,
                icon: showingSummary
                    ? Icons.calendar_today_outlined
                    : Icons.bar_chart,
                onPressed: () =>
                    context.read<HomeBloc>().add(const HomeViewToggled()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAccount(BuildContext context, HomeState state) async {
    final picked = await showAccountBookSheet<HomeAccountPick>(
      context: context,
      maxHeightFactor: 0.5,
      builder: (context) {
        return HomeAccountSheet(
          accounts: [
            for (final account in state.accounts)
              if (account.isActive) account,
          ],
          selectedId: state.selectedAccountId,
        );
      },
    );
    if (picked != null && context.mounted) {
      context.read<HomeBloc>().add(HomeAccountSelected(picked.accountId));
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

String _accountLabel(BuildContext context, HomeState state) {
  final selectedId = state.selectedAccountId;
  if (selectedId == null) {
    return context.l10n.allAccounts;
  }
  for (final account in state.accounts) {
    if (account.id == selectedId) {
      return account.labelFor(context.categoryLanguageCode);
    }
  }
  return context.l10n.allAccounts;
}

class _BarIconButton extends StatelessWidget {
  static const double extent = 32;

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  const _BarIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: 22,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.zero,
        minimumSize: const Size(extent, extent),
        fixedSize: const Size(extent, extent),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _HomeAccountButton extends StatelessWidget {
  final String label;
  final String tooltip;
  final VoidCallback onPressed;

  const _HomeAccountButton({
    required this.label,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: kToolbarHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final showIcon = constraints.maxWidth >= 36;
              return Row(
                children: [
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  if (showIcon) ...[
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(Icons.expand_more, size: 18),
                    const SizedBox(width: AppSpacing.s),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
