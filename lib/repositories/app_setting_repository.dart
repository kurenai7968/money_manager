import 'dart:convert';

import 'package:money_manager/app_config.dart';
import 'package:money_manager/core/errors/app_exception.dart';
import 'package:money_manager/database/shared_preferences/shared_preference_store.dart';
import 'package:money_manager/models/app_setting_model.dart';
import 'package:money_manager/models/enums/app_appearance.dart';
import 'package:money_manager/models/enums/first_day_of_week.dart';

abstract interface class AppSettingRepository {
  Future<AppSettingModel> getAppSetting();

  Future<void> updateAppSetting(AppSettingModel appSetting);
}

class AppSettingRepositoryImpl implements AppSettingRepository {
  final SharedPreferenceStore store;

  AppSettingRepositoryImpl({required this.store});

  @override
  Future<AppSettingModel> getAppSetting() async {
    // try {
    //   return AppSettingModel(
    //     languageCode: store.getString(AppConfig.languageCodeKey),
    //     countryCode: store.getString(AppConfig.countryCodeKey),
    //     appearance: _appearance(store.getString(AppConfig.themeKey)),
    //     firstDayOfWeek: _firstDayOfWeek(
    //       store.getString(AppConfig.weekStartKey),
    //     ),
    //   );
    // } on AppException {
    //   rethrow;
    // } catch (error) {
    //   throw CacheException('App setting could not be read. $error');
    // }

    final json = store.getString(AppConfig.appSettingKey);
    if (json == null) return AppSettingModel();

    try {
      final decoded = jsonDecode(json);
      if (decoded is! Map) {
        throw const FormatException('App setting JSON is not an object');
      }
      return AppSettingEntity.fromJson(
        Map<String, dynamic>.from(decoded),
      ).toModel();
    } on CacheException {
      rethrow;
    } catch (error) {
      throw CacheException('$error');
    }
  }

  @override
  Future<void> updateAppSetting(AppSettingModel appSetting) async {
    try {
      final languageCode = appSetting.languageCode;
      await store.setString(AppConfig.languageCodeKey, languageCode);
      await store.setString(AppConfig.themeKey, appSetting.appearance.name);
      await store.setString(
        AppConfig.weekStartKey,
        appSetting.firstDayOfWeek.name,
      );
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

  FirstDayOfWeek _firstDayOfWeek(String? name) {
    if (name == null) return FirstDayOfWeek.monday;
    for (final day in FirstDayOfWeek.values) {
      if (day.name == name) return day;
    }
    throw CacheException('Week start $name is not recognized.');
  }
}
