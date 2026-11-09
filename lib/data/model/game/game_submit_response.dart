import 'package:dashink/core/base/model/base_model.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'game_submit_response.g.dart';

/// Günlük meydan okuma oyununun sonucu.
@JsonSerializable()
class DailyGameResult extends Equatable {
  const DailyGameResult({this.date, this.best, this.rank});

  factory DailyGameResult.fromJson(Map<String, dynamic> json) =>
      _$DailyGameResultFromJson(json);

  final String? date;
  final int? best;
  final int? rank;

  Map<String, dynamic> toJson() => _$DailyGameResultToJson(this);

  @override
  List<Object?> get props => [date, best, rank];
}

/// `POST /games` cevabı.
@JsonSerializable()
class GameSubmitResponse extends Equatable
    implements BaseModel<GameSubmitResponse> {
  const GameSubmitResponse({
    this.score = 0,
    this.previousBest = 0,
    this.bestScore = 0,
    this.newRecord = false,
    this.recordReward = 0,
    this.coinsCredited = 0,
    this.coins = 0,
    this.daily,
    this.completedTasks = const [],
  });

  factory GameSubmitResponse.fromJson(Map<String, dynamic> json) =>
      _$GameSubmitResponseFromJson(json);

  final int score;
  final int previousBest;
  final int bestScore;
  final bool newRecord;
  final int recordReward;
  final int coinsCredited;
  final int coins;
  final DailyGameResult? daily;
  final List<String> completedTasks;

  @override
  GameSubmitResponse fromJson(Map<String, dynamic> json) =>
      GameSubmitResponse.fromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GameSubmitResponseToJson(this);

  @override
  List<Object?> get props => [
    score,
    previousBest,
    bestScore,
    newRecord,
    recordReward,
    coinsCredited,
    coins,
    daily,
    completedTasks,
  ];
}

/// `POST /events/share` cevabı.
@JsonSerializable()
class OkResponse extends Equatable implements BaseModel<OkResponse> {
  const OkResponse({this.ok = false});

  factory OkResponse.fromJson(Map<String, dynamic> json) =>
      _$OkResponseFromJson(json);

  final bool ok;

  @override
  OkResponse fromJson(Map<String, dynamic> json) => OkResponse.fromJson(json);

  @override
  Map<String, dynamic> toJson() => _$OkResponseToJson(this);

  @override
  List<Object?> get props => [ok];
}
