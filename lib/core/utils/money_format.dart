import 'package:intl/intl.dart';

final _amountPattern = RegExp(r'^(-)?(\d+)(?:\.(\d{1,2}))?$');
final _decimalPatterns = <String, NumberFormat>{};

double? parseAmount(String text) {
  final normalized = text.trim().replaceAll(',', '');
  if (normalized.isEmpty) return 0;
  final match = _amountPattern.firstMatch(normalized);
  if (match == null) return null;
  final whole = int.parse(match.group(2)!);
  final fractionText = match.group(3);
  final fraction = fractionText == null
      ? 0
      : int.parse(fractionText.padRight(2, '0'));
  final amount = whole + fraction / 100;
  return match.group(1) == null ? amount : -amount;
}

String formatAmount(
  double amount, {
  required String locale,
  bool signed = false,
}) {
  final negative = amount < 0;
  final scaled = (amount.abs() * 100).round();
  final pattern = _decimalPatterns.putIfAbsent(
    locale,
    () => NumberFormat.decimalPattern(locale),
  );
  final whole = pattern.format(scaled ~/ 100);
  final fraction = scaled % 100;
  final text = fraction == 0
      ? whole
      : '$whole.${fraction.toString().padLeft(2, '0')}';
  if (!signed || amount == 0) {
    return negative ? '-$text' : text;
  }
  return negative ? '-$text' : '+$text';
}
