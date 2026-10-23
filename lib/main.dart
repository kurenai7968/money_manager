import 'package:flutter/widgets.dart';
import 'package:money_manager/app.dart';
import 'package:money_manager/database/sqlite/app_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await AppDatabase.open();
  runApp(MoneyManagerApp(database: database));
}
