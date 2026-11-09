part of '../home_view.dart';

mixin HomeViewMixin on State<HomeView> {
  SoundManager get _sound => GetIt.instance<SoundManager>();

  void onPlayTapped() {
    _sound
      ..play(GameSound.tap)
      ..haptic();
    unawaited(
      context.pushNamed(RoutePaths.game.name, extra: const GameArgs()),
    );
  }

  void onDailyTapped() {
    _sound.play(GameSound.tap, volume: 0.4);
    context.goNamed(RoutePaths.daily.name);
  }

  void onLeaderboardTapped() {
    _sound.play(GameSound.tap, volume: 0.4);
    context.goNamed(RoutePaths.leaderboard.name);
  }

  void onRewards(BuildContext context, HomeState state) {
    final reward = state.rewards.first;
    _sound.play(GameSound.coin);
    AppSnackbar.show(
      context: context,
      text: LocaleKeys.home_reward_daily.tr(
        namedArgs: {'rank': '${reward.rank ?? ''}', 'coins': '${reward.coins}'},
      ),
      type: SnackBarType.success,
      duration: const Duration(seconds: 4),
    );
  }
}
