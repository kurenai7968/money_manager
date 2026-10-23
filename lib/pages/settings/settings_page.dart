import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_bloc.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_event.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_state.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/models/app_setting.dart';
import 'package:money_manager/routes/app_routes.dart';
import 'package:money_manager/themes/app_themes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: BlocBuilder<AppSettingBloc, AppSettingState>(
        builder: (context, state) {
          final setting = state.setting;
          return ListView(
            children: [
              _Section(l10n.general),
              _Row(
                title: l10n.language,
                value: switch (setting.languageCode) {
                  'zh' => l10n.traditionalChinese,
                  'en' => l10n.english,
                  _ => l10n.followSystem,
                },
                onTap: () => _choose<String?>(
                  context,
                  title: l10n.language,
                  options: [
                    (null, l10n.followSystem),
                    ('zh', l10n.traditionalChinese),
                    ('en', l10n.english),
                  ],
                  selected: setting.languageCode,
                  onSelected: (value) {
                    context.read<AppSettingBloc>().add(
                      AppSettingChanged(
                        setting.copyWith(
                          languageCode: value,
                          clearLanguage: value == null,
                        ),
                      ),
                    );
                  },
                ),
              ),
              _Row(
                title: l10n.appearance,
                value: switch (setting.themeChoice) {
                  AppThemeChoice.light => l10n.light,
                  AppThemeChoice.dark => l10n.dark,
                  AppThemeChoice.system => l10n.followSystem,
                },
                onTap: () => _choose<AppThemeChoice>(
                  context,
                  title: l10n.appearance,
                  options: [
                    (AppThemeChoice.system, l10n.followSystem),
                    (AppThemeChoice.light, l10n.light),
                    (AppThemeChoice.dark, l10n.dark),
                  ],
                  selected: setting.themeChoice,
                  onSelected: (value) {
                    context.read<AppSettingBloc>().add(
                      AppSettingChanged(setting.copyWith(themeChoice: value)),
                    );
                  },
                ),
              ),
              _Row(
                title: l10n.currency,
                value: setting.currency,
                onTap: () => _editCurrency(context, setting),
              ),
              _Row(
                title: l10n.weekStart,
                value: setting.weekStart == WeekStart.monday
                    ? l10n.monday
                    : l10n.sunday,
                onTap: () => _choose<WeekStart>(
                  context,
                  title: l10n.weekStart,
                  options: [
                    (WeekStart.monday, l10n.monday),
                    (WeekStart.sunday, l10n.sunday),
                  ],
                  selected: setting.weekStart,
                  onSelected: (value) {
                    context.read<AppSettingBloc>().add(
                      AppSettingChanged(setting.copyWith(weekStart: value)),
                    );
                  },
                ),
              ),
              _Section(l10n.ledger),
              ListTile(
                title: Text(l10n.categories),
                subtitle: Text(l10n.expenseAndIncome),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.categories.path),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _editCurrency(BuildContext context, AppSetting setting) async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: setting.currency);
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.currency),
          content: TextField(controller: controller, autofocus: true),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (result != null && result.isNotEmpty && context.mounted) {
      context.read<AppSettingBloc>().add(
        AppSettingChanged(setting.copyWith(currency: result.toUpperCase())),
      );
    }
  }
}

class _Section extends StatelessWidget {
  const _Section(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.xl,
        AppSpacing.l,
        AppSpacing.s,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.title, required this.value, required this.onTap});

  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }
}

Future<void> _choose<T>(
  BuildContext context, {
  required String title,
  required List<(T, String)> options,
  required T selected,
  required ValueChanged<T> onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final option in options)
              ListTile(
                title: Text(option.$2),
                trailing: option.$1 == selected
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  onSelected(option.$1);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      );
    },
  );
}
