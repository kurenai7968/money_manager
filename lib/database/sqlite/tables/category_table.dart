class CategoryTable {
  static const tableName = 'categories';

  static const id = 'id';
  static const name = 'name';
  static const icon = 'icon';
  static const type = 'type';
  static const sortOrder = 'sort_order';
  static const isActive = 'is_active';
  static const languageEn = 'language_en';
  static const languageZh = 'language_zh';
  static const languageZhCn = 'language_zh_cn';

  static const createSql =
      'CREATE TABLE $tableName ('
      '$id INTEGER PRIMARY KEY AUTOINCREMENT, '
      '$name TEXT, '
      '$icon TEXT NOT NULL, '
      '$type TEXT NOT NULL, '
      '$sortOrder INTEGER NOT NULL, '
      '$isActive INTEGER NOT NULL, '
      '$languageEn TEXT, '
      '$languageZh TEXT, '
      '$languageZhCn TEXT)';
}
