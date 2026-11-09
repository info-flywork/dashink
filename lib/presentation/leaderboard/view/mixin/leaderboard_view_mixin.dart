part of '../leaderboard_view.dart';

mixin LeaderboardViewMixin on State<LeaderboardView> {
  void onPeriodChanged(int index) => context.read<LeaderboardBloc>().add(
    LeaderboardPeriodSelected(LeaderboardPeriod.values[index]),
  );

  void onCloseTapped() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(RoutePaths.home.name);
    }
  }
}
