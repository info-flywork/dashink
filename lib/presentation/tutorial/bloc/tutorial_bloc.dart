import 'package:dashink/domain/player/player_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class TutorialEvent extends Equatable {
  const TutorialEvent();

  @override
  List<Object?> get props => [];
}

final class TutorialPageChanged extends TutorialEvent {
  const TutorialPageChanged(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

/// "Geç" veya son adımda "ANLADIM".
final class TutorialFinished extends TutorialEvent {
  const TutorialFinished();
}

class TutorialState extends Equatable {
  const TutorialState({this.step = 0, this.finished = false});

  static const int stepCount = 3;

  final int step;
  final bool finished;

  bool get isLast => step == stepCount - 1;

  @override
  List<Object?> get props => [step, finished];
}

/// Eğitim adımları. Bitiş/atlama kalıcı saklanır (tekrar izleme açılışı
/// etkilemez: zaten görülmüş sayılır).
class TutorialBloc extends Bloc<TutorialEvent, TutorialState> {
  TutorialBloc(this._playerRepository) : super(const TutorialState()) {
    on<TutorialPageChanged>(
      (event, emit) => emit(TutorialState(step: event.index)),
    );
    on<TutorialFinished>((event, emit) async {
      await _playerRepository.completeTutorial();
      emit(TutorialState(step: state.step, finished: true));
    });
  }

  final PlayerRepository _playerRepository;
}
