import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/app_config.dart';
import 'package:money_manager/database/shared_preferences/shared_preference_store.dart';
import 'package:money_manager/models/app_setting_model.dart';
import 'package:money_manager/models/enums/app_appearance.dart';
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

  test('saves appearance under the existing theme key', () async {
    await repository.updateAppSetting(
      const AppSettingModel(
        languageCode: 'zh',
        appearance: AppAppearance.dark,
        firstDayOfWeek: FirstDayOfWeek.wednesday,
      ),
    );

    expect(preferences.getString(AppConfig.languageKey), 'zh');
    expect(preferences.getString(AppConfig.themeKey), 'dark');
    expect(preferences.getString(AppConfig.weekStartKey), 'wednesday');

    final loaded = await repository.getAppSetting();
    expect(loaded.languageCode, 'zh');
    expect(loaded.appearance, AppAppearance.dark);
    expect(loaded.firstDayOfWeek, FirstDayOfWeek.wednesday);
  });

  test('clears a language that follows the system', () async {
    await repository.updateAppSetting(
      const AppSettingModel(languageCode: 'en'),
    );
    await repository.updateAppSetting(
      const AppSettingModel(appearance: AppAppearance.light),
    );

    expect(preferences.getString(AppConfig.languageKey), isNull);
    final loaded = await repository.getAppSetting();
    expect(loaded.languageCode, isNull);
    expect(loaded.appearance, AppAppearance.light);
  });
}
