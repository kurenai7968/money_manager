import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:money_manager/models/enums/app_theme_mode.dart';
import 'package:money_manager/models/enums/first_day_of_week.dart';
import 'package:money_manager/models/enums/ledger_color.dart';

class AppSettingModel extends Equatable {
  final String languageCode;
  final String countryCode;
  final AppThemeMode appThemeMode;
  final FirstDayOfWeek firstDayOfWeek;
  final LedgerColorPair colorPair;

  const AppSettingModel({
    this.languageCode = '',
    this.countryCode = '',
    this.appThemeMode = AppThemeMode.system,
    this.firstDayOfWeek = FirstDayOfWeek.monday,
    this.colorPair = LedgerColorPair.redGreen,
  });

  LedgerColor get incomeColor => colorPair.income;

  LedgerColor get expenseColor => colorPair.expense;

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
    LedgerColorPair? colorPair,
  }) {
    return AppSettingModel(
      languageCode: languageCode ?? this.languageCode,
      countryCode: countryCode ?? this.countryCode,
      appThemeMode: appThemeMode ?? this.appThemeMode,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      colorPair: colorPair ?? this.colorPair,
    );
  }

  @override
  List<Object?> get props => [
    languageCode,
    countryCode,
    appThemeMode,
    firstDayOfWeek,
    colorPair,
  ];
}
