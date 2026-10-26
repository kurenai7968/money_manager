import 'package:money_manager/database/sqlite/table_field.dart';

class TransactionTable {
  static const tableName = 'transactions';

  static const id = TableField('id', 'TEXT PRIMARY KEY');
  static const type = TableField('type', 'TEXT NOT NULL');
  static const amountMinor = TableField('amount_minor', 'INTEGER NOT NULL');
  static const date = TableField('date', 'TEXT NOT NULL');
  static const note = TableField('note', 'TEXT');
  static const accountId = TableField('account_id', 'TEXT');
  static const categoryId = TableField('category_id', 'TEXT');
  static const fromAccountId = TableField('from_account_id', 'TEXT');
  static const toAccountId = TableField('to_account_id', 'TEXT');

  static const fields = [
    id,
    type,
    amountMinor,
    date,
    note,
    accountId,
    categoryId,
    fromAccountId,
    toAccountId,
  ];

  static String get createSql =>
      'CREATE TABLE $tableName (${fields.map((field) => field.declaration).join(', ')})';
}
