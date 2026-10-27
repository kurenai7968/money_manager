import 'package:flutter/widgets.dart';
import 'package:money_manager/app.dart';
import 'package:money_manager/database/shared_preferences/shared_preference_store.dart';
import 'package:money_manager/database/sqlite/app_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferenceManager.instance.initialize();
  await AppDatabase.instance.initialize();
  runApp(const App());
}
