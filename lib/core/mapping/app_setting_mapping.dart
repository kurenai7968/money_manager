import 'package:money_manager/entities/app_setting_entity.dart';
import 'package:money_manager/models/app_setting_model.dart';
import 'package:money_manager/models/enums/app_appearance.dart';
import 'package:money_manager/models/enums/first_day_of_week.dart';

extension AppSettingEntityMapping on AppSettingEntity {
  AppSettingModel toModel() {
    return AppSettingModel(
      languageCode: languageCode,
      countryCode: countryCode,
      appearance: AppAppearance.values.byName(appearance),
      firstDayOfWeek: FirstDayOfWeek.values.byName(firstDayOfWeek),
    );
  }
}

extension AppSettingModelMapping on AppSettingModel {
  AppSettingEntity toEntity() {
    return AppSettingEntity(
      languageCode: languageCode,
      countryCode: countryCode,
      appearance: appearance.name,
      firstDayOfWeek: firstDayOfWeek.name,
    );
  }
}
