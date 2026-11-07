class AccountTable {
  static const tableName = 'accounts';

  static const id = 'id';
  static const name = 'name';
  static const type = 'type';
  static const openingBalance = 'opening_balance';
  static const sortOrder = 'sort_order';
  static const archived = 'archived';
  static const languageEn = 'language_en';
  static const languageZh = 'language_zh';
  static const languageZhCn = 'language_zh_cn';

  static const createSql =
      'CREATE TABLE $tableName ('
      '$id TEXT PRIMARY KEY, '
      '$name TEXT, '
      '$type TEXT NOT NULL, '
      '$openingBalance INTEGER NOT NULL, '
      '$sortOrder INTEGER NOT NULL, '
      '$archived INTEGER NOT NULL, '
      '$languageEn TEXT, '
      '$languageZh TEXT, '
      '$languageZhCn TEXT)';
}
