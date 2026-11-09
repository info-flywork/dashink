import 'package:dashink/core/base/model/base_model.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'task_list.g.dart';

enum TaskPeriod { daily, weekly, achievement }

enum TaskStatus {
  @JsonValue('in_progress')
  inProgress,
  claimable,
  claimed,
}

/// Bir görev. Başlık istemcide [id] ile yerelleştirilir.
@JsonSerializable()
class GameTask extends Equatable {
  const GameTask({
    required this.id,
    this.icon,
    this.target = 1,
    this.progress = 0,
    this.reward = 0,
    this.status = TaskStatus.inProgress,
    this.unlocksItem,
  });

  factory GameTask.fromJson(Map<String, dynamic> json) =>
      _$GameTaskFromJson(json);

  final String id;

  /// `play` | `trophy` | `share` | `calendar` | `crown` | `coin`.
  final String? icon;
  final int target;
  final int progress;
  final int reward;
  @JsonKey(unknownEnumValue: TaskStatus.inProgress)
  final TaskStatus status;
  final String? unlocksItem;

  double get ratio => target <= 0 ? 0 : (progress / target).clamp(0, 1);

  Map<String, dynamic> toJson() => _$GameTaskToJson(this);

  GameTask copyWith({TaskStatus? status, int? progress}) => GameTask(
    id: id,
    icon: icon,
    target: target,
    progress: progress ?? this.progress,
    reward: reward,
    status: status ?? this.status,
    unlocksItem: unlocksItem,
  );

  @override
  List<Object?> get props => [
    id,
    icon,
    target,
    progress,
    reward,
    status,
    unlocksItem,
  ];
}

/// `GET /tasks?period=...`.
@JsonSerializable()
class TaskList extends Equatable implements BaseModel<TaskList> {
  const TaskList({this.period, this.resetsAt, this.tasks = const []});

  factory TaskList.fromJson(Map<String, dynamic> json) =>
      _$TaskListFromJson(json);

  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  final TaskPeriod? period;
  final DateTime? resetsAt;
  final List<GameTask> tasks;

  @override
  TaskList fromJson(Map<String, dynamic> json) => TaskList.fromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TaskListToJson(this);

  @override
  List<Object?> get props => [period, resetsAt, tasks];
}

/// `POST /tasks/:id/claim`.
@JsonSerializable()
class TaskClaimResponse extends Equatable
    implements BaseModel<TaskClaimResponse> {
  const TaskClaimResponse({this.task, this.coins = 0, this.unlockedItem});

  factory TaskClaimResponse.fromJson(Map<String, dynamic> json) =>
      _$TaskClaimResponseFromJson(json);

  final GameTask? task;
  final int coins;
  final String? unlockedItem;

  @override
  TaskClaimResponse fromJson(Map<String, dynamic> json) =>
      TaskClaimResponse.fromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TaskClaimResponseToJson(this);

  @override
  List<Object?> get props => [task, coins, unlockedItem];
}
