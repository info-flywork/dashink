// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_submit_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyGameResult _$DailyGameResultFromJson(Map<String, dynamic> json) =>
    DailyGameResult(
      date: json['date'] as String?,
      best: (json['best'] as num?)?.toInt(),
      rank: (json['rank'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DailyGameResultToJson(DailyGameResult instance) =>
    <String, dynamic>{
      'date': instance.date,
      'best': instance.best,
      'rank': instance.rank,
    };

GameSubmitResponse _$GameSubmitResponseFromJson(Map<String, dynamic> json) =>
    GameSubmitResponse(
      score: (json['score'] as num?)?.toInt() ?? 0,
      previousBest: (json['previous_best'] as num?)?.toInt() ?? 0,
      bestScore: (json['best_score'] as num?)?.toInt() ?? 0,
      newRecord: json['new_record'] as bool? ?? false,
      recordReward: (json['record_reward'] as num?)?.toInt() ?? 0,
      coinsCredited: (json['coins_credited'] as num?)?.toInt() ?? 0,
      coins: (json['coins'] as num?)?.toInt() ?? 0,
      daily: json['daily'] == null
          ? null
          : DailyGameResult.fromJson(json['daily'] as Map<String, dynamic>),
      completedTasks:
          (json['completed_tasks'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$GameSubmitResponseToJson(GameSubmitResponse instance) =>
    <String, dynamic>{
      'score': instance.score,
      'previous_best': instance.previousBest,
      'best_score': instance.bestScore,
      'new_record': instance.newRecord,
      'record_reward': instance.recordReward,
      'coins_credited': instance.coinsCredited,
      'coins': instance.coins,
      'daily': instance.daily?.toJson(),
      'completed_tasks': instance.completedTasks,
    };

OkResponse _$OkResponseFromJson(Map<String, dynamic> json) =>
    OkResponse(ok: json['ok'] as bool? ?? false);

Map<String, dynamic> _$OkResponseToJson(OkResponse instance) =>
    <String, dynamic>{'ok': instance.ok};
