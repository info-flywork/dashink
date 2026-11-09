// Mağaza toplarının görsellerini Flutter canvas'ında çizer (mevcut topların
// parlak, yumuşak gölgeli dilinde; şeffaf zemin).
//   flutter test tool/ball_art/render_balls_test.dart
// Çıktı: assets/images/top_<ad>.png (368×368)
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

const double _size = 368;
const Offset _c = Offset(_size / 2, _size / 2);
const double _r = _size * 0.44;

/// Ortak top: taban gradyanı → desen (daireye kırpılı) → gölge → parlama.
class _BallPainter extends CustomPainter {
  const _BallPainter({required this.base, this.pattern});

  /// Açık, orta, koyu ton.
  final List<Color> base;
  final void Function(Canvas canvas)? pattern;

  @override
  void paint(Canvas canvas, Size size) {
    final circle = Rect.fromCircle(center: _c, radius: _r);
    canvas
      ..save()
      ..clipPath(Path()..addOval(circle))
      ..drawCircle(
        _c,
        _r,
        Paint()
          ..shader = ui.Gradient.radial(
            _c.translate(-_r * 0.35, -_r * 0.4),
            _r * 1.5,
            base,
            const [0, 0.55, 1],
          ),
      );
    pattern?.call(canvas);
    // Hacim: sağ alta doğru koyulaşan gölge.
    canvas
      ..drawCircle(
        _c,
        _r,
        Paint()
          ..shader = ui.Gradient.radial(
            _c.translate(-_r * 0.3, -_r * 0.35),
            _r * 1.45,
            [
              Colors.transparent,
              Colors.transparent,
              Colors.black.withValues(alpha: 0.32),
            ],
            const [0, 0.55, 1],
          ),
      )
      // Alt kenarda yansıyan ışık.
      ..drawArc(
        Rect.fromCircle(center: _c, radius: _r * 0.9),
        math.pi * 0.2,
        math.pi * 0.6,
        false,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = _r * 0.08
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      )
      ..restore()
      // Parlama.
      ..drawOval(
        Rect.fromCenter(
          center: _c.translate(-_r * 0.36, -_r * 0.46),
          width: _r * 0.62,
          height: _r * 0.36,
        ),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.7)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      )
      ..drawCircle(
        _c.translate(-_r * 0.5, -_r * 0.5),
        _r * 0.07,
        Paint()..color = Colors.white.withValues(alpha: 0.9),
      );
  }

  @override
  bool shouldRepaint(_BallPainter oldDelegate) => false;
}

Paint _stroke(Color color, double width) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round;

// --- Desenler ----------------------------------------------------------------

void _basket(Canvas canvas) {
  final seam = _stroke(const Color(0xFF4A220C), _r * 0.055);
  canvas
    ..drawLine(_c.translate(-_r, 0), _c.translate(_r, 0), seam)
    ..drawLine(_c.translate(0, -_r), _c.translate(0, _r), seam)
    ..drawArc(
      Rect.fromCircle(center: _c.translate(-_r * 1.25, 0), radius: _r * 0.95),
      -math.pi / 2,
      math.pi,
      false,
      seam,
    )
    ..drawArc(
      Rect.fromCircle(center: _c.translate(_r * 1.25, 0), radius: _r * 0.95),
      math.pi / 2,
      math.pi,
      false,
      seam,
    );
}

void _tenis(Canvas canvas) {
  final seam = _stroke(Colors.white.withValues(alpha: 0.95), _r * 0.09);
  canvas
    ..drawArc(
      Rect.fromCircle(
        center: _c.translate(-_r * 1.05, -_r * 0.2),
        radius: _r * 0.85,
      ),
      -math.pi * 0.45,
      math.pi * 0.9,
      false,
      seam,
    )
    ..drawArc(
      Rect.fromCircle(
        center: _c.translate(_r * 1.05, _r * 0.2),
        radius: _r * 0.85,
      ),
      math.pi * 0.55,
      math.pi * 0.9,
      false,
      seam,
    );
}

