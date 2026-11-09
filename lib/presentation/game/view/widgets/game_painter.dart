part of '../game_view.dart';

/// Oyunda çizilen görseller (önceden yüklenmiş).
class GameSprites {
  const GameSprites({required this.ball, required this.coin, this.cloud});

  final ui.Image ball;
  final ui.Image coin;
  final ui.Image? cloud;

  static Future<ui.Image> _load(AssetGenImage asset) async {
    final data = await rootBundle.load(asset.path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    return (await codec.getNextFrame()).image;
  }

  static Future<GameSprites> load(String ballId) async {
    final images = await Future.wait([
      _load(ItemAssets.ballImage(ballId)),
      _load(Assets.images.coin),
      _load(Assets.images.eCloud),
    ]);
    return GameSprites(ball: images[0], coin: images[1], cloud: images[2]);
  }

  void dispose() {
    ball.dispose();
    coin.dispose();
    cloud?.dispose();
  }
}

/// Görünüm ayarları (kuşanılı mürekkep / tema).
class GameLook {
  const GameLook({
    required this.ink,
    required this.dark,
    this.background = const Color(0xFF2B3260),
  });

  final Color ink;
  final bool dark;

  /// Tema zemin rengi; koyu temalarda platform rengi bundan türetilir
  /// (gece lacivert, orman yeşil, uzay mor-siyah).
  final Color background;

  Color get line => dark ? const Color(0xFFE8E4F5) : ColorName.ink;
  Color get ground => dark
      ? Color.alphaBlend(Colors.white.withValues(alpha: 0.1), background)
      : ColorName.paperCard;
}

/// Dünyayı çizer: bulutlar (paralaks), uçurumlar, sivriler, altınlar,
/// mürekkep ve top. Kamera: ölçek = ekran genişliği / 430.
class GamePainter extends CustomPainter {
  GamePainter({
    required this.world,
    required this.sprites,
    required this.look,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final GameWorld world;
  final GameSprites? sprites;
  final GameLook look;

  static const double designWidth = 430;

  /// Ölüm animasyonu; oyun sonu diyaloğu bundan sonra açılır.
  static const Duration deathAnimation = Duration(milliseconds: 380);
  static const double _deathSeconds = 0.38;

  final List<Offset> _trail = [];

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / designWidth;
    final camX = world.cameraX;
    final camY = world.cameraY;
    final viewW = size.width / scale;

    canvas
      ..save()
      ..scale(scale);
    // Ölüm anında kısa sarsıntı.
    if (world.isOver && world.deathElapsed < 0.25) {
      final k = 1 - world.deathElapsed / 0.25;
      canvas.translate(math.sin(world.deathElapsed * 90) * 5 * k, 0);
    }
    _paintClouds(canvas, camX, viewW);
    canvas.translate(-camX, -camY);

    final visibleBottom = camY + size.height / scale + 40;
    for (final p in world.platforms) {
      if (p.right < camX - 20 || p.left > camX + viewW + 20) continue;
      _paintPlatform(canvas, p, visibleBottom);
    }
    for (final s in world.spikes) {
      if (s.left + s.width < camX || s.left > camX + viewW) continue;
      _paintSpike(canvas, s);
    }
    _paintCoins(canvas, camX, viewW);
    _paintInk(canvas);
    _paintBall(canvas);
    canvas.restore();
  }

  void _paintClouds(Canvas canvas, double camX, double viewW) {
    final cloud = sprites?.cloud;
    if (cloud == null) return;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: look.dark ? 0.12 : 0.55)
      ..filterQuality = FilterQuality.medium;
    const spacing = 360.0;
    final offset = camX * 0.25;
    final first = (offset / spacing).floor() - 1;
    for (var i = first; i < first + viewW / spacing + 3; i++) {
      final x = i * spacing - offset;
      final y = 140.0 + (i * 97 % 5) * 46;
      final dst = Rect.fromLTWH(x, y, 150, 77);
      canvas.drawImageRect(
        cloud,
        Rect.fromLTWH(0, 0, cloud.width.toDouble(), cloud.height.toDouble()),
        dst,
        paint,
      );
    }
  }

