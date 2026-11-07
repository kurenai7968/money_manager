class TransactionTable {
  static const tableName = 'transactions';

  static const id = 'id';
  static const type = 'type';
  static const amountMinor = 'amount_minor';
  static const date = 'date';
  static const note = 'note';
  static const accountId = 'account_id';
  static const categoryId = 'category_id';
  static const fromAccountId = 'from_account_id';
  static const toAccountId = 'to_account_id';

  static const createSql =
      'CREATE TABLE $tableName ('
      '$id TEXT PRIMARY KEY, '
      '$type TEXT NOT NULL, '
      '$amountMinor INTEGER NOT NULL, '
      '$date TEXT NOT NULL, '
      '$note TEXT, '
      '$accountId TEXT, '
      '$categoryId TEXT, '
      '$fromAccountId TEXT, '
      '$toAccountId TEXT)';
}
