import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_bloc.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_event.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_state.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/models/enums/app_theme_mode.dart';
import 'package:money_manager/models/enums/first_day_of_week.dart';
import 'package:money_manager/models/enums/ledger_color.dart';
import 'package:money_manager/pages/settings/widgets/settings_choice_sheet.dart';
import 'package:money_manager/themes/account_book_palette.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/pages/settings/widgets/settings_row.dart';
import 'package:money_manager/pages/settings/widgets/settings_section.dart';
import 'package:money_manager/routes/app_routes.dart';

class SettingsBody extends StatelessWidget {
  const SettingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingBloc, AppSettingState>(
      builder: (context, state) {
        final setting = state.appSetting;
        return ListView(
          children: [
            SettingsSection(context.l10n.general),
            SettingsRow(
              title: context.l10n.language,
              value: switch ((setting.languageCode, setting.countryCode)) {
                ('zh', 'CN') => context.l10n.simplifiedChinese,
                ('zh', _) => context.l10n.traditionalChinese,
                ('en', _) => context.l10n.english,
                _ => context.l10n.followSystem,
              },
              onTap: () => showSettingsChoice<(String, String)>(
                context,
                title: context.l10n.language,
                options: [
                  (('', ''), context.l10n.followSystem),
                  (('zh', ''), context.l10n.traditionalChinese),
                  (('zh', 'CN'), context.l10n.simplifiedChinese),
                  (('en', ''), context.l10n.english),
                ],
                selected: (setting.languageCode, setting.countryCode),
                onSelected: (value) {
                  context.read<AppSettingBloc>().add(
                    AppSettingLanguageChanged(
                      languageCode: value.$1,
                      countryCode: value.$2,
                    ),
                  );
                },
              ),
            ),
            SettingsRow(
              title: context.l10n.appearance,
              value: switch (setting.appThemeMode) {
                AppThemeMode.light => context.l10n.light,
                AppThemeMode.dark => context.l10n.dark,
                AppThemeMode.system => context.l10n.followSystem,
              },
              onTap: () => showSettingsChoice<AppThemeMode>(
                context,
                title: context.l10n.appearance,
                options: [
                  (AppThemeMode.system, context.l10n.followSystem),
                  (AppThemeMode.light, context.l10n.light),
                  (AppThemeMode.dark, context.l10n.dark),
                ],
                selected: setting.appThemeMode,
                onSelected: (value) {
                  context.read<AppSettingBloc>().add(
                    AppSettingThemeModeChanged(appThemeMode: value),
                  );
                },
              ),
            ),
            SettingsRow(
              title: context.l10n.weekStart,
              value: _weekdayLabel(context.l10n, setting.firstDayOfWeek),
              onTap: () => showSettingsChoice<FirstDayOfWeek>(
                context,
                title: context.l10n.weekStart,
                options: [
                  for (final day in FirstDayOfWeek.values)
                    (day, _weekdayLabel(context.l10n, day)),
                ],
                selected: setting.firstDayOfWeek,
                onSelected: (value) {
                  context.read<AppSettingBloc>().add(
                    AppSettingFirstDayOfWeekChanged(firstDayOfWeek: value),
                  );
                },
              ),
            ),
            SettingsSection(context.l10n.accountBook),
            SettingsRow(
              title: context.l10n.color,
              value: _pairLabel(context.l10n, setting.colorPair),
              swatches: [
                AccountBookPalette.of(setting.expenseColor),
                AccountBookPalette.of(setting.incomeColor),
              ],
              onTap: () => showSettingsChoice<LedgerColorPair>(
                context,
                title: context.l10n.color,
                options: [
                  for (final pair in LedgerColorPair.values)
                    (pair, _pairLabel(context.l10n, pair)),
                ],
                selected: setting.colorPair,
                leading: _pairDots,
                onSelected: (value) {
                  context.read<AppSettingBloc>().add(
                    AppSettingColorPairChanged(colorPair: value),
                  );
                },
              ),
            ),
            ListTile(
              title: Text(context.l10n.categories),
              subtitle: Text(context.l10n.expenseAndIncome),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.categories.path),
            ),
          ],
        );
      },
    );
  }
}

String _pairLabel(AppLocalizations l10n, LedgerColorPair pair) {
  return '${_ledgerColorLabel(l10n, pair.expense)} / ${_ledgerColorLabel(l10n, pair.income)}';
}

Widget _pairDots(LedgerColorPair pair) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _colorDot(pair.expense),
      const SizedBox(width: AppSpacing.xs),
      _colorDot(pair.income),
    ],
  );
}

String _ledgerColorLabel(AppLocalizations l10n, LedgerColor color) {
  return switch (color) {
    LedgerColor.coral => l10n.colorCoral,
    LedgerColor.red => l10n.colorRed,
    LedgerColor.blue => l10n.colorBlue,
    LedgerColor.amber => l10n.colorAmber,
    LedgerColor.teal => l10n.colorTeal,
    LedgerColor.pink => l10n.colorPink,
    LedgerColor.green => l10n.colorGreen,
    LedgerColor.slate => l10n.colorSlate,
  };
}

Widget _colorDot(LedgerColor color) {
  return DecoratedBox(
    decoration: BoxDecoration(
      color: AccountBookPalette.of(color),
      shape: BoxShape.circle,
    ),
    child: const SizedBox.square(dimension: 12),
  );
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
