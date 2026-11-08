import 'package:sqflite/sqflite.dart';

abstract interface class SqlExecutor {
  Future<void> execute(String sql, [List<Object?>? arguments]);

  Future<int> rawInsert(String sql, [List<Object?>? arguments]);

  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    String? nullColumnHack,
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
  });

  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  });

  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]);

  Future<int> rawUpdate(String sql, [List<Object?>? arguments]);

  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  });

  Future<int> rawDelete(String sql, [List<Object?>? arguments]);

  Future<int> delete(String table, {String? where, List<Object?>? whereArgs});

  Future<int> count(String sql, [List<Object?>? arguments]);
}
