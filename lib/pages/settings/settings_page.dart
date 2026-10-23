import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/routes/app_routes.dart';
import 'package:money_manager/themes/app_themes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.xl,
              AppSpacing.l,
              AppSpacing.s,
            ),
            child: Text(
              l10n.categories,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ListTile(
            title: Text(l10n.categories),
            subtitle: Text(l10n.expenseAndIncome),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.categories.path),
          ),
        ],
      ),
    );
  }
}
