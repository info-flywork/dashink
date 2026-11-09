import 'package:dashink/core/base/model/base_model.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'leaderboard.g.dart';

enum LeaderboardPeriod { daily, weekly, all }

@JsonSerializable()
class LeaderboardEntry extends Equatable {
  const LeaderboardEntry({
    this.rank = 0,
    this.userId,
    this.name,
    this.score = 0,
    this.isMe = false,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);

  final int rank;
  final String? userId;
  final String? name;
  final int score;
  final bool isMe;

  Map<String, dynamic> toJson() => _$LeaderboardEntryToJson(this);

  @override
  List<Object?> get props => [rank, userId, name, score, isMe];
}

/// `GET /leaderboard?period=...`.
@JsonSerializable()
class Leaderboard extends Equatable implements BaseModel<Leaderboard> {
  const Leaderboard({this.period, this.entries = const [], this.me});

  factory Leaderboard.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardFromJson(json);

  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  final LeaderboardPeriod? period;
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? me;

  @override
  Leaderboard fromJson(Map<String, dynamic> json) => Leaderboard.fromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LeaderboardToJson(this);

  @override
  List<Object?> get props => [period, entries, me];
}
