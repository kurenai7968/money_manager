import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/core/errors/app_exception.dart';
import 'package:money_manager/database/shared_preferences/shared_preference_store.dart';
import 'package:money_manager/database/sqlite/app_database.dart';

void main() {
  test('database throws before initialize', () async {
    await AppDatabase.instance.close();
    expect(
      () => AppDatabase.instance.query('accounts'),
      throwsA(isA<CacheException>()),
    );
  });

  test('shared preferences throw before initialize', () {
    SharedPreferenceManager.instance.reset();
    expect(
      () => SharedPreferenceManager.instance.store,
      throwsA(isA<CacheException>()),
    );
  });
}
