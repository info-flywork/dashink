import 'package:dashink/core/network/network_exception.dart';
import 'package:dashink/core/network/network_manager.dart';
import 'package:dashink/core/utils/enum/request_type.dart';
import 'package:dashink/data/model/leaderboard/leaderboard.dart';

/// Sıralama: `GET /leaderboard?period=daily|weekly|all`.
class LeaderboardRepository {
  LeaderboardRepository(this._networkManager);

  final NetworkManager _networkManager;
  final Map<LeaderboardPeriod, Leaderboard> _memory = {};

  /// Aynı oturumda daha önce yüklenen liste (sekme geçişinde anında).
  Leaderboard? cached(LeaderboardPeriod period) => _memory[period];

  Future<Leaderboard> fetch(LeaderboardPeriod period) async {
    final result = await _networkManager.send<Leaderboard>(
      path: '/leaderboard',
      method: RequestType.get,
      parserModel: Leaderboard.fromJson,
      queryParameters: {'period': period.name, 'limit': 50},
    );
    if (result == null) throw NetworkException.emptyResponse();
    return _memory[period] = result;
  }
}
