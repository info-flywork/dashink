import 'dart:async';

import 'package:dashink/core/sound/sound_manager.dart';
import 'package:dashink/data/model/player/player_progress.dart';
import 'package:dashink/data/model/task/task_list.dart';
import 'package:dashink/domain/player/player_repository.dart';
import 'package:dashink/domain/task/task_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

/// Dönem seçildi / yenile (sekmeye dönüş, süre doldu).
final class TasksPeriodSelected extends TasksEvent {
  const TasksPeriodSelected(this.period);

  final TaskPeriod period;

  @override
  List<Object?> get props => [period];
}

final class TasksClaimRequested extends TasksEvent {
  const TasksClaimRequested(this.task);

  final GameTask task;

  @override
  List<Object?> get props => [task];
}

final class _TasksCoinsChanged extends TasksEvent {
  const _TasksCoinsChanged(this.coins);

  final int coins;

  @override
  List<Object?> get props => [coins];
}

sealed class TasksState extends Equatable {
  const TasksState({required this.period, required this.coins});

  final TaskPeriod period;
  final int coins;

  @override
  List<Object?> get props => [period, coins];
}

final class TasksLoading extends TasksState {
  const TasksLoading({required super.period, required super.coins});
}

final class TasksError extends TasksState {
  const TasksError({
    required super.period,
    required super.coins,
    required this.error,
  });

  final Object error;

  @override
  List<Object?> get props => [...super.props, error];
}

class TasksLoaded extends TasksState {
  const TasksLoaded({
    required super.period,
    required super.coins,
    required this.list,
  });

  final TaskList list;

  @override
  List<Object?> get props => [...super.props, list];
}

/// Ödül alındı (view "+30 altın" / "DİSKO açıldı!" gösterir).
final class TasksClaimSuccess extends TasksLoaded {
  const TasksClaimSuccess({
    required super.period,
    required super.coins,
    required super.list,
    required this.task,
  });

  final GameTask task;

  @override
  List<Object?> get props => [...super.props, task];
}

final class TasksClaimFailure extends TasksLoaded {
  const TasksClaimFailure({
    required super.period,
    required super.coins,
    required super.list,
    required this.error,
  });

  final Object error;

  @override
  List<Object?> get props => [...super.props, error];
}

/// Görevler: dönem listesi ve ödül alma.
class TasksBloc extends Bloc<TasksEvent, TasksState> {
  TasksBloc(this._taskRepository, this._playerRepository, this._sound)
    : super(
        TasksLoading(
          period: TaskPeriod.daily,
          coins: _playerRepository.progress.coins,
        ),
      ) {
    on<TasksPeriodSelected>(_onPeriodSelected);
    on<TasksClaimRequested>(_onClaim);
    on<_TasksCoinsChanged>(_onCoinsChanged);
    _subscription = _playerRepository.changes.listen(
      (p) => add(_TasksCoinsChanged(p.coins)),
    );
  }

  final TaskRepository _taskRepository;
  final PlayerRepository _playerRepository;
  final SoundManager _sound;
  late final StreamSubscription<PlayerProgress> _subscription;
  final Map<TaskPeriod, TaskList> _lists = {};

  int get _coins => _playerRepository.progress.coins;

  /// Önce bellekteki / cihazdaki liste anında gösterilir, ağdan tazelenir.
  /// İlk yüklemede diğer dönemler de arka planda çekilir: sekme değişince
  /// yükleniyor ekranı çıkmaz.
  Future<void> _onPeriodSelected(
    TasksPeriodSelected event,
    Emitter<TasksState> emit,
  ) async {
    final period = event.period;
    final cached = _lists[period] ?? _taskRepository.cached(period);
    if (cached != null) _lists[period] = cached;
    emit(
      cached == null
          ? TasksLoading(period: period, coins: _coins)
          : TasksLoaded(period: period, coins: _coins, list: cached),
    );
    try {
      final list = await _taskRepository.fetch(period);
      _lists[period] = list;
      if (state.period == period) {
        emit(TasksLoaded(period: period, coins: _coins, list: list));
      }
      _prefetchOthers(period);
    } on Exception catch (e) {
      if (cached == null && state.period == period) {
        emit(TasksError(period: period, coins: _coins, error: e));
      }
    }
  }

  bool _prefetched = false;

  void _prefetchOthers(TaskPeriod current) {
    if (_prefetched) return;
    _prefetched = true;
    for (final p in TaskPeriod.values) {
      if (p != current) unawaited(_prefetch(p));
    }
  }

  Future<void> _prefetch(TaskPeriod period) async {
    try {
      _lists[period] = await _taskRepository.fetch(period);
    } on Exception {
      // Sessiz: o sekmeye geçilince yeniden denenir.
    }
  }

  /// İyimser ödül: görev ANINDA "alındı" olur ve kutlama oynar; sunucu
  /// cevabı arka planda gelir. Hata olursa görev geri "al" durumuna döner.
  Future<void> _onClaim(
    TasksClaimRequested event,
    Emitter<TasksState> emit,
  ) async {
    final period = state.period;
    final task = event.task;
    final current = _lists[period]?.tasks.where((t) => t.id == task.id);
    // Çift dokunuş / zaten alınmış: yok say.
    if (current == null ||
        current.isEmpty ||
        current.first.status != TaskStatus.claimable) {
      return;
    }
    _replace(period, task.copyWith(status: TaskStatus.claimed));
    _sound.play(GameSound.coin);
    emit(
      TasksClaimSuccess(
        period: period,
        coins: _coins,
        list: _lists[period]!,
        task: task,
      ),
    );
    try {
      final updated = await _taskRepository.claim(task);
      _replace(period, updated);
      unawaited(_taskRepository.saveCache(_lists[period]!));
      if (state.period == period) {
        emit(TasksLoaded(period: period, coins: _coins, list: _lists[period]!));
      }
    } on Exception catch (e) {
      _replace(period, task);
      emit(
        TasksClaimFailure(
          period: state.period,
          coins: _coins,
          list: _lists[state.period] ?? _lists[period]!,
          error: e,
        ),
      );
    }
  }

  void _replace(TaskPeriod period, GameTask task) {
    final list = _lists[period];
    if (list == null) return;
    _lists[period] = TaskList(
      period: list.period,
      resetsAt: list.resetsAt,
      tasks: [for (final t in list.tasks) t.id == task.id ? task : t],
    );
  }

  void _onCoinsChanged(_TasksCoinsChanged event, Emitter<TasksState> emit) {
    final s = state;
    emit(switch (s) {
      TasksLoaded(:final list) => TasksLoaded(
        period: s.period,
        coins: event.coins,
        list: list,
      ),
      TasksLoading() => TasksLoading(period: s.period, coins: event.coins),
      TasksError(:final error) => TasksError(
        period: s.period,
        coins: event.coins,
        error: error,
      ),
    });
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
