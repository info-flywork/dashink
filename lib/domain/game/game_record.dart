import 'package:dashink/data/model/game/game_submit_response.dart';
import 'package:equatable/equatable.dart';

enum GameMode { normal, daily }

/// Biten bir oyunun sunucuya gönderilecek kaydı (`POST /games`).
class GameRecord extends Equatable {
  const GameRecord({
    required this.clientEventId,
    required this.mode,
    required this.seed,
    required this.score,
    required this.coinsCollected,
    required this.durationMs,
    this.dailyDate,
  });

  factory GameRecord.fromJson(Map<String, dynamic> json) => GameRecord(
    clientEventId: json['client_event_id'] as String,
    mode: GameMode.values.byName(json['mode'] as String),
    seed: json['seed'] as int,
    score: json['score'] as int,
    coinsCollected: json['coins_collected'] as int,
    durationMs: json['duration_ms'] as int,
    dailyDate: json['daily_date'] as String?,
  );

  final String clientEventId;
  final GameMode mode;
  final int seed;
  final int score;
  final int coinsCollected;
  final int durationMs;
  final String? dailyDate;

  Map<String, dynamic> toJson() => {
    'client_event_id': clientEventId,
    'mode': mode.name,
    'seed': seed,
    'daily_date': dailyDate,
    'score': score,
    'coins_collected': coinsCollected,
    'duration_ms': durationMs,
  };

  @override
  List<Object?> get props => [
    clientEventId,
    mode,
    seed,
    score,
    coinsCollected,
    durationMs,
    dailyDate,
  ];
}

/// Oyun sonu ekranlarının ihtiyaç duyduğu sonuç. Çevrimdışıyken yerel
/// tahmindir ([offline] true); sunucu kayıt ulaşınca kesinleştirir.
class GameOutcome extends Equatable {
  const GameOutcome({
    required this.score,
    required this.previousBest,
    required this.bestScore,
    required this.newRecord,
    required this.recordReward,
    required this.coinsCredited,
    this.daily,
    this.offline = false,
  });

  factory GameOutcome.fromResponse(GameSubmitResponse r) => GameOutcome(
    score: r.score,
    previousBest: r.previousBest,
    bestScore: r.bestScore,
    newRecord: r.newRecord,
    recordReward: r.recordReward,
    coinsCredited: r.coinsCredited,
    daily: r.daily,
  );

  /// Rekor ödülü (sunucu ile aynı kural).
  static const int recordRewardCoins = 50;

  final int score;
  final int previousBest;
  final int bestScore;
  final bool newRecord;
  final int recordReward;
  final int coinsCredited;
  final DailyGameResult? daily;
  final bool offline;

  int get improvement => score - previousBest;

  @override
  List<Object?> get props => [
    score,
    previousBest,
    bestScore,
    newRecord,
    recordReward,
    coinsCredited,
    daily,
    offline,
  ];
}
