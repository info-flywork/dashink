/// Mock endpoint kayıtları: `'<METHOD> <path>[?period=<p>]'` ->
/// `assets/mock/<dosya>.json`.
///
/// Oyuncu işlemleri (ilerleme, oyun sonucu, satın alma, görev ödülü) mock
/// modunda istek atmaz; repository'ler cihazda yürütür.
/// `MOCK_SCENARIO=empty` iken önce `<dosya>.empty.json` aranır.
const Map<String, String> mockRoutes = {
  'GET /shop/catalog': 'assets/mock/shop_catalog.json',
  'GET /daily': 'assets/mock/daily.json',
  'GET /tasks?period=daily': 'assets/mock/tasks_daily.json',
  'GET /tasks?period=weekly': 'assets/mock/tasks_weekly.json',
  'GET /tasks?period=achievement': 'assets/mock/tasks_achievement.json',
  'GET /leaderboard?period=daily': 'assets/mock/leaderboard_daily.json',
  'GET /leaderboard?period=weekly': 'assets/mock/leaderboard_weekly.json',
  'GET /leaderboard?period=all': 'assets/mock/leaderboard_all.json',
};
