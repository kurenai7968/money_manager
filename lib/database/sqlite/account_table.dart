import 'package:money_manager/database/sqlite/table_field.dart';

class AccountTable {
  static const tableName = 'accounts';

  static const id = TableField('id', 'TEXT PRIMARY KEY');
  static const name = TableField('name', 'TEXT');
  static const type = TableField('type', 'TEXT NOT NULL');
  static const openingBalance = TableField(
    'opening_balance',
    'INTEGER NOT NULL',
  );
  static const sortOrder = TableField('sort_order', 'INTEGER NOT NULL');
  static const archived = TableField('archived', 'INTEGER NOT NULL');
  static const languageEn = TableField('language_en', 'TEXT');
  static const languageZh = TableField('language_zh', 'TEXT');
  static const languageZhCn = TableField('language_zh_cn', 'TEXT');

  static const fields = [
    id,
    name,
    type,
    openingBalance,
    sortOrder,
    archived,
    languageEn,
    languageZh,
    languageZhCn,
  ];

  static String get createSql =>
      'CREATE TABLE $tableName (${fields.map((field) => field.declaration).join(', ')})';
}
