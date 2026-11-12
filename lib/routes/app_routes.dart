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

  static String account(int id) => '/account/$id';

  static String editAccount(int id) => '/account/$id/edit';

  static String editCategory(int id) => '/category/$id';
}
