// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_setting_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppSettingEntity _$AppSettingEntityFromJson(Map<String, dynamic> json) =>
    AppSettingEntity(
      languageCode: json['language_code'] as String,
      countryCode: json['country_code'] as String,
      appearance: json['appearance'] as String,
      firstDayOfWeek: json['first_day_of_week'] as String,
    );

Map<String, dynamic> _$AppSettingEntityToJson(AppSettingEntity instance) =>
    <String, dynamic>{
      'language_code': instance.languageCode,
      'country_code': instance.countryCode,
      'appearance': instance.appearance,
      'first_day_of_week': instance.firstDayOfWeek,
    };
