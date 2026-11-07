import 'package:equatable/equatable.dart';
import 'package:money_manager/models/enums/app_theme_mode.dart';
import 'package:money_manager/models/enums/first_day_of_week.dart';

sealed class AppSettingEvent extends Equatable {
  const AppSettingEvent();

  @override
  List<Object?> get props => [];
}

class AppSettingInitialized extends AppSettingEvent {
  const AppSettingInitialized();
}

class AppSettingLanguageChanged extends AppSettingEvent {
  final String languageCode;
  final String countryCode;

  const AppSettingLanguageChanged({
    required this.languageCode,
    required this.countryCode,
  });

  @override
  List<Object?> get props => [languageCode, countryCode];
}

class AppSettingThemeModeChanged extends AppSettingEvent {
  final AppThemeMode appThemeMode;

  const AppSettingThemeModeChanged({required this.appThemeMode});

  @override
  List<Object?> get props => [appThemeMode];
}

class AppSettingFirstDayOfWeekChanged extends AppSettingEvent {
  final FirstDayOfWeek firstDayOfWeek;

  const AppSettingFirstDayOfWeekChanged({required this.firstDayOfWeek});

  @override
  List<Object?> get props => [firstDayOfWeek];
}
