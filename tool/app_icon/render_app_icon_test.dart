// Uygulama ikonunu üretir (oyunun kağıt + mürekkep diliyle, Flutter canvas'ında).
//   flutter test tool/app_icon/render_app_icon_test.dart
//   dart run flutter_launcher_icons
// Çıktı: asset_sources/app_icon/{app_icon,android_foreground,android_background}.png
//
// Sahne: kareli krem kağıt; soldan dağılan mürekkep damlacıklarıyla yükselen
// kalın lacivert mürekkep dalgası ve üstünde parlak domates top (ana ekran
// hero görseli ile aynı motif).
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

const double _size = 1024;
const Color _paper = Color(0xFFF7F0E1);
const Color _paperDeep = Color(0xFFEFE4CC);
const Color _grid = Color(0xFFE2D6BC);
const Color _ink = Color(0xFF1D2550);
const Color _inkSoft = Color(0xFF5A6082);
const Color _tomato = Color(0xFFF45D35);
const Color _tomatoLight = Color(0xFFFF8A5C);
const Color _tomatoDark = Color(0xFFC4401C);

enum _Layer { full, foreground, background }

/// Dalga eğrisi: 0..1 aralığında x için y (ikon koordinatı).
Offset _wave(double t) {
  final x = -60 + t * (_size + 120);
  final y = _size * 0.70 - math.sin((t - 0.08) * math.pi * 1.25) * _size * 0.13;
  return Offset(x, y);
}

class _IconPainter extends CustomPainter {
  const _IconPainter(this.layer);

  final _Layer layer;

  @override
  void paint(Canvas canvas, Size size) {
    if (layer != _Layer.foreground) _paintPaper(canvas, size);
    if (layer == _Layer.background) return;
    if (layer == _Layer.foreground) {
      // Android adaptive ön plan: içerik güvenli alana (orta %66) sığsın.
      canvas
        ..translate(size.width / 2, size.height / 2)
        ..scale(0.72)
        ..translate(-size.width / 2, -size.height / 2);
    }
    _paintDroplets(canvas);
    _paintWave(canvas);
    _paintBall(canvas);
    _paintSpeedLines(canvas);
  }

  void _paintPaper(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(size.width * 0.5, size.height * 0.42),
          size.width * 0.75,
          const [_paper, _paperDeep],
        ),
    );
    final grid = Paint()
      ..color = _grid
      ..strokeWidth = 3;
    const step = _size / 12;
    for (var x = step; x < _size; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, _size), grid);
    }
    for (var y = step; y < _size; y += step) {
      canvas.drawLine(Offset(0, y), Offset(_size, y), grid);
    }
  }

  void _paintWave(Canvas canvas) {
    final path = Path();
    for (var i = 0; i <= 80; i++) {
      final p = _wave(i / 80);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas
      // Kağıda düşen hafif gölge.
      ..drawPath(
        path.shift(const Offset(0, 22)),
        Paint()
          ..color = _ink.withValues(alpha: 0.16)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 92
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      )
      ..drawPath(
        path,
        Paint()
          ..color = _ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 88
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      )
      // Islak mürekkep parlaklığı.
      ..drawPath(
        path.shift(const Offset(0, -20)),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round,
      );
  }

  void _paintDroplets(Canvas canvas) {
    // Topun arkasında, dalganın üstünde sola doğru dağılan damlacıklar.
    final random = math.Random(11);
    final paint = Paint();
    for (var i = 0; i < 60; i++) {
      final t = random.nextDouble(); // 1 = topa yakın
      final x = 30 + t * 270;
      final waveY = _wave((x + 60) / (_size + 120)).dy;
      final spread = (1 - t) * 150 + 20;
      final y = waveY - 62 - random.nextDouble() * spread;
      final r = 5 + t * t * 26 * (0.5 + random.nextDouble() * 0.5);
      paint.color = (t < 0.4 ? _inkSoft : _ink).withValues(
        alpha: 0.3 + t * 0.7,
      );
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  void _paintBall(Canvas canvas) {
    const r = _size * 0.205;
    final c = Offset(_size * 0.47, _wave(0.47).dy - 44 - r);
    canvas
      ..drawOval(
        Rect.fromCenter(
          center: Offset(c.dx, c.dy + r + 26),
          width: r * 1.6,
          height: 40,
        ),
        Paint()
          ..color = _ink.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      )
      ..drawCircle(
        c,
        r,
        Paint()
          ..shader = ui.Gradient.radial(
            c.translate(-r * 0.35, -r * 0.4),
            r * 1.45,
            const [_tomatoLight, _tomato, _tomatoDark],
            const [0, 0.55, 1],
          ),
      )
      // Alt kenarda koyu yansıma.
      ..drawArc(
        Rect.fromCircle(center: c, radius: r - 10),
        math.pi * 0.15,
        math.pi * 0.7,
        false,
        Paint()
          ..color = _tomatoDark.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round,
      )
      // Parlama.
      ..drawOval(
        Rect.fromCenter(
          center: c.translate(-r * 0.38, -r * 0.45),
          width: r * 0.62,
          height: r * 0.38,
        ),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.85)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      )
      ..drawCircle(
        c.translate(r * 0.08, -r * 0.62),
        r * 0.07,
        Paint()..color = Colors.white.withValues(alpha: 0.9),
      );
  }

  void _paintSpeedLines(Canvas canvas) {
    final paint = Paint()
      ..color = _ink
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    const r = _size * 0.205;
    final c = Offset(_size * 0.47, _wave(0.47).dy - 44 - r);
    for (final (dy, len) in [(-0.55, 110.0), (-0.25, 150.0)]) {
      final start = c.translate(-r - 50, r * dy);
      canvas.drawLine(start, start.translate(-len, len * 0.12), paint);
    }
  }

  @override
  bool shouldRepaint(_IconPainter oldDelegate) => false;
}

void main() {
  for (final (layer, file) in [
    (_Layer.full, 'app_icon.png'),
    (_Layer.foreground, 'android_foreground.png'),
    (_Layer.background, 'android_background.png'),
  ]) {
    testWidgets('render $file', (tester) async {
      tester.view
        ..devicePixelRatio = 1
        ..physicalSize = const Size(_size, _size);
      addTearDown(tester.view.reset);
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: CustomPaint(
            size: const Size(_size, _size),
            painter: _IconPainter(layer),
          ),
        ),
      );
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        Directory('asset_sources/app_icon').createSync(recursive: true);
        File(
          'asset_sources/app_icon/$file',
        ).writeAsBytesSync(bytes!.buffer.asUint8List());
      });
    });
  }
}
