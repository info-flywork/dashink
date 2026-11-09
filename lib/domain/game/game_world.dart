import 'dart:math' as math;

/// 2B vektör (oyun motoru Flutter'dan bağımsız; birim testlenebilir).
class Vec2 {
  const Vec2(this.x, this.y);

  static const Vec2 zero = Vec2(0, 0);

  final double x;
  final double y;

  Vec2 operator +(Vec2 o) => Vec2(x + o.x, y + o.y);
  Vec2 operator -(Vec2 o) => Vec2(x - o.x, y - o.y);
  Vec2 operator *(double s) => Vec2(x * s, y * s);

  double dot(Vec2 o) => x * o.x + y * o.y;
  double get length => math.sqrt(x * x + y * y);
  double distanceTo(Vec2 o) => (this - o).length;

  @override
  String toString() => 'Vec2(${x.toStringAsFixed(1)}, ${y.toStringAsFixed(1)})';
}

/// Zemin bloğu (uçurum): üst kenarı [top], soldan [left] sağa [right].
class Platform {
  const Platform({required this.left, required this.right, required this.top});

  final double left;
  final double right;
  final double top;

  double get width => right - left;
}

/// Sivri engel: tabanı [left]..[left]+[width], tepe [top] - [height].
class Spike {
  const Spike({required this.left, required this.top, this.width = 34});

  static const double height = 32;

  final double left;
  final double top;
  final double width;

  Vec2 get a => Vec2(left, top);
  Vec2 get b => Vec2(left + width, top);
  Vec2 get apex => Vec2(left + width / 2, top - height);
}

class Coin {
  Coin(this.position);

  static const double radius = 16;

  final Vec2 position;
  bool collected = false;

  /// Toplandığı oyun zamanı (+1 animasyonu için).
  double collectedAt = 0;
}

/// Mürekkep noktası: [bornAt] anında çizildi, [GameRules.inkLifetime] sonra
/// silinir.
class InkPoint {
  const InkPoint(this.position, this.bornAt);

  final Vec2 position;
  final double bornAt;
}

/// Tek bir parmak hareketiyle çizilen çizgi.
class InkStroke {
  final List<InkPoint> points = [];

  bool alive(double now) =>
      points.isNotEmpty && now - points.last.bornAt < GameRules.inkLifetime;
}

enum DeathCause { fall, spike }

/// Oyun kuralları / ayarları (tasarım pikselleri, saniye).
abstract final class GameRules {
  static const double ballRadius = 21;
  static const double gravity = 1900;
  // İlk hız 230'du; yokuş / uzun köprüde yetmiyordu. Üst sınır sunucu
  // sınırının (saniyede en fazla 15 puan = 600 px/s) rahatça altında.
  static const double startSpeed = 300;
  static const double maxSpeed = 500;
  static const double speedGainPerSecond = 3.2;

  /// Mürekkep 1 saniyede silinir (Figma: eğitim balonu).
  static const double inkLifetime = 1;

  /// Bir dolu hazne ile çizilebilecek uzunluk.
  static const double inkCapacity = 900;
  static const double inkRefillPerSecond = 0.28;
  static const double inkMinPointSpacing = 7;
  static const double inkThickness = 9;

  /// Skor: kat edilen mesafe / [unitsPerPoint].
  static const double unitsPerPoint = 40;

  /// Görünür dünyanın üst sınırının altı; bunu geçen top düşmüş sayılır.
  static const double deathY = 1150;

  static const double startX = 120;
  static const double groundY = 560;
}

/// Parkur bölüm tipleri: her bölüm farklı bir hareket ister, sıra seed'e
/// bağlıdır (günlük parkurda herkes aynı sırayı görür).
enum SegmentKind {
  /// Klasik: boşluk + platform (+ zorlukla sivri).
  gap,

  /// Kısa, yükselen veya alçalan basamaklar.
  stairs,

  /// Uzun köprü isteyen geniş uçurum.
  chasm,

  /// Dar sütunlar, kısa boşluklar: hızlı ritim.
  pillars,

  /// Belirgin biçimde yüksekte duran platform: rampa çizmek gerekir.
  climb,

  /// Belirgin biçimde aşağıda: düşüşü yumuşat.
  drop,

  /// Uzun platform üzerinde aralıklı sivri kümeleri.
  spikeRun,
}

/// Tohumlu (seed) parkur üreteci: aynı seed herkese aynı parkuru verir
/// (günlük meydan okuma). Bölümler soldan sağa, kamera ilerledikçe üretilir;
/// tipleri zorlukla açılır ve art arda aynı tip gelmez.
class CourseGenerator {
  CourseGenerator(int seed) : _random = math.Random(seed);

