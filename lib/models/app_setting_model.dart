import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:money_manager/models/enums/app_theme_mode.dart';
import 'package:money_manager/models/enums/first_day_of_week.dart';

class AppSettingModel extends Equatable {
  final String languageCode;
  final String countryCode;
  final AppThemeMode appThemeMode;
  final FirstDayOfWeek firstDayOfWeek;

  const AppSettingModel({
    this.languageCode = '',
    this.countryCode = '',
    this.appThemeMode = AppThemeMode.system,
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
    AppThemeMode? appThemeMode,
    FirstDayOfWeek? firstDayOfWeek,
  }) {
    return AppSettingModel(
      languageCode: languageCode ?? this.languageCode,
      countryCode: countryCode ?? this.countryCode,
      appThemeMode: appThemeMode ?? this.appThemeMode,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
    );
  }

  @override
  List<Object?> get props => [
    languageCode,
    countryCode,
    appThemeMode,
    firstDayOfWeek,
  ];
}
