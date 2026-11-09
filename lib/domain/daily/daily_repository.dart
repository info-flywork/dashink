import 'package:dashink/core/network/network_exception.dart';
import 'package:dashink/core/network/network_manager.dart';
import 'package:dashink/core/utils/enum/request_type.dart';
import 'package:dashink/data/model/daily/daily_challenge.dart';

/// Günlük meydan okuma: `GET /daily` (herkese aynı seed).
class DailyRepository {
  DailyRepository(this._networkManager);

  final NetworkManager _networkManager;

  Future<DailyChallenge> fetch() async {
    final result = await _networkManager.send<DailyChallenge>(
      path: '/daily',
      method: RequestType.get,
      parserModel: DailyChallenge.fromJson,
    );
    if (result == null) throw NetworkException.emptyResponse();
    return result;
  }
}