  final math.Random _random;
  double _cursor = -300;
  double _lastTop = GameRules.groundY;
  int _index = 0;
  SegmentKind? _lastKind;

  /// Üretilen bölüm tipleri (test / hata ayıklama).
  final List<SegmentKind> kinds = [];

  static const double _minTop = 440;
  static const double _maxTop = 660;

  /// Topun merkezi zemindeyken platform üstünden bu kadar yukarıdadır.
  static const double _rollHeight = GameRules.ballRadius + 4;

  double get generatedUntil => _cursor;

  double _range(double min, double max) =>
      min + _random.nextDouble() * (max - min);

  double get _difficulty => (_index / 25).clamp(0.0, 1.0);

  /// [untilX]'e kadar parkur üretir.
  void generate(
    double untilX,
    List<Platform> platforms,
    List<Spike> spikes,
    List<Coin> coins,
  ) {
    while (_cursor < untilX) {
      if (_index == 0) {
        // Güvenli başlangıç: geniş düz zemin.
        final p = Platform(left: _cursor, right: 620, top: GameRules.groundY);
        platforms.add(p);
        _cursor = p.right;
        _index++;
        continue;
      }
      final kind = _pickKind();
      kinds.add(kind);
      _lastKind = kind;
      switch (kind) {
        case SegmentKind.gap:
          _gap(platforms, spikes, coins);
        case SegmentKind.stairs:
          _stairs(platforms, coins);
        case SegmentKind.chasm:
          _chasm(platforms, coins);
        case SegmentKind.pillars:
          _pillars(platforms, coins);
        case SegmentKind.climb:
          _step(platforms, coins, rise: _range(110, 150));
        case SegmentKind.drop:
          _step(platforms, coins, rise: -_range(110, 160));
        case SegmentKind.spikeRun:
          _spikeRun(platforms, spikes, coins);
      }
    }
  }

  /// İlk bölümler klasik; sonra tipler zorlukla açılır, aynısı art arda
  /// gelmez.
  SegmentKind _pickKind() {
    if (_index < 3) return SegmentKind.gap;
    final d = _difficulty;
    final weights = <SegmentKind, double>{
      SegmentKind.gap: 3,
      SegmentKind.stairs: 1.6,
      SegmentKind.drop: 1.2,
      SegmentKind.climb: d > 0.15 ? 1.2 : 0,
      SegmentKind.pillars: d > 0.2 ? 1.3 : 0,
      SegmentKind.chasm: d > 0.3 ? 1 + d : 0,
      SegmentKind.spikeRun: d > 0.35 ? 1 + d : 0,
    }..remove(_lastKind);
    final total = weights.values.fold<double>(0, (a, b) => a + b);
    var roll = _random.nextDouble() * total;
    for (final e in weights.entries) {
      roll -= e.value;
      if (roll <= 0) return e.key;
    }
    return SegmentKind.gap;
  }

  /// Boşluk + platform ekler; boşluğun üstüne topun yuvarlanacağı / köprüden
  /// geçeceği yükseklikte altın dizer.
  Platform _add(
    List<Platform> platforms,
    List<Coin> coins, {
    required double gap,
    required double width,
    required double top,
    bool coinsOverGap = true,
  }) {
    final clamped = top.clamp(_minTop, _maxTop);
    final left = _cursor + gap;
    final platform = Platform(left: left, right: left + width, top: clamped);
    platforms.add(platform);
    if (coinsOverGap && gap >= 80) {
      // Köprü çizgisi iki kenar arasında: altınlar o çizginin hemen üstünde,
      // ortada hafif kavisli (eskiden 90–150 px yukarıdaydı).
      final count = 2 + (gap ~/ 130).clamp(0, 2);
      for (var i = 0; i < count; i++) {
        final t = count == 1 ? 0.5 : i / (count - 1);
        final x = _cursor + gap * (0.12 + 0.76 * t);
        final edgeY = _lastTop + (clamped - _lastTop) * t;
        final y = edgeY - _rollHeight - 14 - math.sin(t * math.pi) * 22;
        coins.add(Coin(Vec2(x, y)));
      }
    }
    _lastTop = clamped;
    _cursor = platform.right;
    _index++;
    return platform;
  }

