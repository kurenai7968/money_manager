import 'package:intl/intl.dart';

final _formats = <String, DateFormat>{};

DateFormat cachedDateFormat(String locale, String pattern) {
  return _formats.putIfAbsent(
    '$locale|$pattern',
    () => DateFormat(pattern, locale),
  );
}

DateFormat cachedYearMonth(String locale) {
  return _formats.putIfAbsent('$locale|yMMMM', () => DateFormat.yMMMM(locale));
}

DateFormat cachedMonthDay(String locale) {
  return _formats.putIfAbsent('$locale|MMMd', () => DateFormat.MMMd(locale));
}

DateFormat cachedYearMonthDay(String locale) {
  return _formats.putIfAbsent(
    '$locale|yMMMEd',
    () => DateFormat.yMMMEd(locale),
  );
}
