class TableField {
  const TableField(this.column, this.type);

  final String column;
  final String type;

  String get declaration => '$column $type';
}
