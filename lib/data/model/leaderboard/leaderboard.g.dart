// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaderboardEntry _$LeaderboardEntryFromJson(Map<String, dynamic> json) =>
    LeaderboardEntry(
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      userId: json['user_id'] as String?,
      name: json['name'] as String?,
      score: (json['score'] as num?)?.toInt() ?? 0,
      isMe: json['is_me'] as bool? ?? false,
    );

Map<String, dynamic> _$LeaderboardEntryToJson(LeaderboardEntry instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'user_id': instance.userId,
      'name': instance.name,
      'score': instance.score,
      'is_me': instance.isMe,
    };

Leaderboard _$LeaderboardFromJson(Map<String, dynamic> json) => Leaderboard(
  period: $enumDecodeNullable(
    _$LeaderboardPeriodEnumMap,
    json['period'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
  entries:
      (json['entries'] as List<dynamic>?)
          ?.map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  me: json['me'] == null
      ? null
      : LeaderboardEntry.fromJson(json['me'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LeaderboardToJson(Leaderboard instance) =>
    <String, dynamic>{
      'period': _$LeaderboardPeriodEnumMap[instance.period],
      'entries': instance.entries.map((e) => e.toJson()).toList(),
      'me': instance.me?.toJson(),
    };

const _$LeaderboardPeriodEnumMap = {
  LeaderboardPeriod.daily: 'daily',
  LeaderboardPeriod.weekly: 'weekly',
  LeaderboardPeriod.all: 'all',
};