  void _paintPlatform(Canvas canvas, Platform p, double bottom) {
    final rect = Rect.fromLTRB(p.left, p.top, p.right, bottom);
    final body = RRect.fromRectAndCorners(
      rect,
      topLeft: const Radius.circular(10),
      topRight: const Radius.circular(10),
    );
    canvas.drawRRect(body, Paint()..color = look.ground);

    // Kalem taraması (çapraz çizgiler), uçurum dokusu.
    final hatch = Paint()
      ..color = look.line.withValues(alpha: 0.18)
      ..strokeWidth = 1.4;
    canvas
      ..save()
      ..clipRRect(body);
    for (var x = p.left - 200; x < p.right; x += 14) {
      canvas.drawLine(
        Offset(x, p.top + 26),
        Offset(x + 120, p.top + 220),
        hatch,
      );
    }
    canvas.restore();

    final outline = Paint()
      ..color = look.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round;
    canvas
      ..drawRRect(body, outline)
      ..drawLine(
        Offset(p.left + 6, p.top + 16),
        Offset(p.right - 6, p.top + 16),
        Paint()
          ..color = look.line.withValues(alpha: 0.35)
          ..strokeWidth = 1.5,
      );

    // Çimen tutamları (platforma göre sabit konumlar).
    final grass = Paint()
      ..color = look.line.withValues(alpha: 0.8)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final seed = p.left.round();
    for (var i = 0; i < 2; i++) {
      final gx = p.left + 24 + ((seed * (i + 3)) % math.max(1, p.width - 48));
      for (final dx in [-5.0, 0.0, 5.0]) {
        canvas.drawLine(
          Offset(gx, p.top - 1),
          Offset(gx + dx * 1.4, p.top - 12 + dx.abs()),
          grass,
        );
      }
    }
  }

  void _paintSpike(Canvas canvas, Spike s) {
    final path = Path()
      ..moveTo(s.a.x, s.a.y)
      ..lineTo(s.apex.x, s.apex.y)
      ..lineTo(s.b.x, s.b.y)
      ..close();
    canvas
      ..drawPath(path, Paint()..color = look.line)
      ..drawLine(
        Offset(s.apex.x, s.apex.y + 4),
        Offset(s.left + s.width * 0.7, s.a.y - 2),
        Paint()
          ..color = look.ground.withValues(alpha: 0.6)
          ..strokeWidth = 2,
      );
  }

  void _paintCoins(Canvas canvas, double camX, double viewW) {
    final coin = sprites?.coin;
    final src = coin == null
        ? Rect.zero
        : Rect.fromLTWH(0, 0, coin.width.toDouble(), coin.height.toDouble());
    final paint = Paint()..filterQuality = FilterQuality.medium;
    for (final c in world.coins) {
      final pos = c.position;
      if (pos.x < camX - 40 || pos.x > camX + viewW + 40) continue;
      if (c.collected) {
        _paintPlusOne(canvas, c);
        continue;
      }
      final bob = math.sin(world.time * 3 + pos.x * 0.05) * 3;
      const r = Coin.radius;
      if (coin != null) {
        canvas.drawImageRect(
          coin,
          src,
          Rect.fromCircle(center: Offset(pos.x, pos.y + bob), radius: r),
          paint,
        );
      } else {
        canvas.drawCircle(
          Offset(pos.x, pos.y + bob),
          r,
          Paint()..color = ColorName.gold,
        );
      }
    }
  }

