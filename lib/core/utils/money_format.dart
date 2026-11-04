import 'package:intl/intl.dart';

final _amountPattern = RegExp(r'^(-)?(\d+)(?:\.(\d{1,2}))?$');
final _decimalPatterns = <String, NumberFormat>{};

int? parseAmountMinor(String text) {
  final normalized = text.trim().replaceAll(',', '');
  if (normalized.isEmpty) return 0;
  final match = _amountPattern.firstMatch(normalized);
  if (match == null) return null;
  final whole = int.parse(match.group(2)!);
  final fraction = match.group(3);
  final minor = fraction == null ? 0 : int.parse(fraction.padRight(2, '0'));
  final amount = whole * 100 + minor;
  return match.group(1) == null ? amount : -amount;
}

String formatMinor(int minor, {required String locale, bool signed = false}) {
  final negative = minor < 0;
  final absolute = minor.abs();
  final pattern = _decimalPatterns.putIfAbsent(
    locale,
    () => NumberFormat.decimalPattern(locale),
  );
  final whole = pattern.format(absolute ~/ 100);
  final fraction = absolute % 100;
  final text = fraction == 0
      ? whole
      : '$whole.${fraction.toString().padLeft(2, '0')}';
  if (!signed || minor == 0) {
    return negative ? '-$text' : text;
  }
  return negative ? '-$text' : '+$text';
}
