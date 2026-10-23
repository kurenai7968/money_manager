import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase(this.db);

  final Database db;

  static Future<AppDatabase> open({String? path}) async {
    final database = await openDatabase(
      path ?? await _defaultPath(),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE accounts (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            opening_balance INTEGER NOT NULL,
            sort_order INTEGER NOT NULL,
            archived INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE categories (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            icon TEXT NOT NULL,
            color TEXT NOT NULL,
            kind TEXT NOT NULL,
            sort_order INTEGER NOT NULL,
            archived INTEGER NOT NULL
          )
        ''');
      },
    );
    return AppDatabase(database);
  }

  static Future<String> _defaultPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return path.join(directory.path, 'money_manager.db');
  }

  Future<void> close() => db.close();
}
