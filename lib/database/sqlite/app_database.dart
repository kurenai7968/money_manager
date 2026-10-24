import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase(this.db);

  final Database db;

  static Future<AppDatabase> open({String? path}) async {
    final database = await openDatabase(
      path ?? await _defaultPath(),
      version: 3,
      onCreate: (db, version) async {
        await _createAccounts(db);
        await _createCategories(db);
        await _createTransactions(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createTransactions(db);
        }
        if (oldVersion < 3) {
          await _addCategoryLanguages(db);
        }
      },
    );
    return AppDatabase(database);
  }

  static Future<String> _defaultPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return path.join(directory.path, 'money_manager.db');
  }

  static Future<void> _createAccounts(Database db) {
    return db.execute('''
      CREATE TABLE accounts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        opening_balance INTEGER NOT NULL,
        sort_order INTEGER NOT NULL,
        archived INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> _createCategories(Database db) {
    return db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT,
        icon TEXT NOT NULL,
        color TEXT NOT NULL,
        kind TEXT NOT NULL,
        sort_order INTEGER NOT NULL,
        archived INTEGER NOT NULL,
        language_en TEXT,
        language_zh TEXT,
        language_zh_cn TEXT
      )
    ''');
  }

  static Future<void> _addCategoryLanguages(Database db) async {
    await db.execute('''
      CREATE TABLE categories_next (
        id TEXT PRIMARY KEY,
        name TEXT,
        icon TEXT NOT NULL,
        color TEXT NOT NULL,
        kind TEXT NOT NULL,
        sort_order INTEGER NOT NULL,
        archived INTEGER NOT NULL,
        language_en TEXT,
        language_zh TEXT,
        language_zh_cn TEXT
      )
    ''');
    await db.execute('''
      INSERT INTO categories_next (
        id, name, icon, color, kind, sort_order, archived
      )
      SELECT id, name, icon, color, kind, sort_order, archived
      FROM categories
    ''');
    await db.execute('DROP TABLE categories');
    await db.execute('ALTER TABLE categories_next RENAME TO categories');
  }

  static Future<void> _createTransactions(Database db) {
    return db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        amount_minor INTEGER NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        account_id TEXT,
        category_id TEXT,
        from_account_id TEXT,
        to_account_id TEXT
      )
    ''');
  }

  Future<void> close() => db.close();
}
