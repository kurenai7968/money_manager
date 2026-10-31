import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/app.dart';
import 'package:money_manager/core/utils/app_bloc_observer.dart';
import 'package:money_manager/database/shared_preferences/shared_preference_store.dart';
import 'package:money_manager/database/sqlite/app_database.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Shared Preferences
  await SharedPreferenceManager.instance.initialize();
  await AppDatabase.instance.initialize();

  // Add Bloc observer
  Bloc.observer = AppBlocObserver(logOnTransition: false);

  runApp(const App());
}
