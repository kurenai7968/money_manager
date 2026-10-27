import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/database/shared_preferences/shared_preference_store.dart';
import 'package:money_manager/database/sqlite/app_database.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final _databaseNames = Random();
var _databaseSerial = 0;

Future<String> openTestDatabase() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  await AppDatabase.instance.close();
  final file = path.join(
    Directory.systemTemp.path,
    'money-manager-${_databaseSerial++}-'
    '${DateTime.now().microsecondsSinceEpoch}-'
    '${_databaseNames.nextInt(1 << 32)}.db',
  );
  await AppDatabase.instance.initialize(path: file);
  addTearDown(() => deleteTestDatabase(file));
  return file;
}

Future<void> deleteTestDatabase(String file) async {
  await AppDatabase.instance.close();
  final database = File(file);
  if (await database.exists()) {
    await database.delete();
  }
}

Future<void> openTestPreferences() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  SharedPreferenceManager.instance.reset();
  await SharedPreferenceManager.instance.initialize();
}
