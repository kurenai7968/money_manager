import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/core/utils/money_format.dart';

void main() {
  test('parses whole and fractional amounts', () {
    expect(parseAmount(''), 0);
    expect(parseAmount('12'), 12);
    expect(parseAmount('12.5'), 12.5);
    expect(parseAmount('12.50'), 12.5);
    expect(parseAmount('1,280'), 1280);
    expect(parseAmount('-1'), -1);
    expect(parseAmount('-12.5'), -12.5);
    expect(parseAmount('1.234'), isNull);
  });

  test('formats grouped amounts and signs', () {
    expect(formatAmount(18200.0, locale: 'en'), '18,200');
    expect(formatAmount(12.5, locale: 'en'), '12.50');
    expect(formatAmount(-86.0, locale: 'en', signed: true), '-86');
    expect(formatAmount(18200.0, locale: 'en', signed: true), '+18,200');
  });
}
