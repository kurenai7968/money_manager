class AccountTable {
  static const tableName = 'accounts';

  static const id = 'id';
  static const name = 'name';
  static const type = 'type';
  static const icon = 'icon';
  static const sortOrder = 'sort_order';
  static const isActive = 'is_active';
  static const languageEn = 'language_en';
  static const languageZh = 'language_zh';
  static const languageZhCn = 'language_zh_cn';

  static const createSql =
      'CREATE TABLE $tableName ('
      '$id INTEGER PRIMARY KEY AUTOINCREMENT, '
      '$name TEXT, '
      '$type TEXT NOT NULL, '
      '$icon TEXT NOT NULL, '
      '$sortOrder INTEGER NOT NULL, '
      '$isActive INTEGER NOT NULL, '
      '$languageEn TEXT, '
      '$languageZh TEXT, '
      '$languageZhCn TEXT)';
}
