import 'package:money_manager/app_config.dart';
import 'package:money_manager/core/errors/app_exception.dart';
import 'package:money_manager/database/shared_preferences/shared_preference_store.dart';
import 'package:money_manager/models/app_setting_model.dart';
import 'package:money_manager/models/enums/app_appearance.dart';
import 'package:money_manager/models/enums/week_start.dart';

abstract interface class AppSettingRepository {
  Future<AppSettingModel> getAppSetting();

  Future<void> updateAppSetting(AppSettingModel appSetting);
}

class AppSettingRepositoryImpl implements AppSettingRepository {
  AppSettingRepositoryImpl({required this.store});

  final SharedPreferenceStore store;

  @override
  Future<AppSettingModel> getAppSetting() async {
    try {
      return AppSettingModel(
        languageCode: store.getString(AppConfig.languageKey),
        appearance: _appearance(store.getString(AppConfig.themeKey)),
        weekStart: _weekStart(store.getString(AppConfig.weekStartKey)),
      );
    } on AppException {
      rethrow;
    } catch (error) {
      throw CacheException('App setting could not be read. $error');
    }
  }

  @override
  Future<void> updateAppSetting(AppSettingModel appSetting) async {
    try {
      final languageCode = appSetting.languageCode;
      if (languageCode == null) {
        await store.remove(AppConfig.languageKey);
      } else {
        await store.setString(AppConfig.languageKey, languageCode);
      }
      await store.setString(AppConfig.themeKey, appSetting.appearance.name);
      await store.setString(AppConfig.weekStartKey, appSetting.weekStart.name);
    } on AppException {
      rethrow;
    } catch (error) {
      throw CacheException('App setting could not be saved. $error');
    }
  }

  AppAppearance _appearance(String? name) {
    if (name == null) return AppAppearance.system;
    for (final appearance in AppAppearance.values) {
      if (appearance.name == name) return appearance;
    }
    throw CacheException('Appearance $name is not recognized.');
  }

  WeekStart _weekStart(String? name) {
    if (name == null) return WeekStart.monday;
    for (final weekStart in WeekStart.values) {
      if (weekStart.name == name) return weekStart;
    }
    throw CacheException('Week start $name is not recognized.');
  }
}
