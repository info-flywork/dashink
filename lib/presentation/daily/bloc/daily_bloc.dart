import 'package:dashink/data/model/daily/daily_challenge.dart';
import 'package:dashink/domain/daily/daily_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class DailyEvent extends Equatable {
  const DailyEvent();

  @override
  List<Object?> get props => [];
}

/// Açılışta, oyundan dönünce ve gün bitince (yeni parkur).
final class DailyRequested extends DailyEvent {
  const DailyRequested();
}

sealed class DailyState extends Equatable {
  const DailyState();

  @override
  List<Object?> get props => [];
}

final class DailyLoading extends DailyState {
  const DailyLoading();
}

final class DailyLoaded extends DailyState {
  const DailyLoaded(this.challenge);

  final DailyChallenge challenge;

  @override
  List<Object?> get props => [challenge];
}

final class DailyError extends DailyState {
  const DailyError(this.error);

  final Object error;

  @override
  List<Object?> get props => [error];
}

class DailyBloc extends Bloc<DailyEvent, DailyState> {
  DailyBloc(this._repository) : super(const DailyLoading()) {
    on<DailyRequested>(_onRequested);
  }

  final DailyRepository _repository;

  Future<void> _onRequested(
    DailyRequested event,
    Emitter<DailyState> emit,
  ) async {
    if (state is! DailyLoaded) emit(const DailyLoading());
    try {
      emit(DailyLoaded(await _repository.fetch()));
    } on Exception catch (e) {
      if (state is! DailyLoaded) emit(DailyError(e));
    }
  }
}
