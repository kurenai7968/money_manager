class CategoryTable {
  static const tableName = 'categories';

  static const id = 'id';
  static const name = 'name';
  static const icon = 'icon';
  static const color = 'color';
  static const kind = 'kind';
  static const sortOrder = 'sort_order';
  static const archived = 'archived';
  static const languageEn = 'language_en';
  static const languageZh = 'language_zh';
  static const languageZhCn = 'language_zh_cn';

  static const createSql =
      'CREATE TABLE $tableName ('
      '$id TEXT PRIMARY KEY, '
      '$name TEXT, '
      '$icon TEXT NOT NULL, '
      '$color TEXT NOT NULL, '
      '$kind TEXT NOT NULL, '
      '$sortOrder INTEGER NOT NULL, '
      '$archived INTEGER NOT NULL, '
      '$languageEn TEXT, '
      '$languageZh TEXT, '
      '$languageZhCn TEXT)';
}
