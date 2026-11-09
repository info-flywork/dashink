import 'dart:async';
import 'dart:convert';

import 'package:dashink/core/managers/shared_pref_manager.dart';
import 'package:dashink/core/network/network_exception.dart';
import 'package:dashink/core/network/network_manager.dart';
import 'package:dashink/core/utils/enum/request_type.dart';
import 'package:dashink/core/utils/id_generator.dart';
import 'package:dashink/data/model/auth/user.dart';
import 'package:dashink/data/model/game/game_submit_response.dart';
import 'package:dashink/data/model/player/player_progress.dart';
import 'package:dashink/data/model/shop/shop_catalog.dart';
import 'package:dashink/domain/game/game_record.dart';
import 'package:dashink/domain/player/player_exceptions.dart';

/// Oyuncu ilerlemesi (altın, en iyi skor, sahip olunan / kuşanılan öğeler).
///
/// [_network] null ise (mock modu) tamamen yereldir. Doluysa sunucu
/// yetkilidir: oyun akışını bekletmemek için oyun sonucu önce yerelde
/// uygulanır, sonra `POST /games` ile gönderilir; çevrimdışıyken kuyruğa
/// alınır (`client_event_id` ile idempotent) ve sonraki bağlantıda gönderilir.
/// Altın harcayan işlemler (mağaza) yalnızca sunucuda yapılır.
class PlayerRepository {
  PlayerRepository(this._prefs, [this._network]);

  final SharedPrefManager _prefs;
  final NetworkManager? _network;
  final StreamController<PlayerProgress> _changes =
      StreamController<PlayerProgress>.broadcast();

  /// Premium ile açılan öğeler (sunucu kataloğuyla aynı).
  static const List<String> premiumItems = [
    'ball_yildiz',
    'ink_altin',
    'theme_gece',
  ];

  bool get isRemote => _network != null;

  List<PlayerReward> _pendingRewards = const [];

  /// Son refresh'te sunucunun yeni yüklediği ödüller; bir kez okunur
  /// (ana ekran bildirimi).
  List<PlayerReward> takeRewards() {
    final rewards = _pendingRewards;
    _pendingRewards = const [];
    return rewards;
  }

  /// İlerleme her değiştiğinde yayınlanır (sekmeler arası altın sayacı).
  Stream<PlayerProgress> get changes => _changes.stream;

