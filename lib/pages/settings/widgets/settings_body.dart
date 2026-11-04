import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_bloc.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_event.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_state.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/models/enums/app_appearance.dart';
import 'package:money_manager/models/enums/first_day_of_week.dart';
import 'package:money_manager/pages/settings/widgets/settings_choice_sheet.dart';
import 'package:money_manager/pages/settings/widgets/settings_row.dart';
import 'package:money_manager/pages/settings/widgets/settings_section.dart';
import 'package:money_manager/routes/app_routes.dart';

class SettingsBody extends StatelessWidget {
  const SettingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<AppSettingBloc, AppSettingState>(
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
              value: _weekdayLabel(l10n, setting.firstDayOfWeek),
              onTap: () => showSettingsChoice<FirstDayOfWeek>(
                context,
                title: l10n.weekStart,
                options: [
                  for (final day in FirstDayOfWeek.values)
                    (day, _weekdayLabel(l10n, day)),
                ],
                selected: setting.firstDayOfWeek,
                onSelected: (value) {
                  context.read<AppSettingBloc>().add(
                    AppSettingChanged(setting.copyWith(firstDayOfWeek: value)),
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
    );
  }
}

String _weekdayLabel(AppLocalizations l10n, FirstDayOfWeek day) {
  return switch (day) {
    FirstDayOfWeek.monday => l10n.monday,
    FirstDayOfWeek.tuesday => l10n.tuesday,
    FirstDayOfWeek.wednesday => l10n.wednesday,
    FirstDayOfWeek.thursday => l10n.thursday,
    FirstDayOfWeek.friday => l10n.friday,
    FirstDayOfWeek.saturday => l10n.saturday,
    FirstDayOfWeek.sunday => l10n.sunday,
  };
}
