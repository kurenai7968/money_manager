import 'dart:convert';

import 'package:money_manager/app_config.dart';
import 'package:money_manager/core/errors/app_exception.dart';
import 'package:money_manager/core/mapping/app_setting_mapping.dart';
import 'package:money_manager/database/shared_preferences/shared_preference_store.dart';
import 'package:money_manager/entities/app_setting_entity.dart';
import 'package:money_manager/models/app_setting_model.dart';

abstract interface class AppSettingRepository {
  Future<AppSettingModel> getAppSetting();
  Future<void> updateAppSetting(AppSettingModel appSetting);
}

class AppSettingRepositoryImpl implements AppSettingRepository {
  final SharedPreferenceStore store;

  AppSettingRepositoryImpl({required this.store});

  @override
  Future<AppSettingModel> getAppSetting() async {
    final json = store.getString(AppConfig.appSettingKey);
    if (json == null) return const AppSettingModel();

    try {
      final decoded = jsonDecode(json);
      if (decoded is! Map) {
        throw const FormatException('App setting JSON is not an object');
      }
      return AppSettingEntity.fromJson(Map<String, dynamic>.from(decoded))
          .toModel();
    } on CacheException {
      rethrow;
    } catch (error) {
      throw CacheException('App setting could not be read. $error');
    }
  }

  @override
  Future<void> updateAppSetting(AppSettingModel appSetting) async {
    try {
      await store.setString(
        AppConfig.appSettingKey,
        jsonEncode(appSetting.toEntity().toJson()),
      );
    } on AppException {
      rethrow;
    } catch (error) {
      throw CacheException('App setting could not be saved. $error');
    }
  }
}
