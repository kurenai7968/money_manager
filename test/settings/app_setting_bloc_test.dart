import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_bloc.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_event.dart';
import 'package:money_manager/blocs/app_setting_bloc/app_setting_state.dart';
import 'package:money_manager/database/shared_preferences/settings_store.dart';
import 'package:money_manager/models/app_setting.dart';

void main() {
  late SettingsStore store;

  setUp(() {
    store = SettingsStore.memory();
  });

  blocTest<AppSettingBloc, AppSettingState>(
    'loads the default setting',
    build: () => AppSettingBloc(store),
    act: (bloc) => bloc.add(const AppSettingStarted()),
    verify: (bloc) {
      expect(bloc.state.setting, const AppSetting());
      expect(bloc.state.status, AppSettingStatus.success);
    },
  );

  blocTest<AppSettingBloc, AppSettingState>(
    'saves a theme change',
    build: () => AppSettingBloc(store),
    act: (bloc) => bloc.add(
      const AppSettingChanged(AppSetting(themeChoice: AppThemeChoice.dark)),
    ),
    verify: (bloc) async {
      expect(bloc.state.setting.themeChoice, AppThemeChoice.dark);
      expect((await store.load()).themeChoice, AppThemeChoice.dark);
    },
  );

  test('Sunday is the first column when the week starts on Sunday', () {
    expect(leadingCalendarBlanks(DateTime(2026, 10, 1), WeekStart.monday), 3);
    expect(leadingCalendarBlanks(DateTime(2026, 10, 1), WeekStart.sunday), 4);
  });
}