void _plaj(Canvas canvas) {
  const colors = [
    Color(0xFFF45D35),
    Color(0xFFFFFFFF),
    Color(0xFFF6B830),
    Color(0xFF3A7BE0),
    Color(0xFFFFFFFF),
    Color(0xFF2BBF98),
  ];
  final pole = _c.translate(-_r * 0.18, -_r * 0.22);
  const n = 6;
  for (var i = 0; i < n; i++) {
    final a0 = -math.pi / 2 + i * 2 * math.pi / n + 0.2;
    final a1 = a0 + 2 * math.pi / n;
    final path = Path()
      ..moveTo(pole.dx, pole.dy)
      ..lineTo(pole.dx + math.cos(a0) * _r * 3, pole.dy + math.sin(a0) * _r * 3)
      ..lineTo(pole.dx + math.cos(a1) * _r * 3, pole.dy + math.sin(a1) * _r * 3)
      ..close();
    canvas.drawPath(path, Paint()..color = colors[i]);
  }
  canvas.drawOval(
    Rect.fromCenter(center: pole, width: _r * 0.26, height: _r * 0.2),
    Paint()..color = Colors.white,
  );
}

void _bilardo(Canvas canvas) {
  final center = _c.translate(-_r * 0.06, -_r * 0.12);
  canvas.drawCircle(
    center,
    _r * 0.42,
    Paint()..color = const Color(0xFFFFFBF2),
  );
  // "8": test ortamında gerçek font yok; iki halkayla çizilir.
  final eight = _stroke(const Color(0xFF16161C), _r * 0.07);
  canvas
    ..drawOval(
      Rect.fromCenter(
        center: center.translate(0, -_r * 0.11),
        width: _r * 0.2,
        height: _r * 0.18,
      ),
      eight,
    )
    ..drawOval(
      Rect.fromCenter(
        center: center.translate(0, _r * 0.1),
        width: _r * 0.25,
        height: _r * 0.22,
      ),
      eight,
    );
}

void _ay(Canvas canvas) {
  const craters = [
    (0.35, -0.25, 0.22),
    (-0.3, 0.3, 0.16),
    (0.15, 0.45, 0.12),
    (-0.45, -0.1, 0.1),
    (0.55, 0.2, 0.09),
    (-0.05, -0.55, 0.08),
  ];
  for (final (x, y, s) in craters) {
    final p = _c.translate(_r * x, _r * y);
    canvas
      ..drawCircle(p, _r * s, Paint()..color = const Color(0xFF8E909E))
      ..drawCircle(
        p.translate(_r * s * 0.15, _r * s * 0.15),
        _r * s * 0.8,
        Paint()..color = const Color(0xFFA7A9B5),
      )
      ..drawArc(
        Rect.fromCircle(center: p, radius: _r * s),
        math.pi * 0.1,
        math.pi * 0.8,
        false,
        _stroke(Colors.white.withValues(alpha: 0.35), _r * 0.02),
      );
  }
}

void _lav(Canvas canvas) {
  canvas.drawCircle(
    _c.translate(_r * 0.1, _r * 0.15),
    _r * 0.9,
    Paint()
      ..shader = ui.Gradient.radial(
        _c.translate(_r * 0.1, _r * 0.15),
        _r * 0.9,
        [
          const Color(0xFFFF7A1A).withValues(alpha: 0.55),
          Colors.transparent,
        ],
      ),
  );
  final rnd = math.Random(7);
  for (var k = 0; k < 7; k++) {
    final path = Path();
    var p = _c.translate(
      (rnd.nextDouble() - 0.5) * _r * 1.6,
      (rnd.nextDouble() - 0.5) * _r * 1.6,
    );
    path.moveTo(p.dx, p.dy);
    for (var i = 0; i < 4; i++) {
      p = p.translate(
        (rnd.nextDouble() - 0.5) * _r * 0.7,
        (rnd.nextDouble() - 0.5) * _r * 0.7,
      );
      path.lineTo(p.dx, p.dy);
    }
    canvas
      ..drawPath(
        path,
        _stroke(const Color(0xFFFF6A00), _r * 0.09)
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      )
      ..drawPath(
        path,
        _stroke(const Color(0xFFFFD34D), _r * 0.035)
          ..strokeJoin = StrokeJoin.round,
      );
  }
}

