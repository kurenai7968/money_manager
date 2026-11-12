class TransactionTable {
  static const tableName = 'transactions';

  static const id = 'id';
  static const type = 'type';
  static const amount = 'amount';
  static const date = 'date';
  static const note = 'note';
  static const accountId = 'account_id';
  static const categoryId = 'category_id';
  static const fromAccountId = 'from_account_id';
  static const toAccountId = 'to_account_id';

  static const createSql =
      'CREATE TABLE $tableName ('
      '$id INTEGER PRIMARY KEY AUTOINCREMENT, '
      '$type TEXT NOT NULL, '
      '$amount REAL NOT NULL, '
      '$date TEXT NOT NULL, '
      '$note TEXT, '
      '$accountId INTEGER, '
      '$categoryId INTEGER, '
      '$fromAccountId INTEGER, '
      '$toAccountId INTEGER)';
}
