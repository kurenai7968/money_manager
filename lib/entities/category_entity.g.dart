// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryEntity _$CategoryEntityFromJson(Map<String, dynamic> json) =>
    CategoryEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      kind: json['kind'] as String,
      sortOrder: (json['sort_order'] as num).toInt(),
      archived: const BoolIntConverter().fromJson(
        (json['archived'] as num).toInt(),
      ),
    );

Map<String, dynamic> _$CategoryEntityToJson(CategoryEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'color': instance.color,
      'kind': instance.kind,
      'sort_order': instance.sortOrder,
      'archived': const BoolIntConverter().toJson(instance.archived),
    };
