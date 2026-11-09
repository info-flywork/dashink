import 'package:dashink/core/managers/shared_pref_manager.dart';
import 'package:dashink/data/model/shop/shop_catalog.dart';
import 'package:dashink/domain/game/game_record.dart';
import 'package:dashink/domain/player/player_exceptions.dart';
import 'package:dashink/domain/player/player_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

GameRecord _game(int score, {int coins = 0}) => GameRecord(
  clientEventId: 'e$score',
  mode: GameMode.normal,
  seed: 1,
  score: score,
  coinsCollected: coins,
  durationMs: 20000,
);

const _karpuz = ShopItem(
  id: 'ball_karpuz',
  category: ShopCategory.ball,
  price: 200,
  unlock: ShopUnlock.coins,
);

void main() {
  late PlayerRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPrefManager.instance.init();
    repo = PlayerRepository(SharedPrefManager.instance);
  });

  group('submitGame (yerel / mock modu)', () {
    test('ilk oyun rekor sayılmaz ama en iyi skor olur', () async {
      final outcome = await repo.submitGame(_game(40, coins: 7));
      expect(outcome.newRecord, isFalse);
      expect(outcome.bestScore, 40);
      expect(outcome.coinsCredited, 7);
      expect(repo.progress.coins, 7);
      expect(repo.progress.gamesPlayed, 1);
    });

    test('önceki en iyiyi geçmek rekor + 50 altın', () async {
      await repo.submitGame(_game(40));
      final outcome = await repo.submitGame(_game(55, coins: 3));
      expect(outcome.newRecord, isTrue);
      expect(outcome.previousBest, 40);
      expect(outcome.improvement, 15);
      expect(outcome.recordReward, GameOutcome.recordRewardCoins);
      expect(repo.progress.coins, 3 + GameOutcome.recordRewardCoins);
    });

    test('eşit skor rekor değildir', () async {
      await repo.submitGame(_game(40));
      final outcome = await repo.submitGame(_game(40));
      expect(outcome.newRecord, isFalse);
    });
  });

  group('mağaza (yerel)', () {
    test('altın yetmezse InsufficientCoinsException', () async {
      expect(
        () => repo.buyItem(_karpuz),
        throwsA(isA<InsufficientCoinsException>()),
      );
    });

    test('satın alınca altın düşer, öğe sahip ve kuşanılı olur', () async {
      await repo.submitGame(_game(10, coins: 250));
      final p = await repo.buyItem(_karpuz);
      expect(p.coins, 50);
      expect(p.owns('ball_karpuz'), isTrue);
      expect(p.equipped.ball, 'ball_karpuz');
    });

    test('görev / premium öğeleri altınla alınamaz', () async {
      const disko = ShopItem(
        id: 'ball_disko',
        category: ShopCategory.ball,
        unlock: ShopUnlock.task,
      );
      expect(() => repo.buyItem(disko), throwsA(isA<ItemLockedException>()));
    });

    test('premium yerelde bir kez verilir', () async {
      await repo.grantPremiumLocal(1000);
      await repo.grantPremiumLocal(1000);
      expect(repo.progress.premium, isTrue);
      expect(repo.progress.coins, 1000);
      expect(repo.progress.owns('theme_gece'), isTrue);
    });
  });

  test('ilerleme değişince yayın yapılır', () async {
    final next = repo.changes.first;
    await repo.submitGame(_game(12, coins: 2));
    expect((await next).coins, 2);
  });

  group('updateName (yerel)', () {
    test('geçerli adı kaydeder', () async {
      final p = await repo.updateName('  Zeynep  ');
      expect(p.user?.name, 'Zeynep');
      expect(repo.progress.user?.name, 'Zeynep');
    });

    test('geçersiz ad InvalidPlayerNameException fırlatır', () async {
      expect(
        () => repo.updateName('A'),
        throwsA(isA<InvalidPlayerNameException>()),
      );
      expect(
        () => repo.updateName('bad@name'),
        throwsA(isA<InvalidPlayerNameException>()),
      );
    });
  });
}
