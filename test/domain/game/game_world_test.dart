// Testlerde adım adım okunabilirlik için cascade kullanılmadı.
// ignore_for_file: cascade_invocations

import 'package:dashink/domain/game/game_world.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CourseGenerator', () {
    test('aynı seed aynı parkuru üretir (günlük meydan okuma)', () {
      List<double> layout(int seed) {
        final platforms = <Platform>[];
        CourseGenerator(seed).generate(8000, platforms, [], []);
        return [
          for (final p in platforms) ...[p.left, p.right, p.top],
        ];
      }

      expect(layout(42), layout(42));
      expect(layout(42), isNot(layout(43)));
    });

    test('parkur çeşitli: en az 6 bölüm tipi, aynı tip art arda gelmez', () {
      final gen = CourseGenerator(5);
      gen.generate(30000, [], [], []);
      expect(gen.kinds.toSet().length, greaterThanOrEqualTo(6));
      // Isınmadan (ilk 2 bölüm) sonra aynı tip art arda gelmez.
      for (var i = 3; i < gen.kinds.length; i++) {
        expect(gen.kinds[i], isNot(gen.kinds[i - 1]));
      }
      // İlk bölümler ısınma: klasik boşluk.
      expect(gen.kinds.take(2), everyElement(SegmentKind.gap));
    });

    test('altınlar topun yoluna yakın (çok yukarıda değil)', () {
      for (final seed in [1, 7, 42, 1234]) {
        final platforms = <Platform>[];
        final coins = <Coin>[];
        CourseGenerator(seed).generate(20000, platforms, [], coins);
        for (final coin in coins) {
          final x = coin.position.x;
          final nearby = platforms.where(
            (p) => p.right > x - 400 && p.left < x + 400,
          );
          final highest = nearby
              .map((p) => p.top)
              .reduce(
                (a, b) => a < b ? a : b,
              );
          expect(
            coin.position.y,
            greaterThanOrEqualTo(highest - 100),
            reason: 'seed $seed, altın ${coin.position}',
          );
        }
      }
    });

    test(
      'tüm altınları toplayan oyuncu sunucu sınırını aşmaz (≤ skor/2 + 5)',
      () {
        // Sunucu (score.js): coins_collected <= floor(score / 2) + 5.
        for (final seed in [1, 2, 3, 7, 42, 99, 1234, 777777]) {
          final coins = <Coin>[];
          CourseGenerator(seed).generate(40000, [], [], coins);
          final xs = coins.map((c) => c.position.x).toList()..sort();
          for (var i = 0; i < xs.length; i++) {
            final score = ((xs[i] - GameRules.startX) / GameRules.unitsPerPoint)
                .floor();
            expect(
              i + 1,
              lessThanOrEqualTo(score ~/ 2 + 5),
              reason: 'seed $seed, x=${xs[i].round()}',
            );
          }
        }
      },
    );

    test('platformlar oynanabilir yükseklik aralığında', () {
      final platforms = <Platform>[];
      CourseGenerator(9).generate(30000, platforms, [], []);
      for (final p in platforms) {
        expect(p.top, inInclusiveRange(440, 660));
        expect(p.width, greaterThan(0));
      }
    });

    test('ilk platform güvenli ve topun altında', () {
      final world = GameWorld(seed: 1);
      final first = world.platforms.first;
      expect(first.left, lessThan(GameRules.startX));
      expect(first.right, greaterThan(GameRules.startX + 300));
      expect(world.spikes.every((s) => s.left > first.right), isTrue);
    });
  });

  group('GameWorld', () {
    void run(GameWorld world, double seconds, {void Function()? each}) {
      var t = 0.0;
      while (t < seconds && !world.isOver) {
        each?.call();
        world.step(1 / 60);
        t += 1 / 60;
      }
    }

    test('ölüm animasyonu yalnız oyun bitince ilerler', () {
      final world = GameWorld(seed: 7);
      world.advanceDeath(0.1);
      expect(world.deathElapsed, 0);
      run(world, 20);
      expect(world.isOver, isTrue);
      final x = world.ballPosition.x;
      world.advanceDeath(0.2);
      world.step(0.2);
      expect(world.deathElapsed, closeTo(0.05, 1e-9)); // tek adım en fazla 0.05
      expect(world.ballPosition.x, x); // fizik durdu
    });

    test('çizgi çizilmezse top ilk boşluğa düşer', () {
      final world = GameWorld(seed: 7);
      run(world, 20);
      expect(world.deathCause, DeathCause.fall);
      expect(world.score, greaterThan(5));
    });

    test('topun önüne çizilen köprü boşluğu geçirir', () {
      final world = GameWorld(seed: 7);
      final firstGapStart = world.platforms.first.right;
      final next = world.platforms[1];
      while (world.ballPosition.x < firstGapStart - 50) {
        world.step(1 / 60);
      }
      expect(world.isOver, isFalse);
      // Boşluğun üstüne düz bir köprü çiz (top yaklaşırken).
      final y = world.platforms.first.top - 2;
      world.beginStroke(Vec2(firstGapStart - 40, y));
      for (var x = firstGapStart - 40; x <= next.left + 40; x += 10) {
        world.extendStroke(Vec2(x, y + (next.top - y) * 0.5));
      }
      world.endStroke();
      run(world, 0.95);
      expect(world.isOver, isFalse);
      expect(world.ballPosition.x, greaterThan(next.left));
    });

    test('yokuşta yavaşlamaz: dik rampada da hedef hızda çıkar', () {
      final world = GameWorld(seed: 1);
      final y = world.platforms.first.top;
      // 40°'lik rampa: topun hemen önünden yukarı.
      const dx = 220.0;
      const rise = dx * 0.84;
      world.beginStroke(Vec2(GameRules.startX + 30, y));
      for (var x = 0.0; x <= dx; x += 8) {
        world.extendStroke(Vec2(GameRules.startX + 30 + x, y - x * 0.84));
      }
      world.endStroke();
      var minSpeed = double.infinity;
      final startY = world.ballPosition.y;
      for (var i = 0; i < 50 && !world.isOver; i++) {
        world.step(1 / 60);
        // Rampanın ortasında (yükselmeye başladıktan sonra) hızı ölç.
        if (startY - world.ballPosition.y > rise * 0.2 &&
            startY - world.ballPosition.y < rise * 0.8) {
          final speed = world.ballVelocity.length;
          if (speed < minSpeed) minSpeed = speed;
        }
      }
      expect(minSpeed, isNot(double.infinity), reason: 'top rampaya çıkmadı');
      expect(minSpeed, greaterThan(world.targetSpeed * 0.85));
    });

    test('mürekkep çizdikçe azalır, bırakınca dolar', () {
      final world = GameWorld(seed: 3);
      world.beginStroke(const Vec2(200, 300));
      world.extendStroke(const Vec2(650, 300));
      world.endStroke();
      expect(world.ink, closeTo(0.5, 0.01));
      run(world, 1);
      expect(world.ink, greaterThan(0.7));
    });

    test('mürekkep 1 saniyede silinir', () {
      final world = GameWorld(seed: 3);
      world.beginStroke(const Vec2(200, 300));
      world.extendStroke(const Vec2(260, 300));
      world.endStroke();
      expect(world.strokes, hasLength(1));
      run(world, GameRules.inkLifetime + 0.1);
      expect(world.strokes, isEmpty);
    });

    test('mürekkep bitince çizgi uzamaz', () {
      final world = GameWorld(seed: 3)
        ..ink = 0.05
        ..beginStroke(const Vec2(0, 300))
        ..extendStroke(const Vec2(500, 300));
      expect(world.ink, 0);
      final end = world.strokes.single.points.last.position;
      expect(end.x, closeTo(GameRules.inkCapacity * 0.05, 0.5));
    });
  });
}
