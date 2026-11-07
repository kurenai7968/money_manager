import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/core/errors/app_exception.dart';

void main() {
  group('guard', () {
    test('returns the action result', () async {
      final value = await guard('unused', () async => 7);

      expect(value, 7);
    });

    test('rethrows AppException without wrapping it', () async {
      final error = await _error(
        () => guard('unused', () async {
          throw const CacheException('already wrapped');
        }),
      );

      expect(error, isA<CacheException>());
      expect(error.message, 'already wrapped');
      expect(error.cause, isNull);
    });

    test('wraps other errors and keeps the cause', () async {
      final failure = StateError('disk');
      final error = await _error(
        () => guard('Accounts could not be read.', () async {
          throw failure;
        }),
      );

      expect(error, isA<CacheException>());
      expect(error.message, 'Accounts could not be read.');
      expect(error.cause, same(failure));
      expect(error.toString(), 'Accounts could not be read. ($failure)');
    });
  });
}

Future<AppException> _error(Future<void> Function() action) async {
  try {
    await action();
  } on AppException catch (error) {
    return error;
  }
  fail('expected AppException');
}
