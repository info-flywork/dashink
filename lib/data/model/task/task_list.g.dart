// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameTask _$GameTaskFromJson(Map<String, dynamic> json) => GameTask(
  id: json['id'] as String,
  icon: json['icon'] as String?,
  target: (json['target'] as num?)?.toInt() ?? 1,
  progress: (json['progress'] as num?)?.toInt() ?? 0,
  reward: (json['reward'] as num?)?.toInt() ?? 0,
  status:
      $enumDecodeNullable(
        _$TaskStatusEnumMap,
        json['status'],
        unknownValue: TaskStatus.inProgress,
      ) ??
      TaskStatus.inProgress,
  unlocksItem: json['unlocks_item'] as String?,
);

Map<String, dynamic> _$GameTaskToJson(GameTask instance) => <String, dynamic>{
  'id': instance.id,
  'icon': instance.icon,
  'target': instance.target,
  'progress': instance.progress,
  'reward': instance.reward,
  'status': _$TaskStatusEnumMap[instance.status]!,
  'unlocks_item': instance.unlocksItem,
};

const _$TaskStatusEnumMap = {
  TaskStatus.inProgress: 'in_progress',
  TaskStatus.claimable: 'claimable',
  TaskStatus.claimed: 'claimed',
};

TaskList _$TaskListFromJson(Map<String, dynamic> json) => TaskList(
  period: $enumDecodeNullable(
    _$TaskPeriodEnumMap,
    json['period'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
  resetsAt: json['resets_at'] == null
      ? null
      : DateTime.parse(json['resets_at'] as String),
  tasks:
      (json['tasks'] as List<dynamic>?)
          ?.map((e) => GameTask.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$TaskListToJson(TaskList instance) => <String, dynamic>{
  'period': _$TaskPeriodEnumMap[instance.period],
  'resets_at': instance.resetsAt?.toIso8601String(),
  'tasks': instance.tasks.map((e) => e.toJson()).toList(),
};

const _$TaskPeriodEnumMap = {
  TaskPeriod.daily: 'daily',
  TaskPeriod.weekly: 'weekly',
  TaskPeriod.achievement: 'achievement',
};

TaskClaimResponse _$TaskClaimResponseFromJson(Map<String, dynamic> json) =>
    TaskClaimResponse(
      task: json['task'] == null
          ? null
          : GameTask.fromJson(json['task'] as Map<String, dynamic>),
      coins: (json['coins'] as num?)?.toInt() ?? 0,
      unlockedItem: json['unlocked_item'] as String?,
    );

Map<String, dynamic> _$TaskClaimResponseToJson(TaskClaimResponse instance) =>
    <String, dynamic>{
      'task': instance.task?.toJson(),
      'coins': instance.coins,
      'unlocked_item': instance.unlockedItem,
    };