  void _gap(List<Platform> platforms, List<Spike> spikes, List<Coin> coins) {
    final d = _difficulty;
    final width = _range(200 - d * 60, 420 - d * 140);
    final p = _add(
      platforms,
      coins,
      gap: _range(90, 140 + d * 130),
      width: width,
      top: _lastTop + _range(-70, 70),
    );
    final spikeChance = 0.18 + d * 0.42;
    if (width > 230 && _random.nextDouble() < spikeChance) {
      _spikeCluster(p, spikes, coins, 1 + _random.nextInt(d > 0.5 ? 3 : 2));
    } else if (_random.nextDouble() < 0.4) {
      _rollingCoins(p, coins, 2);
    }
  }

  void _stairs(List<Platform> platforms, List<Coin> coins) {
    final up = _lastTop > 520 || (_lastTop > 480 && _random.nextBool());
    final steps = 3 + _random.nextInt(2);
    for (var i = 0; i < steps; i++) {
      final p = _add(
        platforms,
        coins,
        gap: _range(60, 95),
        width: _range(110, 160),
        top: _lastTop + (up ? -1 : 1) * _range(35, 55),
        coinsOverGap: false,
      );
      _rollingCoins(p, coins, 1);
    }
  }

  void _chasm(List<Platform> platforms, List<Coin> coins) {
    final d = _difficulty;
    _add(
      platforms,
      coins,
      gap: _range(230, 280 + d * 60),
      width: _range(260, 360),
      top: _lastTop + _range(-40, 40),
    );
  }

  void _pillars(List<Platform> platforms, List<Coin> coins) {
    final count = 3 + _random.nextInt(3);
    for (var i = 0; i < count; i++) {
      final p = _add(
        platforms,
        coins,
        gap: _range(55, 90),
        width: _range(80, 120),
        top: _lastTop + _range(-30, 30),
        coinsOverGap: false,
      );
      if (i.isOdd) _rollingCoins(p, coins, 1);
    }
  }

  void _step(
    List<Platform> platforms,
    List<Coin> coins, {
    required double rise,
  }) {
    // Yükseliş negatif y'dir; sınırlara takılırsa ters yöne çevrilir.
    var target = _lastTop - rise;
    if (target < _minTop || target > _maxTop) target = _lastTop + rise;
    final p = _add(
      platforms,
      coins,
      gap: _range(100, 150),
      width: _range(240, 340),
      top: target,
    );
    _rollingCoins(p, coins, 2);
  }

  void _spikeRun(
    List<Platform> platforms,
    List<Spike> spikes,
    List<Coin> coins,
  ) {
    final p = _add(
      platforms,
      coins,
      gap: _range(90, 130),
      width: _range(560, 720),
      top: _lastTop + _range(-40, 40),
    );
    // İki-üç küme; aralarda topun inip yeniden zıplayabileceği boşluk.
    final clusters = 2 + (_difficulty > 0.7 ? 1 : 0);
    final span = p.width - 160;
    for (var c = 0; c < clusters; c++) {
      final count = 1 + _random.nextInt(2);
      final start = p.left + 90 + span * (c + 0.5) / clusters - count * 17;
      _spikeAt(p, spikes, coins, start, count);
    }
  }

  void _spikeCluster(
    Platform p,
    List<Spike> spikes,
    List<Coin> coins,
    int count,
  ) {
    const spikeWidth = 34.0;
    final start = p.left + _range(70, p.width - count * spikeWidth - 50);
    _spikeAt(p, spikes, coins, start, count);
  }

  void _spikeAt(
    Platform p,
    List<Spike> spikes,
    List<Coin> coins,
    double start,
    int count,
  ) {
    const spikeWidth = 34.0;
    for (var i = 0; i < count; i++) {
      spikes.add(Spike(left: start + i * spikeWidth, top: p.top));
    }
    // Sivrinin üstünden atlarken toplanan ödül (atlama tepesine yakın).
    coins.add(Coin(Vec2(start + count * spikeWidth / 2, p.top - 88)));
  }

  /// Platform üstünde, yuvarlanırken toplanan sıra.
  void _rollingCoins(Platform p, List<Coin> coins, int count) {
    for (var i = 0; i < count; i++) {
      final t = (i + 1) / (count + 1);
      coins.add(Coin(Vec2(p.left + p.width * t, p.top - _rollHeight)));
    }
  }
}

/// Oyunun anlık durumu ve fizik adımı. Ekran / Flutter bilmez; görünüm
/// `GameWorld`'ü okur ve çizer.
class GameWorld {
  GameWorld({required this.seed, this.viewWidth = 430})
    : _generator = CourseGenerator(seed) {
    ballPosition = const Vec2(
      GameRules.startX,
      GameRules.groundY - GameRules.ballRadius,
    );
    _generator.generate(cameraX + viewWidth * 2, platforms, spikes, coins);
  }

