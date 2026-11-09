import 'dart:convert';

import 'package:dashink/core/managers/shared_pref_manager.dart';
import 'package:dashink/core/network/network_exception.dart';
import 'package:dashink/core/network/network_manager.dart';
import 'package:dashink/core/utils/enum/request_type.dart';
import 'package:dashink/data/model/task/task_list.dart';
import 'package:dashink/domain/player/player_exceptions.dart';
import 'package:dashink/domain/player/player_repository.dart';

/// Günlük / haftalık görevler ve başarımlar. İlerlemeyi sunucu hesaplar;
/// mock modunda liste `assets/mock/` dosyalarından gelir ve ödüller cihazda
/// verilir.
class TaskRepository {
  TaskRepository(
    this._networkManager,
    this._playerRepository,
    this._prefs, {
    required this.remote,
  });

  final NetworkManager _networkManager;
  final PlayerRepository _playerRepository;
  final SharedPrefManager _prefs;
  final bool remote;

  static String _cacheName(TaskPeriod period) => 'tasks_${period.name}_v1';

  /// Cihazdaki son liste; dönemi bitmişse (resets_at geçtiyse) null.
  /// Görevler ekranı bununla anında açılır, ağdan arka planda tazelenir.
  TaskList? cached(TaskPeriod period) {
    if (!remote) return null;
    final entry = _prefs.readCache(_cacheName(period));
    if (entry == null) return null;
    try {
      final list = TaskList.fromJson(
        jsonDecode(entry.json) as Map<String, dynamic>,
      );
      final resetsAt = list.resetsAt;
      if (resetsAt != null && !resetsAt.isAfter(DateTime.now())) return null;
      return list;
    } on Object {
      return null;
    }
  }

  /// Listeyi önbelleğe yazar (ör. ödül alındıktan sonra).
  Future<void> saveCache(TaskList list) async {
    final period = list.period;
    if (!remote || period == null) return;
    await _prefs.writeCache(_cacheName(period), jsonEncode(list.toJson()));
  }

  Future<TaskList> fetch(TaskPeriod period) async {
    final result = await _networkManager.send<TaskList>(
      path: '/tasks',
      method: RequestType.get,
      parserModel: TaskList.fromJson,
      queryParameters: {'period': period.name},
    );
    if (result == null) throw NetworkException.emptyResponse();
    if (remote) {
      await saveCache(result);
      return result;
    }
    final claims = _prefs.localTaskClaims.toSet();
    return TaskList(
      period: result.period,
      resetsAt: result.resetsAt,
      tasks: [
        for (final task in result.tasks)
          claims.contains(task.id)
              ? task.copyWith(status: TaskStatus.claimed)
              : task,
      ],
    );
  }

  /// Ödülü alır; güncel görevi döndürür.
  Future<GameTask> claim(GameTask task) async {
    if (!remote) {
      if (task.status != TaskStatus.claimable) {
        throw const TaskNotClaimableException();
      }
      await _prefs.setLocalTaskClaims([..._prefs.localTaskClaims, task.id]);
      await _playerRepository.applyTaskReward(
        coins: _playerRepository.progress.coins + task.reward,
        unlockedItem: task.unlocksItem,
      );
      return task.copyWith(status: TaskStatus.claimed);
    }
    try {
      final result = await _networkManager.send<TaskClaimResponse>(
        path: '/tasks/${task.id}/claim',
        method: RequestType.post,
        parserModel: TaskClaimResponse.fromJson,
      );
      if (result == null) throw NetworkException.emptyResponse();
      await _playerRepository.applyTaskReward(
        coins: result.coins,
        unlockedItem: result.unlockedItem,
      );
      return result.task ?? task.copyWith(status: TaskStatus.claimed);
    } on NetworkException catch (e) {
      throw mapPlayerError(e);
    }
  }
}
