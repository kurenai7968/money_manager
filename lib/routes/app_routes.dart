enum AppRoutes {
  home('/'),
  analysis('/analysis'),
  accounts('/accounts'),
  settings('/settings'),
  record('/record'),
  accountNew('/account/new'),
  accountDetail('/account/:id'),
  accountEdit('/account/:id/edit'),
  categories('/categories'),
  categoryNew('/category/new'),
  categoryEdit('/category/:id');

  const AppRoutes(this.path);

  final String path;

  static String account(int id) =>
      AppRoutes.accountDetail.path.replaceFirst(':id', '$id');

  static String editAccount(int id) =>
      AppRoutes.accountEdit.path.replaceFirst(':id', '$id');

  static String editCategory(int id) =>
      AppRoutes.categoryEdit.path.replaceFirst(':id', '$id');

  static String recordLocation({int? id, String? type, int? from}) {
    final query = <String, String>{
      if (id != null) 'id': '$id',
      if (type != null) 'type': type,
      if (from != null) 'from': '$from',
    };
    if (query.isEmpty) {
      return AppRoutes.record.path;
    }
    return Uri(path: AppRoutes.record.path, queryParameters: query).toString();
  }
}
