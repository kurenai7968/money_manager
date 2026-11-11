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

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomeBloc>().state;
    final l10n = context.l10n;
    final showingSummary = state.view == HomeView.summary;
    final locale = Localizations.localeOf(context).toString();
    final monthLabel = cachedYearMonth(locale).format(state.month);
    return AppBar(
      leadingWidth: 120,
      leading: _HomeAccountButton(
        label: _accountLabel(context, state),
        tooltip: l10n.chooseAccount,
        onPressed: () => _pickAccount(context, state),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: l10n.previousMonth,
            onPressed: () =>
                context.read<HomeBloc>().add(const HomeMonthShifted(-1)),
            icon: const Icon(Icons.chevron_left),
          ),
          Flexible(child: Text(monthLabel, overflow: TextOverflow.ellipsis)),
          IconButton(
            tooltip: l10n.nextMonth,
            onPressed: () =>
                context.read<HomeBloc>().add(const HomeMonthShifted(1)),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: showingSummary ? l10n.showCalendar : l10n.showSummary,
          onPressed: () =>
              context.read<HomeBloc>().add(const HomeViewToggled()),
          icon: Icon(
            showingSummary ? Icons.calendar_today_outlined : Icons.bar_chart,
          ),
        ),
      ],
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
              if (!account.archived) account,
          ],
          selectedId: state.selectedAccountId,
        );
      },
    );
    if (picked != null && context.mounted) {
      context.read<HomeBloc>().add(HomeAccountSelected(picked.accountId));
    }
  }
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                const Icon(Icons.expand_more, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
