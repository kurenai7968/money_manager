import 'package:flutter/widgets.dart';
import 'package:money_manager/app.dart';
import 'package:money_manager/database/shared_preferences/settings_store.dart';
import 'package:money_manager/database/sqlite/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await AppDatabase.open();
  final preferences = await SharedPreferences.getInstance();
  runApp(
    MoneyManagerApp(database: database, settings: SettingsStore(preferences)),
  );
}
