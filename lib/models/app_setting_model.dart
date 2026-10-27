import 'package:equatable/equatable.dart';
import 'package:money_manager/models/enums/app_appearance.dart';
import 'package:money_manager/models/enums/week_start.dart';

class AppSettingModel extends Equatable {
  const AppSettingModel({
    this.languageCode,
    this.appearance = AppAppearance.system,
    this.weekStart = WeekStart.monday,
  });

  final String? languageCode;
  final AppAppearance appearance;
  final WeekStart weekStart;

  AppSettingModel copyWith({
    String? languageCode,
    AppAppearance? appearance,
    WeekStart? weekStart,
    bool clearLanguage = false,
  }) {
    return AppSettingModel(
      languageCode: clearLanguage ? null : languageCode ?? this.languageCode,
      appearance: appearance ?? this.appearance,
      weekStart: weekStart ?? this.weekStart,
    );
  }

  @override
  List<Object?> get props => [languageCode, appearance, weekStart];
}

int leadingCalendarBlanks(DateTime firstOfMonth, WeekStart weekStart) {
  if (weekStart == WeekStart.monday) {
    return firstOfMonth.weekday - 1;
  }
  return firstOfMonth.weekday % 7;
}
