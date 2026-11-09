part of '../daily_view.dart';

mixin DailyViewMixin on State<DailyView> {
  DailyBloc get _bloc => context.read<DailyBloc>();

  void onRetry() => _bloc.add(const DailyRequested());

  void onCloseTapped() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(RoutePaths.home.name);
    }
  }

  Future<void> onStartTapped(DailyChallenge challenge) async {
    await context.pushNamed(
      RoutePaths.game.name,
      extra: GameArgs(
        mode: GameMode.daily,
        seed: challenge.seed,
        dailyDate: challenge.date,
      ),
    );
    if (!mounted) return;
    // En iyin / sıran güncellensin.
    _bloc.add(const DailyRequested());
  }
}
