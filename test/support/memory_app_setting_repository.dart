import 'package:money_manager/models/app_setting_model.dart';
import 'package:money_manager/models/enums/app_theme_mode.dart';
import 'package:money_manager/models/enums/first_day_of_week.dart';
import 'package:money_manager/repositories/app_setting_repository.dart';

class MemoryAppSettingRepository implements AppSettingRepository {
  AppSettingModel appSetting = const AppSettingModel();

  @override
  Future<AppSettingModel> getAppSetting() async => appSetting;

  @override
  Future<AppSettingModel> updateLanguage(
    String languageCode,
    String countryCode,
  ) async {
    appSetting = appSetting.copyWith(
      languageCode: languageCode,
      countryCode: countryCode,
    );
    return appSetting;
  }

  @override
  Future<AppSettingModel> updateThemeMode(AppThemeMode appThemeMode) async {
    appSetting = appSetting.copyWith(appThemeMode: appThemeMode);
    return appSetting;
  }

  @override
  Future<AppSettingModel> updateFirstDayOfWeek(
    FirstDayOfWeek firstDayOfWeek,
  ) async {
    appSetting = appSetting.copyWith(firstDayOfWeek: firstDayOfWeek);
    return appSetting;
  }
}