  PlayerProgress get progress {
    final raw = _prefs.progressJson;
    if (raw == null) return _withTutorial(const PlayerProgress());
    try {
      return _withTutorial(
        PlayerProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>),
      );
    } on Object {
      return _withTutorial(const PlayerProgress());
    }
  }

  PlayerProgress _withTutorial(PlayerProgress p) =>
      p.copyWith(tutorialSeen: p.tutorialSeen || _prefs.isTutorialSeen);

  bool get isTutorialSeen => _prefs.isTutorialSeen;

  /// Bekleyen oyunları gönderir ve sunucudaki ilerlemeyi önbelleğe alır.
  /// Dönen ilerlemedeki `rewards` yalnızca bu istekte yeni yüklenenlerdir.
  Future<PlayerProgress> refresh() async {
    final network = _network;
    if (network == null) return progress;
    await flushPending();
    final result = await network.send<PlayerProgress>(
      path: '/player/progress',
      method: RequestType.get,
      parserModel: PlayerProgress.fromJson,
    );
    if (result == null) throw NetworkException.emptyResponse();
    if (!result.tutorialSeen && _prefs.isTutorialSeen) {
      unawaited(_postTutorial());
    }
    if (result.rewards.isNotEmpty) {
      _pendingRewards = [..._pendingRewards, ...result.rewards];
    }
    await _save(result);
    return result;
  }

  Future<void> completeTutorial() async {
    await _prefs.setTutorialSeen();
    await _save(progress.copyWith(tutorialSeen: true));
    if (isRemote) unawaited(_postTutorial());
  }

  /// Görünen adı günceller. Sunucu varsa `POST /player/name`, yoksa yerelde.
  /// Geçersiz ad → [InvalidPlayerNameException].
  Future<PlayerProgress> updateName(String raw) async {
    final name = normalizePlayerName(raw);
    final network = _network;
    if (network != null) {
      try {
        final result = await network.send<PlayerProgress>(
          path: '/player/name',
          method: RequestType.post,
          parserModel: PlayerProgress.fromJson,
          data: {'name': name},
        );
        if (result == null) throw NetworkException.emptyResponse();
        await _save(result);
        return result;
      } on NetworkException catch (e) {
        if (e.message == 'invalid_request') {
          throw const InvalidPlayerNameException();
        }
        throw mapPlayerError(e);
      }
    }
    final p = progress;
    final user = p.user;
    final updated = p.copyWith(
      user: user == null ? User(name: name) : user.copyWith(name: name),
    );
    await _save(updated);
    return updated;
  }

  Future<void> _postTutorial() async {
    try {
      await _network?.send<PlayerProgress>(
        path: '/player/tutorial-complete',
        method: RequestType.post,
        parserModel: PlayerProgress.fromJson,
      );
    } on NetworkException {
      // Bir sonraki refresh'te tekrar denenir.
    }
  }

  /// Oyunu kaydeder. Sonuç önce yerelde hesaplanır; sunucu cevabı gelirse
  /// onunla kesinleşir, gelmezse kayıt kuyruğa alınır.
  Future<GameOutcome> submitGame(GameRecord record) async {
    final before = progress;
    final local = _localOutcome(before, record);
    await _save(
      before.copyWith(
        coins: before.coins + local.coinsCredited,
        bestScore: local.bestScore,
        gamesPlayed: before.gamesPlayed + 1,
      ),
    );
    final network = _network;
    if (network == null) return local;
    try {
      // Önce çevrimdışıyken biriken oyunlar (sıra korunur).
      await flushPending();
      final response = await _postGame(network, record);
      await _save(
        progress.copyWith(coins: response.coins, bestScore: response.bestScore),
      );
      return GameOutcome.fromResponse(response);
    } on NetworkException catch (e) {
      // Sunucu reddettiyse (4xx) tekrar gönderilmez; refresh düzeltir.
      if (!_isRejected(e)) await _enqueue(record);
      return GameOutcome(
        score: local.score,
        previousBest: local.previousBest,
        bestScore: local.bestScore,
        newRecord: local.newRecord,
        recordReward: local.recordReward,
        coinsCredited: local.coinsCredited,
        offline: true,
      );
    }
  }

  static GameOutcome _localOutcome(PlayerProgress before, GameRecord r) {
    final previousBest = before.bestScore;
    final newRecord = previousBest > 0 && r.score > previousBest;
    final reward = newRecord ? GameOutcome.recordRewardCoins : 0;
    return GameOutcome(
      score: r.score,
      previousBest: previousBest,
      bestScore: r.score > previousBest ? r.score : previousBest,
      newRecord: newRecord,
      recordReward: reward,
      coinsCredited: r.coinsCollected + reward,
    );
  }

  Future<GameSubmitResponse> _postGame(
    NetworkManager network,
    GameRecord record,
  ) async {
    final response = await network.send<GameSubmitResponse>(
      path: '/games',
      method: RequestType.post,
      parserModel: GameSubmitResponse.fromJson,
      data: record.toJson(),
    );
    if (response == null) throw NetworkException.emptyResponse();
    return response;
  }

  static bool _isRejected(NetworkException e) {
    final code = e.statusCode;
    return code != null && code >= 400 && code < 500 && code != 401;
  }

  Future<void> _enqueue(GameRecord record) => _prefs.setPendingEvents([
    ..._prefs.pendingEvents,
    jsonEncode(record.toJson()),
  ]);

  /// Kuyruktaki oyunları sırayla gönderir; ağ hatasında durur.
  Future<void> flushPending() async {
    final network = _network;
    if (network == null) return;
    final pending = [..._prefs.pendingEvents];
    while (pending.isNotEmpty) {
      try {
        final record = GameRecord.fromJson(
          jsonDecode(pending.first) as Map<String, dynamic>,
        );
        await _postGame(network, record);
      } on NetworkException catch (e) {
        if (!_isRejected(e)) break;
      } on Object {
        // Bozuk kayıt: atla.
      }
      pending.removeAt(0);
      await _prefs.setPendingEvents(pending);
    }
  }

  /// Altınla satın alır ve kuşanır.
  Future<PlayerProgress> buyItem(ShopItem item) async {
    final network = _network;
    if (network != null) {
      return _remote(network, '/shop/buy', {'item_id': item.id});
    }
    final p = progress;
    if (p.owns(item.id)) return equip(item);
    if (!item.isCoinBuyable) throw const ItemLockedException();
    if (p.coins < item.price) throw const InsufficientCoinsException();
    final updated = _equipLocal(
      p.copyWith(
        coins: p.coins - item.price,
        ownedItems: [
          ...p.ownedItems,
          item.id,
        ],
      ),
      item,
    );
    await _save(updated);
    return updated;
  }

  Future<PlayerProgress> equip(ShopItem item) async {
    final network = _network;
    if (network != null) {
      return _remote(network, '/shop/equip', {'item_id': item.id});
    }
    final p = progress;
    if (!p.owns(item.id)) throw const ItemLockedException();
    final updated = _equipLocal(p, item);
    await _save(updated);
    return updated;
  }

  static PlayerProgress _equipLocal(PlayerProgress p, ShopItem item) =>
      p.copyWith(
        equipped: switch (item.category) {
          ShopCategory.ball => p.equipped.copyWith(ball: item.id),
          ShopCategory.ink => p.equipped.copyWith(ink: item.id),
          ShopCategory.theme => p.equipped.copyWith(theme: item.id),
          null => p.equipped,
        },
      );

  Future<PlayerProgress> _remote(
    NetworkManager network,
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await network.send<PlayerProgress>(
        path: path,
        method: RequestType.post,
        parserModel: PlayerProgress.fromJson,
        data: data,
      );
      if (result == null) throw NetworkException.emptyResponse();
      await _save(result);
      return result;
    } on NetworkException catch (e) {
      throw mapPlayerError(e);
    }
  }

  /// Satın alımları sunucuyla eşitler (`POST /purchases/sync`).
  Future<PlayerProgress> syncPurchases() async {
    final network = _network;
    if (network == null) return progress;
    final result = await network.send<PlayerProgress>(
      path: '/purchases/sync',
      method: RequestType.post,
      parserModel: PlayerProgress.fromJson,
    );
    if (result == null) throw NetworkException.emptyResponse();
    await _save(result);
    return result;
  }

  /// Mock modu: premium'u cihazda açar.
  Future<PlayerProgress> grantPremiumLocal(int bonusCoins) async {
    final p = progress;
    if (p.premium) return p;
    final updated = p.copyWith(
      premium: true,
      coins: p.coins + bonusCoins,
      ownedItems: {...p.ownedItems, ...premiumItems}.toList(),
    );
    await _save(updated);
    return updated;
  }

  /// Mock modu: coin paketi yükler.
  Future<PlayerProgress> grantCoinsLocal(int coins) async {
    final updated = progress.copyWith(coins: progress.coins + coins);
    await _save(updated);
    return updated;
  }

  /// Görev ödülünden sonra bakiye / açılan öğe (sunucu cevabı veya mock).
  Future<void> applyTaskReward({
    required int coins,
    String? unlockedItem,
  }) async {
    final p = progress;
    await _save(
      p.copyWith(
        coins: coins,
        ownedItems: unlockedItem == null || p.owns(unlockedItem)
            ? null
            : [...p.ownedItems, unlockedItem],
      ),
    );
  }

  /// Klip/skor paylaşımı (görevler için). Hata kullanıcıya gösterilmez.
  Future<void> recordShare() async {
    try {
      await _network?.send<OkResponse>(
        path: '/events/share',
        method: RequestType.post,
        parserModel: OkResponse.fromJson,
        data: {'client_event_id': IdGenerator.uuid()},
      );
    } on NetworkException {
      // Görev ilerlemesi bir sonraki paylaşımda yakalanır.
    }
  }

  Future<void> _save(PlayerProgress p) async {
    final stored = p.copyWith(rewards: const []);
    await _prefs.setProgressJson(jsonEncode(stored.toJson()));
    _changes.add(_withTutorial(stored));
  }
}
