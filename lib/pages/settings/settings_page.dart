import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_bloc.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_event.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_state.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/models/enums/app_appearance.dart';
import 'package:money_manager/models/enums/week_start.dart';
import 'package:money_manager/pages/settings/widgets/settings_choice_sheet.dart';
import 'package:money_manager/pages/settings/widgets/settings_row.dart';
import 'package:money_manager/pages/settings/widgets/settings_section.dart';
import 'package:money_manager/routes/app_routes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: BlocBuilder<AppSettingBloc, AppSettingState>(
        builder: (context, state) {
          final setting = state.appSetting;
          return ListView(
            children: [
              SettingsSection(l10n.general),
              SettingsRow(
                title: l10n.language,
                value: switch (setting.languageCode) {
                  'zh' => l10n.traditionalChinese,
                  'zh_CN' => l10n.simplifiedChinese,
                  'en' => l10n.english,
                  _ => l10n.followSystem,
                },
                onTap: () => showSettingsChoice<String?>(
                  context,
                  title: l10n.language,
                  options: [
                    (null, l10n.followSystem),
                    ('zh', l10n.traditionalChinese),
                    ('zh_CN', l10n.simplifiedChinese),
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
              SettingsRow(
                title: l10n.appearance,
                value: switch (setting.appearance) {
                  AppAppearance.light => l10n.light,
                  AppAppearance.dark => l10n.dark,
                  AppAppearance.system => l10n.followSystem,
                },
                onTap: () => showSettingsChoice<AppAppearance>(
                  context,
                  title: l10n.appearance,
                  options: [
                    (AppAppearance.system, l10n.followSystem),
                    (AppAppearance.light, l10n.light),
                    (AppAppearance.dark, l10n.dark),
                  ],
                  selected: setting.appearance,
                  onSelected: (value) {
                    context.read<AppSettingBloc>().add(
                      AppSettingChanged(setting.copyWith(appearance: value)),
                    );
                  },
                ),
              ),
              SettingsRow(
                title: l10n.weekStart,
                value: setting.weekStart == WeekStart.monday
                    ? l10n.monday
                    : l10n.sunday,
                onTap: () => showSettingsChoice<WeekStart>(
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
              SettingsSection(l10n.ledger),
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
}
