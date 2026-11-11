import 'dart:convert';

import 'package:money_manager/app_config.dart';
import 'package:money_manager/core/errors/app_exception.dart';
import 'package:money_manager/core/mapping/app_setting_mapping.dart';
import 'package:money_manager/database/shared_preferences/shared_preference_store.dart';
import 'package:money_manager/entities/app_setting_entity.dart';
import 'package:money_manager/models/app_setting_model.dart';
import 'package:money_manager/models/enums/app_theme_mode.dart';
import 'package:money_manager/models/enums/first_day_of_week.dart';

abstract interface class AppSettingRepository {
  Future<AppSettingModel> getAppSetting();
  Future<AppSettingModel> updateLanguage(
    String languageCode,
    String countryCode,
  );
  Future<AppSettingModel> updateThemeMode(AppThemeMode appThemeMode);
  Future<AppSettingModel> updateFirstDayOfWeek(FirstDayOfWeek firstDayOfWeek);
}

class AppSettingRepositoryImpl implements AppSettingRepository {
  final SharedPreferenceStore store;

  AppSettingRepositoryImpl({required this.store});

  @override
  Future<AppSettingModel> getAppSetting() {
    return guard('App setting could not be read.', () async {
      final json = store.getString(AppConfig.appSettingKey);
      if (json == null) return const AppSettingModel();

      final decoded = jsonDecode(json);
      if (decoded is! Map) {
        throw const FormatException('App setting JSON is not an object');
      }
      return AppSettingEntity.fromJson(Map<String, dynamic>.from(decoded))
          .toModel();
    });
  }

  @override
  Future<AppSettingModel> updateLanguage(
    String languageCode,
    String countryCode,
  ) {
    return guard('App setting could not be saved.', () async {
      final appSetting = await getAppSetting();
      final updatedSetting = appSetting.copyWith(
        languageCode: languageCode,
        countryCode: countryCode,
      );
      await _updateAppSetting(updatedSetting);
      return updatedSetting;
    });
  }

  @override
  Future<AppSettingModel> updateThemeMode(AppThemeMode appThemeMode) {
    return guard('App setting could not be saved.', () async {
      final appSetting = await getAppSetting();
      final updatedSetting = appSetting.copyWith(appThemeMode: appThemeMode);
      await _updateAppSetting(updatedSetting);
      return updatedSetting;
    });
  }

  @override
  Future<AppSettingModel> updateFirstDayOfWeek(FirstDayOfWeek firstDayOfWeek) {
    return guard('App setting could not be saved.', () async {
      final appSetting = await getAppSetting();
      final updatedSetting = appSetting.copyWith(
        firstDayOfWeek: firstDayOfWeek,
      );
      await _updateAppSetting(updatedSetting);
      return updatedSetting;
    });
  }

  Future<void> _updateAppSetting(AppSettingModel appSetting) {
    return store.setString(
      AppConfig.appSettingKey,
      jsonEncode(appSetting.toEntity().toJson()),
    );
  }
}
