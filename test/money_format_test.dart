import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/core/utils/money_format.dart';

void main() {
  test('parses whole and fractional amounts', () {
    expect(parseAmountMinor(''), 0);
    expect(parseAmountMinor('12'), 1200);
    expect(parseAmountMinor('12.5'), 1250);
    expect(parseAmountMinor('12.50'), 1250);
    expect(parseAmountMinor('1,280'), 128000);
    expect(parseAmountMinor('-1'), isNull);
    expect(parseAmountMinor('1.234'), isNull);
  });

  test('formats grouped amounts and signs', () {
    expect(formatMinor(1820000, locale: 'en'), '18,200');
    expect(formatMinor(1250, locale: 'en'), '12.50');
    expect(formatMinor(-8600, locale: 'en', signed: true), '-86');
    expect(formatMinor(1820000, locale: 'en', signed: true), '+18,200');
  });
}