  final int seed;
  final CourseGenerator _generator;

  /// Görünür dünya genişliği (tasarım pikseli); üretim ve kamera için.
  double viewWidth;

  final List<Platform> platforms = [];
  final List<Spike> spikes = [];
  final List<Coin> coins = [];
  final List<InkStroke> strokes = [];

  late Vec2 ballPosition;
  Vec2 ballVelocity = const Vec2(GameRules.startSpeed, 0);

  /// Topun yuvarlanma açısı (radyan), görsel için.
  double ballRotation = 0;

  double time = 0;

  /// 0..1 mürekkep haznesi.
  double ink = 1;
  int coinsCollected = 0;
  DeathCause? deathCause;
  bool _drawing = false;
  InkStroke? _activeStroke;

  bool get isOver => deathCause != null;

  /// Ölümden bu yana geçen süre (yalnız ölüm animasyonu için; fizik durur).
  double deathElapsed = 0;

  /// Oyun bittikten sonra ölüm animasyonunu ilerletir.
  void advanceDeath(double dt) {
    if (isOver) deathElapsed += math.min(dt, 0.05);
  }

  double get cameraX => ballPosition.x - viewWidth * 0.3;

  /// Yukarı çıkan topu takip eder (aşağı kaymaz).
  double get cameraY => math.min(0, ballPosition.y - 180);

  double get distance => math.max(0, ballPosition.x - GameRules.startX);

  int get score => (distance / GameRules.unitsPerPoint).floor();

  double get targetSpeed => math.min(
    GameRules.maxSpeed,
    GameRules.startSpeed + time * GameRules.speedGainPerSecond,
  );

  // --- Çizim --------------------------------------------------------------

  void beginStroke(Vec2 point) {
    if (isOver) return;
    _drawing = true;
    final stroke = InkStroke();
    strokes.add(stroke);
    _activeStroke = stroke;
    _addPoint(stroke, point);
  }

  /// Parmak hareketi. Mürekkep bittiyse çizgi uzamaz. Eklenen uzunluğu
  /// döndürür (ses/geri bildirim için).
  double extendStroke(Vec2 point) {
    final stroke = _activeStroke;
    if (stroke == null || isOver) return 0;
    final last = stroke.points.last.position;
    final length = last.distanceTo(point);
    if (length < GameRules.inkMinPointSpacing) return 0;
    final cost = length / GameRules.inkCapacity;
    if (ink <= 0) return 0;
    var target = point;
    if (cost > ink) {
      // Kalan mürekkep kadar uzat.
      final ratio = ink / cost;
      target = last + (point - last) * ratio;
    }
    ink = math.max(0, ink - cost);
    _addPoint(stroke, target);
    return length;
  }

  void endStroke() {
    _drawing = false;
    _activeStroke = null;
  }

  void _addPoint(InkStroke stroke, Vec2 p) =>
      stroke.points.add(InkPoint(p, time));

  // --- Adım ---------------------------------------------------------------

  /// [dt] saniye ilerletir. Toplanan altın sayısını döndürür.
  int step(double dt) {
    if (isOver) return 0;
    var collected = 0;
    var remaining = math.min(dt, 0.05);
    while (remaining > 0) {
      final h = math.min(remaining, 1 / 240);
      collected += _substep(h);
      remaining -= h;
      if (isOver) break;
    }
    if (!_drawing) {
      ink = math.min(1, ink + GameRules.inkRefillPerSecond * dt);
    }
    _cleanup();
    return collected;
  }

