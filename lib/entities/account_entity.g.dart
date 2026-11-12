// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountEntity _$AccountEntityFromJson(Map<String, dynamic> json) =>
    AccountEntity(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      languageEn: json['language_en'] as String?,
      languageZh: json['language_zh'] as String?,
      languageZhCn: json['language_zh_cn'] as String?,
      type: json['type'] as String,
      icon: json['icon'] as String,
      sortOrder: (json['sort_order'] as num).toInt(),
      isActive: const BoolIntConverter().fromJson(
        (json['is_active'] as num).toInt(),
      ),
    );

Map<String, dynamic> _$AccountEntityToJson(AccountEntity instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'name': instance.name,
      'language_en': instance.languageEn,
      'language_zh': instance.languageZh,
      'language_zh_cn': instance.languageZhCn,
      'type': instance.type,
      'icon': instance.icon,
      'sort_order': instance.sortOrder,
      'is_active': const BoolIntConverter().toJson(instance.isActive),
    };
