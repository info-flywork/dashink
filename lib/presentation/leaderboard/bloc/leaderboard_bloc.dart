import 'package:dashink/data/model/leaderboard/leaderboard.dart';
import 'package:dashink/domain/leaderboard/leaderboard_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object?> get props => [];
}

/// Dönem seçildi (ilk açılışta günlük).
final class LeaderboardPeriodSelected extends LeaderboardEvent {
  const LeaderboardPeriodSelected(this.period);

  final LeaderboardPeriod period;

  @override
  List<Object?> get props => [period];
}

sealed class LeaderboardState extends Equatable {
  const LeaderboardState(this.period);

  final LeaderboardPeriod period;

  @override
  List<Object?> get props => [period];
}

final class LeaderboardLoading extends LeaderboardState {
  const LeaderboardLoading(super.period);
}

final class LeaderboardLoaded extends LeaderboardState {
  const LeaderboardLoaded(super.period, this.board);

  final Leaderboard board;

  @override
  List<Object?> get props => [period, board];
}

final class LeaderboardError extends LeaderboardState {
  const LeaderboardError(super.period, this.error);

  final Object error;

  @override
  List<Object?> get props => [period, error];
}

/// Sıralama: dönem değişince önce bellekteki liste, sonra ağdan tazesi.
class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  LeaderboardBloc(this._repository)
    : super(const LeaderboardLoading(LeaderboardPeriod.daily)) {
    on<LeaderboardPeriodSelected>(_onPeriodSelected);
  }

  final LeaderboardRepository _repository;

  Future<void> _onPeriodSelected(
    LeaderboardPeriodSelected event,
    Emitter<LeaderboardState> emit,
  ) async {
    final period = event.period;
    final cached = _repository.cached(period);
    emit(
      cached == null
          ? LeaderboardLoading(period)
          : LeaderboardLoaded(period, cached),
    );
    try {
      final board = await _repository.fetch(period);
      if (state.period == period) emit(LeaderboardLoaded(period, board));
    } on Exception catch (e) {
      if (cached == null && state.period == period) {
        emit(LeaderboardError(period, e));
      }
    }
  }
}
