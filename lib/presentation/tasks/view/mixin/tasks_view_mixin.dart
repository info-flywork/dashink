part of '../tasks_view.dart';

mixin TasksViewMixin on State<TasksView> {
  TasksBloc get _bloc => context.read<TasksBloc>();

  void onPeriodChanged(int index) =>
      _bloc.add(TasksPeriodSelected(TaskPeriod.values[index]));

  void onRefresh() => _bloc.add(TasksPeriodSelected(_bloc.state.period));

  /// Üstteki altın sayacı: ödül altınları buraya uçar.
  final GlobalKey coinPillKey = GlobalKey(debugLabel: 'tasksCoinPill');

  /// AL'a basılan butonun konumu (görev id → ekran dikdörtgeni).
  final Map<String, Rect> _claimOrigins = {};

  void onClaimTapped(GameTask task, Rect? from) {
    if (from != null) _claimOrigins[task.id] = from;
    _bloc.add(TasksClaimRequested(task));
  }

  void _celebrate(BuildContext context, GameTask task) {
    final from = _claimOrigins.remove(task.id);
    final pill = AppRewardBurst.rectOf(coinPillKey.currentContext);
    final unlocked = task.unlocksItem;
    AppRewardBurst.show(
      context,
      from:
          from ??
          pill ??
          Rect.fromCenter(
            center: MediaQuery.sizeOf(context).center(Offset.zero),
            width: 1,
            height: 1,
          ),
      to: pill,
      label: unlocked == null
          ? '+${task.reward}'
          : LocaleKeys.tasks_unlocked_toast.tr(
              args: [ItemAssets.name(unlocked)],
            ),
      badge: unlocked == null
          ? null
          : ItemAssets.ballImage(unlocked).image(width: 28, height: 28),
    );
  }

  void onStateChanged(BuildContext context, TasksState state) {
    switch (state) {
      case TasksClaimSuccess(:final task):
        _celebrate(context, task);
      case TasksClaimFailure(:final error):
        AppSnackbar.show(
          context: context,
          text: error is TaskNotClaimableException
              ? LocaleKeys.common_unexpected_error.tr()
              : ErrorMessages.of(error),
          type: SnackBarType.failure,
        );
        onRefresh();
      case _:
        break;
    }
  }
}
