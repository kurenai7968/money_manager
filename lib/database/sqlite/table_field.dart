class TableField {
  final String column;
  final String type;

  const TableField(this.column, this.type);

  String get declaration => '$column $type';
}
