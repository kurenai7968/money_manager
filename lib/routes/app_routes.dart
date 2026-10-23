enum AppRoutes {
  home('/'),
  analysis('/analysis'),
  accounts('/accounts'),
  settings('/settings'),
  record('/record'),
  accountNew('/account/new'),
  categories('/categories'),
  categoryNew('/category/new');

  const AppRoutes(this.path);

  final String path;

  static String account(String id) => '/account/$id';

  static String editAccount(String id) => '/account/$id/edit';

  static String editCategory(String id) => '/category/$id';
}
