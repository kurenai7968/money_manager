import 'package:flutter/material.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/themes/app_themes.dart';

class AppTabBar extends StatelessWidget {
  const AppTabBar({
    required this.selectedIndex,
    required this.onSelected,
    required this.onRecord,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Material(
      color: scheme.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: scheme.outline)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _TabItem(
                  selected: selectedIndex == 0,
                  icon: Icons.home_outlined,
                  label: l10n.home,
                  onTap: () => onSelected(0),
                ),
                _TabItem(
                  selected: selectedIndex == 1,
                  icon: Icons.pie_chart_outline,
                  label: l10n.analysis,
                  onTap: () => onSelected(1),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s,
                  ),
                  child: IconButton(
                    tooltip: l10n.record,
                    onPressed: onRecord,
                    style: IconButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      fixedSize: const Size.square(56),
                      shape: const CircleBorder(),
                    ),
                    icon: const Icon(Icons.add),
                  ),
                ),
                _TabItem(
                  selected: selectedIndex == 2,
                  icon: Icons.account_balance_wallet_outlined,
                  label: l10n.accounts,
                  onTap: () => onSelected(2),
                ),
                _TabItem(
                  selected: selectedIndex == 3,
                  icon: Icons.settings_outlined,
                  label: l10n.settings,
                  onTap: () => onSelected(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
