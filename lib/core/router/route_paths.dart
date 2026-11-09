enum RoutePaths {
  splash('/', 'splash'),
  tutorial('/tutorial', 'tutorial'),
  home('/home', 'home'),
  leaderboard('leaderboard', 'leaderboard'),
  daily('daily', 'daily'),
  shop('/shop', 'shop'),
  tasks('/tasks', 'tasks'),
  settings('/settings', 'settings'),
  game('/game', 'game');

  const RoutePaths(this.path, this.name);

  final String path;
  final String name;
}