  void _paintPlusOne(Canvas canvas, Coin c) {
    final age = world.time - c.collectedAt;
    if (age > 0.7) return;
    final t = age / 0.7;
    final opacity = 1 - t;
    final pos = c.position;
    final tp = TextPainter(
      text: TextSpan(
        text: '+1',
        style: AppTextStyles.display(20).copyWith(
          color: ColorName.gold.withValues(alpha: opacity),
          shadows: [
            Shadow(
              color: ColorName.tomatoDark.withValues(alpha: opacity),
              offset: const Offset(1, 1),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.x - tp.width / 2, pos.y - 20 - 34 * t));
    // Kıvılcımlar.
    final spark = Paint()..color = ColorName.gold.withValues(alpha: opacity);
    for (var i = 0; i < 5; i++) {
      final a = i * math.pi * 2 / 5;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(
            pos.x + math.cos(a) * 26 * t,
            pos.y + math.sin(a) * 26 * t,
          ),
          width: 5,
          height: 5,
        ),
        spark,
      );
    }
  }

  void _paintInk(Canvas canvas) {
    final now = world.time;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = GameRules.inkThickness;
    final gloss = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;
    for (final stroke in world.strokes) {
      final pts = stroke.points;
      if (pts.length == 1) {
        final alpha = _inkAlpha(now - pts.first.bornAt);
        canvas.drawCircle(
          Offset(pts.first.position.x, pts.first.position.y),
          GameRules.inkThickness / 2,
          Paint()..color = look.ink.withValues(alpha: alpha),
        );
        continue;
      }
      for (var i = 1; i < pts.length; i++) {
        final alpha = _inkAlpha(now - pts[i - 1].bornAt);
        if (alpha <= 0) continue;
        final a = Offset(pts[i - 1].position.x, pts[i - 1].position.y);
        final b = Offset(pts[i].position.x, pts[i].position.y);
        if (look.dark) {
          canvas.drawLine(
            a,
            b,
            Paint()
              ..color = Colors.white.withValues(alpha: alpha * 0.5)
              ..strokeWidth = GameRules.inkThickness + 4
              ..strokeCap = StrokeCap.round,
          );
        }
        canvas
          ..drawLine(a, b, paint..color = look.ink.withValues(alpha: alpha))
          ..drawLine(
            a.translate(0, -2),
            b.translate(0, -2),
            gloss..color = Colors.white.withValues(alpha: alpha * 0.25),
          );
      }
    }
  }

  /// Son 0.3 saniyede solarak silinir.
  static double _inkAlpha(double age) {
    const life = GameRules.inkLifetime;
    if (age >= life) return 0;
    if (age < life - 0.3) return 1;
    return ((life - age) / 0.3).clamp(0.0, 1.0);
  }

  void _paintBall(Canvas canvas) {
    final p = world.ballPosition;
    final center = Offset(p.x, p.y);
    const r = GameRules.ballRadius;

    // Mürekkep izi (Figma: topun arkasında dağılan damlacıklar).
    if (!world.isOver) {
      _trail.insert(0, center);
      if (_trail.length > 14) _trail.removeLast();
    }
    final trail = Paint()..color = look.line;
    for (var i = 3; i < _trail.length; i++) {
      final t = i / _trail.length;
      trail.color = look.line.withValues(alpha: (1 - t) * 0.6);
      canvas.drawCircle(_trail[i].translate(-4, r * 0.55), 5 * (1 - t), trail);
    }

    // Ölüm: top şişip söner, etrafa mürekkep damlaları saçılır.
    var scale = 1.0;
    var alpha = 1.0;
    if (world.isOver) {
      final t = (world.deathElapsed / _deathSeconds).clamp(0.0, 1.0);
      scale = 1 + 0.35 * Curves.easeOut.transform(t);
      alpha = 1 - Curves.easeIn.transform(t);
      final drop = Paint()..color = look.ink.withValues(alpha: 1 - t * 0.7);
      for (var i = 0; i < 10; i++) {
        final a = i * math.pi * 2 / 10 + 0.3;
        final dist = r * (0.9 + 2.2 * Curves.easeOut.transform(t));
        canvas.drawCircle(
          center + Offset(math.cos(a), math.sin(a)) * dist,
          (i.isEven ? 5.5 : 3.5) * (1 - t * 0.6),
          drop,
        );
      }
    }

    final ball = sprites?.ball;
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(world.ballRotation)
      ..scale(scale);
    final paint = Paint()
      ..filterQuality = FilterQuality.medium
      ..color = Color.fromRGBO(0, 0, 0, alpha);
    if (ball != null) {
      canvas.drawImageRect(
        ball,
        Rect.fromLTWH(0, 0, ball.width.toDouble(), ball.height.toDouble()),
        Rect.fromCircle(center: Offset.zero, radius: r * 1.12),
        paint,
      );
    } else {
      canvas.drawCircle(
        Offset.zero,
        r,
        Paint()..color = ColorName.tomato.withValues(alpha: alpha),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) =>
      oldDelegate.world != world ||
      oldDelegate.sprites != sprites ||
      oldDelegate.look.ink != look.ink ||
      oldDelegate.look.dark != look.dark;
}
