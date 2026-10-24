import 'package:equatable/equatable.dart';

enum AppThemeChoice { system, light, dark }

enum WeekStart { monday, sunday }

class AppSetting extends Equatable {
  const AppSetting({
    this.languageCode,
    this.themeChoice = AppThemeChoice.system,
    this.weekStart = WeekStart.monday,
  });

  final String? languageCode;
  final AppThemeChoice themeChoice;
  final WeekStart weekStart;

  AppSetting copyWith({
    String? languageCode,
    AppThemeChoice? themeChoice,
    WeekStart? weekStart,
    bool clearLanguage = false,
  }) {
    return AppSetting(
      languageCode: clearLanguage ? null : languageCode ?? this.languageCode,
      themeChoice: themeChoice ?? this.themeChoice,
      weekStart: weekStart ?? this.weekStart,
    );
  }

  @override
  List<Object?> get props => [languageCode, themeChoice, weekStart];
}

int leadingCalendarBlanks(DateTime firstOfMonth, WeekStart weekStart) {
  if (weekStart == WeekStart.monday) {
    return firstOfMonth.weekday - 1;
  }
  return firstOfMonth.weekday % 7;
}
