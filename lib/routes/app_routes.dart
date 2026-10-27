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

  static String account(String id) => '/account/$id';

  static String editAccount(String id) => '/account/$id/edit';

  static String editCategory(String id) => '/category/$id';
}
