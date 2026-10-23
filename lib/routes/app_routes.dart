enum AppRoutes {
  home('/'),
  analysis('/analysis'),
  accounts('/accounts'),
  settings('/settings'),
  record('/record');

  const AppRoutes(this.path);

  final String path;
}