void _buz(Canvas canvas) {
  final facet = Paint()..color = Colors.white.withValues(alpha: 0.22);
  final edge = _stroke(Colors.white.withValues(alpha: 0.55), _r * 0.015);
  const points = [
    [(-0.9, -0.2), (-0.2, -0.75), (0.1, -0.1)],
    [(0.1, -0.1), (-0.2, -0.75), (0.6, -0.6)],
    [(0.1, -0.1), (0.6, -0.6), (0.95, 0.15)],
    [(-0.9, -0.2), (0.1, -0.1), (-0.5, 0.65)],
    [(0.1, -0.1), (0.95, 0.15), (0.3, 0.85)],
    [(-0.5, 0.65), (0.1, -0.1), (0.3, 0.85)],
  ];
  for (var i = 0; i < points.length; i++) {
    final tri = points[i];
    final path = Path()
      ..moveTo(_c.dx + _r * tri[0].$1, _c.dy + _r * tri[0].$2)
      ..lineTo(_c.dx + _r * tri[1].$1, _c.dy + _r * tri[1].$2)
      ..lineTo(_c.dx + _r * tri[2].$1, _c.dy + _r * tri[2].$2)
      ..close();
    if (i.isEven) canvas.drawPath(path, facet);
    canvas.drawPath(path, edge);
  }
  final sparkle = Paint()..color = Colors.white;
  for (final (x, y, s) in [(0.45, -0.35, 0.07), (-0.35, 0.4, 0.05)]) {
    final p = _c.translate(_r * x, _r * y);
    final d = _r * s;
    canvas.drawPath(
      Path()
        ..moveTo(p.dx, p.dy - d * 2)
        ..quadraticBezierTo(p.dx, p.dy, p.dx + d * 2, p.dy)
        ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy + d * 2)
        ..quadraticBezierTo(p.dx, p.dy, p.dx - d * 2, p.dy)
        ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy - d * 2),
      sparkle,
    );
  }
}

void _gokkusagi(Canvas canvas) {
  const bands = [
    Color(0xFFF2453D),
    Color(0xFFFF8A1F),
    Color(0xFFF6CF30),
    Color(0xFF3CC46B),
    Color(0xFF2F8BEB),
    Color(0xFF7B4FD6),
  ];
  final h = _r * 2 / bands.length;
  for (var i = 0; i < bands.length; i++) {
    canvas.drawRect(
      Rect.fromLTWH(_c.dx - _r, _c.dy - _r + i * h, _r * 2, h + 1),
      Paint()..color = bands[i],
    );
  }
}

// --- Toplar ------------------------------------------------------------------

final Map<String, _BallPainter> _balls = {
  'top_basket': const _BallPainter(
    base: [Color(0xFFFFB066), Color(0xFFF07A22), Color(0xFFB4500F)],
    pattern: _basket,
  ),
  'top_tenis': const _BallPainter(
    base: [Color(0xFFF4FF8A), Color(0xFFCFE33A), Color(0xFF8FA417)],
    pattern: _tenis,
  ),
  'top_plaj': const _BallPainter(
    base: [Color(0xFFFFFFFF), Color(0xFFF2F2F2), Color(0xFFCCCCCC)],
    pattern: _plaj,
  ),
  'top_bilardo': const _BallPainter(
    base: [Color(0xFF5A5A66), Color(0xFF1E1E26), Color(0xFF050507)],
    pattern: _bilardo,
  ),
  'top_ay': const _BallPainter(
    base: [Color(0xFFF2F2F6), Color(0xFFC4C5CF), Color(0xFF7E8090)],
    pattern: _ay,
  ),
  'top_lav': const _BallPainter(
    base: [Color(0xFF7A2A14), Color(0xFF3A120A), Color(0xFF1A0704)],
    pattern: _lav,
  ),
  'top_buz': const _BallPainter(
    base: [Color(0xFFF2FBFF), Color(0xFFA8E0F4), Color(0xFF4FA6CF)],
    pattern: _buz,
  ),
  'top_gokkusagi': const _BallPainter(
    base: [Color(0xFFFFFFFF), Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
    pattern: _gokkusagi,
  ),
};

void main() {
  for (final MapEntry(key: name, value: painter) in _balls.entries) {
    testWidgets('render $name', (tester) async {
      tester.view
        ..devicePixelRatio = 1
        ..physicalSize = const Size(_size, _size);
      addTearDown(tester.view.reset);
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: CustomPaint(size: const Size(_size, _size), painter: painter),
        ),
      );
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File('assets/images/$name.png').writeAsBytesSync(
          bytes!.buffer.asUint8List(),
        );
      });
    });
  }
}
