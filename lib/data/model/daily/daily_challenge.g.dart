// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_challenge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyChallenge _$DailyChallengeFromJson(Map<String, dynamic> json) =>
    DailyChallenge(
      date: json['date'] as String?,
      seed: (json['seed'] as num?)?.toInt() ?? 0,
      participants: (json['participants'] as num?)?.toInt() ?? 0,
      myBest: (json['my_best'] as num?)?.toInt(),
      myRank: (json['my_rank'] as num?)?.toInt(),
      endsAt: json['ends_at'] == null
          ? null
          : DateTime.parse(json['ends_at'] as String),
      reward: (json['reward'] as num?)?.toInt() ?? 0,
      rewardTop: (json['reward_top'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$DailyChallengeToJson(DailyChallenge instance) =>
    <String, dynamic>{
      'date': instance.date,
      'seed': instance.seed,
      'participants': instance.participants,
      'my_best': instance.myBest,
      'my_rank': instance.myRank,
      'ends_at': instance.endsAt?.toIso8601String(),
      'reward': instance.reward,
      'reward_top': instance.rewardTop,
    };
