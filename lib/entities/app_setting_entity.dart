import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_setting_entity.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AppSettingEntity extends Equatable {
  final String languageCode;
  final String countryCode;
  final String appearance;
  final String firstDayOfWeek;

  const AppSettingEntity({
    required this.languageCode,
    required this.countryCode,
    required this.appearance,
    required this.firstDayOfWeek,
  });

  factory AppSettingEntity.fromJson(Map<String, dynamic> json) =>
      _$AppSettingEntityFromJson(json);

  Map<String, dynamic> toJson() => _$AppSettingEntityToJson(this);

  @override
  List<Object?> get props => [
    languageCode,
    countryCode,
    appearance,
    firstDayOfWeek,
  ];
}
