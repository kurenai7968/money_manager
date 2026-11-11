import 'dart:convert';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app_config.dart';
import 'package:money_manager/core/errors/app_exception.dart';
import 'package:money_manager/database/shared_preferences/shared_preference_store.dart';
import 'package:money_manager/models/app_setting_model.dart';
import 'package:money_manager/models/enums/app_theme_mode.dart';
import 'package:money_manager/models/enums/first_day_of_week.dart';
import 'package:money_manager/repositories/app_setting_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences preferences;
  late AppSettingRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    repository = AppSettingRepositoryImpl(
      store: SharedPreferenceStore(preferences),
    );
  });

  test('saves and loads the setting as one JSON value', () async {
    const setting = AppSettingModel(
      languageCode: 'zh',
      countryCode: 'CN',
      appThemeMode: AppThemeMode.dark,
      firstDayOfWeek: FirstDayOfWeek.wednesday,
    );

    await repository.updateLanguage(setting.languageCode, setting.countryCode);
    await repository.updateThemeMode(setting.appThemeMode);
    await repository.updateFirstDayOfWeek(setting.firstDayOfWeek);

    expect(jsonDecode(preferences.getString(AppConfig.appSettingKey)!), {
      'language_code': 'zh',
      'country_code': 'CN',
      'appearance': 'dark',
      'first_day_of_week': 'wednesday',
    });
    expect(await repository.getAppSetting(), setting);
    expect(setting.locale, const Locale('zh', 'CN'));
  });

  test('loads defaults when nothing is stored', () async {
    final loaded = await repository.getAppSetting();

    expect(loaded, const AppSettingModel());
    expect(loaded.locale, isNull);
  });

  test('stores an empty language when the app follows the system', () async {
    await repository.updateLanguage('en', '');
    expect((await repository.getAppSetting()).locale, const Locale('en'));

    await repository.updateLanguage('', '');
    await repository.updateThemeMode(AppThemeMode.light);

    final loaded = await repository.getAppSetting();
    expect(loaded.languageCode, isEmpty);
    expect(loaded.countryCode, isEmpty);
    expect(loaded.locale, isNull);
    expect(loaded.appThemeMode, AppThemeMode.light);
  });

  test('rejects JSON that is not an object', () async {
    await preferences.setString(AppConfig.appSettingKey, '[]');

    expect(repository.getAppSetting(), throwsA(isA<CacheException>()));
  });

  test('rejects an unrecognized appearance', () async {
    await preferences.setString(
      AppConfig.appSettingKey,
      jsonEncode({
        'language_code': 'en',
        'country_code': '',
        'appearance': 'sepia',
        'first_day_of_week': 'monday',
      }),
    );

    expect(repository.getAppSetting(), throwsA(isA<CacheException>()));
  });
}
