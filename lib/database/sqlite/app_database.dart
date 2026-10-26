import 'package:money_manager/database/sqlite/account_table.dart';
import 'package:money_manager/database/sqlite/category_table.dart';
import 'package:money_manager/database/sqlite/transaction_table.dart';
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
        await db.execute(AccountTable.createSql);
        await db.execute(CategoryTable.createSql);
        await db.execute(TransactionTable.createSql);
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
