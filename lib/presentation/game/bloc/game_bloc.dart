import 'dart:math' as math;

import 'package:dashink/core/sound/sound_manager.dart';
import 'package:dashink/core/utils/id_generator.dart';
import 'package:dashink/data/model/player/player_progress.dart';
import 'package:dashink/domain/game/game_args.dart';
import 'package:dashink/domain/game/game_record.dart';
import 'package:dashink/domain/player/player_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

final class GameStarted extends GameEvent {
  const GameStarted(this.args);

  final GameArgs args;
}

/// "TEKRAR OYNA" / "BAŞTAN BAŞLA": normal modda yeni parkur, günlükte aynı.
final class GameRestarted extends GameEvent {
  const GameRestarted();
}

/// Top düştü / sivriye çarptı.
final class GameEnded extends GameEvent {
  const GameEnded({
    required this.score,
    required this.coinsCollected,
    required this.durationMs,
  });

  final int score;
  final int coinsCollected;
  final int durationMs;

  @override
  List<Object?> get props => [score, coinsCollected, durationMs];
}

/// Klip/skor paylaşıldı (görev ilerlemesi).
final class GameShared extends GameEvent {
  const GameShared();
}

sealed class GameState extends Equatable {
  const GameState({
    required this.run,
    required this.seed,
    required this.mode,
    required this.equipped,
    this.dailyDate,
  });

  /// Her yeni oyunda artar (görünüm dünyayı yeniden kurar).
  final int run;
  final int seed;
  final GameMode mode;
  final String? dailyDate;
  final EquippedItems equipped;

  @override
  List<Object?> get props => [run, seed, mode, dailyDate, equipped];
}

final class GamePlaying extends GameState {
  const GamePlaying({
    required super.run,
    required super.seed,
    required super.mode,
    required super.equipped,
    super.dailyDate,
  });
}

/// Sonuç sunucuya gönderiliyor (kısa).
final class GameSubmitting extends GameState {
  const GameSubmitting({
    required super.run,
    required super.seed,
    required super.mode,
    required super.equipped,
    super.dailyDate,
  });
}

final class GameOver extends GameState {
  const GameOver({
    required super.run,
    required super.seed,
    required super.mode,
    required super.equipped,
    required this.outcome,
    super.dailyDate,
  });

  final GameOutcome outcome;

  @override
  List<Object?> get props => [...super.props, outcome];
}

/// Oyun oturumu: seed, kuşanılı görünüm ve sonuç kaydı. Fizik/çizim
/// döngüsü görünümdedir (saniyede 60 kare bloc state'i olmaz).
class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc(this._playerRepository, this._sound, [math.Random? random])
    : _random = random ?? math.Random(),
      super(
        GamePlaying(
          run: 0,
          seed: 0,
          mode: GameMode.normal,
          equipped: _playerRepository.progress.equipped,
        ),
      ) {
    on<GameStarted>(_onStarted);
    on<GameRestarted>(_onRestarted);
    on<GameEnded>(_onEnded);
    on<GameShared>((event, emit) => _playerRepository.recordShare());
  }

  final PlayerRepository _playerRepository;
  final SoundManager _sound;
  final math.Random _random;

  int _newSeed() => _random.nextInt(1 << 31);

  void _onStarted(GameStarted event, Emitter<GameState> emit) {
    final args = event.args;
    emit(
      GamePlaying(
        run: state.run + 1,
        seed: args.seed ?? _newSeed(),
        mode: args.mode,
        dailyDate: args.dailyDate,
        equipped: _playerRepository.progress.equipped,
      ),
    );
  }

  void _onRestarted(GameRestarted event, Emitter<GameState> emit) {
    emit(
      GamePlaying(
        run: state.run + 1,
        seed: state.mode == GameMode.daily ? state.seed : _newSeed(),
        mode: state.mode,
        dailyDate: state.dailyDate,
        equipped: _playerRepository.progress.equipped,
      ),
    );
  }

  Future<void> _onEnded(GameEnded event, Emitter<GameState> emit) async {
    if (state is! GamePlaying) return;
    emit(
      GameSubmitting(
        run: state.run,
        seed: state.seed,
        mode: state.mode,
        dailyDate: state.dailyDate,
        equipped: state.equipped,
      ),
    );
    final record = GameRecord(
      clientEventId: IdGenerator.uuid(),
      mode: state.mode,
      seed: state.seed,
      dailyDate: state.dailyDate,
      score: event.score,
      coinsCollected: event.coinsCollected,
      durationMs: event.durationMs,
    );
    final outcome = await _playerRepository.submitGame(record);
    if (outcome.newRecord) _sound.play(GameSound.record);
    emit(
      GameOver(
        run: state.run,
        seed: state.seed,
        mode: state.mode,
        dailyDate: state.dailyDate,
        equipped: state.equipped,
        outcome: outcome,
      ),
    );
  }
}
