enum AmountOperator { add, subtract, multiply, divide }

class AmountExpression {
  const AmountExpression({
    this.current = '0',
    this.accumulatorMinor,
    this.operator,
    this.replaceOnNextDigit = false,
  });

  final String current;
  final int? accumulatorMinor;
  final AmountOperator? operator;
  final bool replaceOnNextDigit;

  static AmountExpression fromMinor(int minor) {
    return AmountExpression(current: _plain(minor));
  }

  String get display {
    final dot = current.endsWith('.');
    final body = dot ? current.substring(0, current.length - 1) : current;
    final parts = body.split('.');
    final whole = parts.first.replaceAll(RegExp(r'^0+(?=\d)'), '');
    final shownWhole = whole.isEmpty ? '0' : whole;
    final grouped = _group(shownWhole);
    if (parts.length == 1) {
      return dot ? '$grouped.' : grouped;
    }
    return '$grouped.${parts[1]}';
  }

  int? get resultMinor {
    final currentMinor = _minorOf(current);
    if (currentMinor == null) {
      return null;
    }
    if (operator == null || accumulatorMinor == null || replaceOnNextDigit) {
      return currentMinor;
    }
    return _apply(accumulatorMinor!, operator!, currentMinor);
  }

  AmountExpression appendDigit(String digit) {
    if (replaceOnNextDigit) {
      return copyWith(current: digit, replaceOnNextDigit: false);
    }
    if (current == '0') {
      return copyWith(current: digit);
    }
    final dot = current.indexOf('.');
    if (dot != -1 && current.length - dot > 2) {
      return this;
    }
    if (dot == -1 && current.length >= 12) {
      return this;
    }
    return copyWith(current: '$current$digit');
  }

  AmountExpression appendDoubleZero() {
    if (replaceOnNextDigit) {
      return copyWith(current: '0', replaceOnNextDigit: false);
    }
    final dot = current.indexOf('.');
    if (dot == -1) {
      if (current == '0' || current.length >= 10) {
        return this;
      }
      return copyWith(current: '${current}00');
    }
    final places = current.length - dot - 1;
    if (places >= 2) {
      return this;
    }
    return copyWith(current: '$current${'0' * (2 - places)}');
  }

  AmountExpression appendDecimal() {
    if (replaceOnNextDigit) {
      return copyWith(current: '0.', replaceOnNextDigit: false);
    }
    if (current.contains('.')) {
      return this;
    }
    return copyWith(current: '$current.');
  }

  AmountExpression backspace() {
    if (replaceOnNextDigit) {
      return AmountExpression(
        current: _trimLast(_plain(accumulatorMinor ?? 0)),
      );
    }
    if (current.length <= 1) {
      return copyWith(current: '0');
    }
    final next = current.substring(0, current.length - 1);
    return copyWith(current: next.isEmpty ? '0' : next);
  }

  AmountExpression clear() => const AmountExpression();

  AmountExpression applyOperator(AmountOperator next) {
    final result = resultMinor;
    if (result == null) {
      return this;
    }
    return AmountExpression(
      current: _plain(result),
      accumulatorMinor: result,
      operator: next,
      replaceOnNextDigit: true,
    );
  }

  AmountExpression copyWith({
    String? current,
    int? accumulatorMinor,
    AmountOperator? operator,
    bool? replaceOnNextDigit,
    bool clearOperator = false,
  }) {
    return AmountExpression(
      current: current ?? this.current,
      accumulatorMinor: accumulatorMinor ?? this.accumulatorMinor,
      operator: clearOperator ? null : operator ?? this.operator,
      replaceOnNextDigit: replaceOnNextDigit ?? this.replaceOnNextDigit,
    );
  }

  static String _plain(int minor) {
    final negative = minor < 0;
    final absolute = minor.abs();
    final whole = absolute ~/ 100;
    final fraction = absolute % 100;
    final text = fraction == 0
        ? '$whole'
        : '$whole.${fraction.toString().padLeft(2, '0')}';
    return negative ? '-$text' : text;
  }

  static String _trimLast(String value) {
    if (value.length <= 1 || value == '-0') {
      return '0';
    }
    final next = value.substring(0, value.length - 1);
    if (next == '-' || next.isEmpty) {
      return '0';
    }
    return next;
  }

  static String _group(String digits) {
    final negative = digits.startsWith('-');
    final body = negative ? digits.substring(1) : digits;
    final buffer = StringBuffer();
    for (var index = 0; index < body.length; index++) {
      final remaining = body.length - index;
      if (index > 0 && remaining % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(body[index]);
    }
    return negative ? '-${buffer.toString()}' : buffer.toString();
  }

  static int? _minorOf(String value) {
    final normalized = value.endsWith('.')
        ? value.substring(0, value.length - 1)
        : value;
    if (normalized.isEmpty || normalized == '-') {
      return 0;
    }
    final negative = normalized.startsWith('-');
    final body = negative ? normalized.substring(1) : normalized;
    final parts = body.split('.');
    if (parts.isEmpty || parts.first.isEmpty) {
      return null;
    }
    final whole = int.tryParse(parts.first);
    if (whole == null) {
      return null;
    }
    final fraction = parts.length == 1
        ? 0
        : int.tryParse(parts[1].padRight(2, '0'));
    if (fraction == null) {
      return null;
    }
    final minor = whole * 100 + fraction;
    return negative ? -minor : minor;
  }

  static int? _apply(int left, AmountOperator op, int right) {
    return switch (op) {
      AmountOperator.add => left + right,
      AmountOperator.subtract => left - right,
      AmountOperator.multiply => (left * right) ~/ 100,
      AmountOperator.divide => right == 0 ? null : (left * 100) ~/ right,
    };
  }
}
