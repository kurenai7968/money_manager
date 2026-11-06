import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:money_manager/models/enums/app_appearance.dart';
import 'package:money_manager/models/enums/first_day_of_week.dart';

class AppSettingModel extends Equatable {
  final String languageCode;
  final String countryCode;
  final AppAppearance appearance;
  final FirstDayOfWeek firstDayOfWeek;

  const AppSettingModel({
    this.languageCode = '',
    this.countryCode = '',
    this.appearance = AppAppearance.system,
    this.firstDayOfWeek = FirstDayOfWeek.monday,
  });

  Locale? get locale {
    if (languageCode.isEmpty) return null;
    if (countryCode.isEmpty) return Locale(languageCode);
    return Locale(languageCode, countryCode);
  }

  AppSettingModel copyWith({
    String? languageCode,
    String? countryCode,
    AppAppearance? appearance,
    FirstDayOfWeek? firstDayOfWeek,
  }) {
    return AppSettingModel(
      languageCode: languageCode ?? this.languageCode,
      countryCode: countryCode ?? this.countryCode,
      appearance: appearance ?? this.appearance,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
    );
  }

  @override
  List<Object?> get props => [
    languageCode,
    countryCode,
    appearance,
    firstDayOfWeek,
  ];
}
