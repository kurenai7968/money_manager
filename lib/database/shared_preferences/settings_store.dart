import 'package:money_manager/models/app_setting.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsStore {
  SettingsStore(this._preferences);

  SettingsStore.memory() : _preferences = null;

  static const languageKey = 'language';
  static const themeKey = 'theme';
  static const weekStartKey = 'week_start';

  final SharedPreferences? _preferences;
  AppSetting _memory = const AppSetting();

  Future<AppSetting> load() async {
    final preferences = _preferences;
    if (preferences == null) {
      return _memory;
    }
    final themeName = preferences.getString(themeKey);
    final weekName = preferences.getString(weekStartKey);
    return AppSetting(
      languageCode: preferences.getString(languageKey),
      themeChoice: themeName == null
          ? AppThemeChoice.system
          : AppThemeChoice.values.byName(themeName),
      weekStart: weekName == null
          ? WeekStart.monday
          : WeekStart.values.byName(weekName),
    );
  }

  Future<void> save(AppSetting setting) async {
    final preferences = _preferences;
    if (preferences == null) {
      _memory = setting;
      return;
    }
    if (setting.languageCode == null) {
      await preferences.remove(languageKey);
    } else {
      await preferences.setString(languageKey, setting.languageCode!);
    }
    await preferences.setString(themeKey, setting.themeChoice.name);
    await preferences.setString(weekStartKey, setting.weekStart.name);
  }
}