  int _substep(double h) {
    time += h;
    var v = ballVelocity + const Vec2(0, GameRules.gravity) * h;
    var p = ballPosition + v * h;
    const r = GameRules.ballRadius;
    var grounded = false;
    Vec2? groundNormal;

    void resolve(Vec2 a, Vec2 b) {
      final closest = _closestPoint(p, a, b);
      final delta = p - closest;
      final d = delta.length;
      if (d >= r || d == 0) return;
      final n = delta * (1 / d);
      p = p + n * (r - d);
      final vn = v.dot(n);
      if (vn < 0) v = v - n * (vn * 1.05);
      if (n.y < -0.35) {
        grounded = true;
        groundNormal = n;
      }
    }

    for (final platform in platforms) {
      if (platform.right < p.x - 60 || platform.left > p.x + 60) continue;
      resolve(
        Vec2(platform.left, platform.top),
        Vec2(platform.right, platform.top),
      );
      // Uçurum duvarları: top boşluğa düşerken duvara takılır.
      resolve(
        Vec2(platform.left, platform.top),
        Vec2(platform.left, platform.top + 900),
      );
      resolve(
        Vec2(platform.right, platform.top),
        Vec2(platform.right, platform.top + 900),
      );
    }
    for (final stroke in strokes) {
      final pts = stroke.points;
      for (var i = 1; i < pts.length; i++) {
        if (time - pts[i - 1].bornAt >= GameRules.inkLifetime) continue;
        final a = pts[i - 1].position;
        final b = pts[i].position;
        if (math.max(a.x, b.x) < p.x - r - 4) continue;
        if (math.min(a.x, b.x) > p.x + r + 4) continue;
        resolve(a, b);
      }
    }

    // İleri sürüş: zemindeyken eğim boyunca hedef hıza, havadayken yavaşça.
    final target = targetSpeed;
    final n = groundNormal;
    if (grounded && n != null) {
      final tangent = Vec2(-n.y, n.x);
      final t = tangent.x < 0 ? tangent * -1 : tangent;
      // Yerçekiminin eğim boyunca olan payı iptal edilir: top yokuş yukarı
      // yavaşlayıp durmaz, yokuş aşağı da kontrolsüz hızlanmaz (yüzeye
      // bastıran pay kalır). Böylece her eğimde hedef hızda yuvarlanır.
      const gravity = Vec2(0, GameRules.gravity);
      v = v - t * (gravity.dot(t) * h);
      final vt = v.dot(t);
      final accel = ((target - vt) * 6).clamp(-900.0, 900.0);
      v = v + t * (accel * h);
    } else {
      final ax = ((target - v.x) * 0.6).clamp(-200.0, 200.0);
      v = Vec2(v.x + ax * h, v.y);
    }

    ballPosition = p;
    ballVelocity = v;
    ballRotation += v.x * h / r;

    var collected = 0;
    for (final coin in coins) {
      if (coin.collected) continue;
      if ((coin.position - p).length < r + Coin.radius) {
        coin
          ..collected = true
          ..collectedAt = time;
        coinsCollected++;
        collected++;
      }
    }

    for (final spike in spikes) {
      if (spike.left > p.x + r || spike.left + spike.width < p.x - r) continue;
      if (_circleHitsTriangle(p, r * 0.82, spike.a, spike.apex, spike.b)) {
        deathCause = DeathCause.spike;
        return collected;
      }
    }
    if (p.y - cameraY > GameRules.deathY || p.y > GameRules.deathY + 400) {
      deathCause = DeathCause.fall;
    }
    return collected;
  }

  void _cleanup() {
    strokes.removeWhere(
      (s) => !identical(s, _activeStroke) && !s.alive(time),
    );
    final left = cameraX - 200;
    final active = _activeStroke;
    if (active != null) {
      active.points.removeWhere(
        (pt) => time - pt.bornAt >= GameRules.inkLifetime + 0.2,
      );
    }
    platforms.removeWhere((p) => p.right < left);
    spikes.removeWhere((s) => s.left + s.width < left);
    coins.removeWhere((c) => c.position.x < left);
    _generator.generate(cameraX + viewWidth * 2, platforms, spikes, coins);
  }

  static Vec2 _closestPoint(Vec2 p, Vec2 a, Vec2 b) {
    final ab = b - a;
    final len2 = ab.dot(ab);
    if (len2 == 0) return a;
    final t = ((p - a).dot(ab) / len2).clamp(0.0, 1.0);
    return a + ab * t;
  }

  static bool _circleHitsTriangle(Vec2 c, double r, Vec2 a, Vec2 b, Vec2 d) {
    if (_pointInTriangle(c, a, b, d)) return true;
    for (final (u, w) in [(a, b), (b, d), (d, a)]) {
      if ((c - _closestPoint(c, u, w)).length < r) return true;
    }
    return false;
  }

  static bool _pointInTriangle(Vec2 p, Vec2 a, Vec2 b, Vec2 c) {
    double sign(Vec2 p1, Vec2 p2, Vec2 p3) =>
        (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
    final d1 = sign(p, a, b);
    final d2 = sign(p, b, c);
    final d3 = sign(p, c, a);
    final hasNeg = d1 < 0 || d2 < 0 || d3 < 0;
    final hasPos = d1 > 0 || d2 > 0 || d3 > 0;
    return !(hasNeg && hasPos);
  }
}
