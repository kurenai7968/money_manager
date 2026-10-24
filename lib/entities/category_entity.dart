import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:money_manager/core/utils/bool_int_converter.dart';

part 'category_entity.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CategoryEntity extends Equatable {
  const CategoryEntity({
    required this.id,
    this.name,
    this.languageEn,
    this.languageZh,
    this.languageZhCn,
    required this.icon,
    required this.color,
    required this.kind,
    required this.sortOrder,
    required this.archived,
  });

  factory CategoryEntity.fromJson(Map<String, dynamic> json) =>
      _$CategoryEntityFromJson(json);

  final String id;
  final String? name;
  final String? languageEn;
  final String? languageZh;
  final String? languageZhCn;
  final String icon;
  final String color;
  final String kind;
  final int sortOrder;

  @BoolIntConverter()
  final bool archived;

  Map<String, dynamic> toJson() => _$CategoryEntityToJson(this);

  @override
  List<Object?> get props => [
    id,
    name,
    languageEn,
    languageZh,
    languageZhCn,
    icon,
    color,
    kind,
    sortOrder,
    archived,
  ];
}
