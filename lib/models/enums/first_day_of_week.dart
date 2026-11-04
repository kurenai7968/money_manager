import 'package:table_calendar/table_calendar.dart';

enum FirstDayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  StartingDayOfWeek toStartingDayOfWeek() {
    return switch (this) {
      FirstDayOfWeek.monday => StartingDayOfWeek.monday,
      FirstDayOfWeek.tuesday => StartingDayOfWeek.tuesday,
      FirstDayOfWeek.wednesday => StartingDayOfWeek.wednesday,
      FirstDayOfWeek.thursday => StartingDayOfWeek.thursday,
      FirstDayOfWeek.friday => StartingDayOfWeek.friday,
      FirstDayOfWeek.saturday => StartingDayOfWeek.saturday,
      FirstDayOfWeek.sunday => StartingDayOfWeek.sunday,
    };
  }
}
