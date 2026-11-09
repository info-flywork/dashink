import 'package:dashink/core/base/model/base_model.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_challenge.g.dart';

/// `GET /daily`: bugünün ortak parkuru.
@JsonSerializable()
class DailyChallenge extends Equatable implements BaseModel<DailyChallenge> {
  const DailyChallenge({
    this.date,
    this.seed = 0,
    this.participants = 0,
    this.myBest,
    this.myRank,
    this.endsAt,
    this.reward = 0,
    this.rewardTop = 0,
  });

  factory DailyChallenge.fromJson(Map<String, dynamic> json) =>
      _$DailyChallengeFromJson(json);

  /// `YYYY-MM-DD` (UTC).
  final String? date;
  final int seed;
  final int participants;
  final int? myBest;
  final int? myRank;
  final DateTime? endsAt;
  final int reward;
  final int rewardTop;

  @override
  DailyChallenge fromJson(Map<String, dynamic> json) =>
      DailyChallenge.fromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DailyChallengeToJson(this);

  @override
  List<Object?> get props => [
    date,
    seed,
    participants,
    myBest,
    myRank,
    endsAt,
    reward,
    rewardTop,
  ];
}
