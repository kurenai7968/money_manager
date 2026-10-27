import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/core/utils/amount_expression.dart';

void main() {
  test('adds left to right and shows only the current number', () {
    final expression = const AmountExpression()
        .appendDigit('8')
        .appendDigit('0')
        .applyOperator(AmountOperator.add)
        .appendDigit('6');

    expect(expression.display, '6');
    expect(expression.operator, AmountOperator.add);
    expect(expression.resultMinor, 8600);
  });

  test('multiplies the running result', () {
    final expression = const AmountExpression()
        .appendDigit('8')
        .appendDigit('0')
        .applyOperator(AmountOperator.add)
        .appendDigit('6')
        .applyOperator(AmountOperator.multiply)
        .appendDigit('2');

    expect(expression.resultMinor, 17200);
  });

  test('divides in minor units and rejects zero', () {
    final divided = const AmountExpression()
        .appendDigit('1')
        .appendDigit('0')
        .applyOperator(AmountOperator.divide)
        .appendDigit('4');
    expect(divided.resultMinor, 250);

    final zero = divided.applyOperator(AmountOperator.divide).appendDigit('0');
    expect(zero.resultMinor, isNull);
  });

  test('evaluate finishes a pending operation', () {
    final pending = const AmountExpression()
        .appendDigit('8')
        .appendDigit('0')
        .applyOperator(AmountOperator.add)
        .appendDigit('6');
    final done = pending.evaluate();

    expect(done, isNotNull);
    expect(done!.display, '86');
    expect(done.operator, isNull);
    expect(done.resultMinor, 8600);

    final dangling = const AmountExpression()
        .appendDigit('8')
        .applyOperator(AmountOperator.add);
    final confirmed = dangling.evaluate();
    expect(confirmed!.display, '8');
    expect(confirmed.operator, isNull);

    final zero = pending.applyOperator(AmountOperator.divide).appendDigit('0');
    expect(zero.evaluate(), isNull);
  });

  test('keeps two decimal places and clears', () {
    final expression = const AmountExpression()
        .appendDigit('1')
        .appendDecimal()
        .appendDigit('2')
        .appendDigit('9');
    expect(expression.display, '1.29');
    expect(expression.appendDigit('9').display, '1.29');
    expect(expression.clear().display, '0');
  });
}
