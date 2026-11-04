import 'package:equatable/equatable.dart';
import 'package:money_manager/models/enums/app_appearance.dart';
import 'package:money_manager/models/enums/first_day_of_week.dart';

class AppSettingModel extends Equatable {
  const AppSettingModel({
    this.languageCode,
    this.appearance = AppAppearance.system,
    this.firstDayOfWeek = FirstDayOfWeek.monday,
  });

  final String? languageCode;
  final AppAppearance appearance;
  final FirstDayOfWeek firstDayOfWeek;

  AppSettingModel copyWith({
    String? languageCode,
    AppAppearance? appearance,
    FirstDayOfWeek? firstDayOfWeek,
    bool clearLanguage = false,
  }) {
    return AppSettingModel(
      languageCode: clearLanguage ? null : languageCode ?? this.languageCode,
      appearance: appearance ?? this.appearance,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
    );
  }

  @override
  List<Object?> get props => [languageCode, appearance, firstDayOfWeek];
}

int leadingCalendarBlanks(DateTime firstOfMonth, FirstDayOfWeek firstDay) {
  final start = firstDay.index + 1;
  return (firstOfMonth.weekday - start + 7) % 7;
}
