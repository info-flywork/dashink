import 'dart:async';

import 'package:dashink/data/model/player/player_progress.dart';
import 'package:dashink/domain/player/player_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

final class HomeStarted extends HomeEvent {
  const HomeStarted();
}

final class _HomeProgressChanged extends HomeEvent {
  const _HomeProgressChanged(this.progress);

  final PlayerProgress progress;

  @override
  List<Object?> get props => [progress];
}

class HomeState extends Equatable {
  const HomeState({
    required this.coins,
    required this.bestScore,
    this.rewards = const [],
  });

  final int coins;
  final int bestScore;

  /// Gösterilecek yeni ödüller (günlük sıralama). View bir kez gösterir.
  final List<PlayerReward> rewards;

  @override
  List<Object?> get props => [coins, bestScore, rewards];
}

/// Ana menü: altın sayacı ve en iyi skor. İlerleme değiştikçe (oyun sonu,
/// mağaza, görev ödülü) kendiliğinden güncellenir.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._playerRepository)
    : super(
        HomeState(
          coins: _playerRepository.progress.coins,
          bestScore: _playerRepository.progress.bestScore,
        ),
      ) {
    on<HomeStarted>(_onStarted);
    on<_HomeProgressChanged>(
      (event, emit) => emit(
        HomeState(
          coins: event.progress.coins,
          bestScore: event.progress.bestScore,
        ),
      ),
    );
    _subscription = _playerRepository.changes.listen(
      (p) => add(_HomeProgressChanged(p)),
    );
  }

  final PlayerRepository _playerRepository;
  late final StreamSubscription<PlayerProgress> _subscription;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    final progress = _playerRepository.progress;
    emit(
      HomeState(
        coins: progress.coins,
        bestScore: progress.bestScore,
        rewards: _playerRepository.takeRewards(),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
