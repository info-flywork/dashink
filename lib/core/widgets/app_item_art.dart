import 'dart:math' as math;

import 'package:dashink/core/utils/item_assets.dart';
import 'package:dashink/data/model/shop/shop_catalog.dart';
import 'package:dashink/generated/colors.gen.dart';
import 'package:flutter/material.dart';

/// Mağaza öğesinin görseli: top resmi, mürekkep karalaması veya tema
/// sayfası (dairesel).
class AppItemArt extends StatelessWidget {
  const AppItemArt({required this.item, required this.size, super.key});

  final ShopItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    return switch (item.category) {
      ShopCategory.ink => _Swatch(
        size: size,
        painter: _InkSwatchPainter(ItemAssets.inkColor(item.id, item)),
      ),
      ShopCategory.theme => _Swatch(
        size: size,
        painter: _ThemeSwatchPainter(
          ItemAssets.themeColor(item.id, item),
          dark: ItemAssets.isDarkTheme(item.id, item),
        ),
      ),
      _ => ClipOval(
        child: ItemAssets.ballImage(item.id).image(
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    };
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.size, required this.painter});

  final double size;
  final CustomPainter painter;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: painter);
}

class _InkSwatchPainter extends CustomPainter {
  _InkSwatchPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    canvas
      ..drawCircle(c, r, Paint()..color = ColorName.paper)
      ..drawCircle(
        c,
        r - 1.5,
        Paint()
          ..color = ColorName.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    final path = Path()..moveTo(size.width * 0.18, size.height * 0.62);
    for (var i = 1; i <= 20; i++) {
      final t = i / 20;
      path.lineTo(
        size.width * (0.18 + 0.64 * t),
        size.height * (0.55 - math.sin(t * math.pi * 1.6) * 0.16),
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = size.width * 0.11,
    );
  }

  @override
  bool shouldRepaint(_InkSwatchPainter old) => old.color != color;
}

class _ThemeSwatchPainter extends CustomPainter {
  _ThemeSwatchPainter(this.color, {required this.dark});

  final Color color;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    final clip = Path()..addOval(Rect.fromCircle(center: c, radius: r));
    canvas
      ..save()
      ..clipPath(clip)
      ..drawRect(Offset.zero & size, Paint()..color = color);
    final grid = Paint()
      ..color = (dark ? Colors.white : ColorName.ink).withValues(alpha: .14)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += size.width / 7) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 0.0; y < size.height; y += size.height / 7) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    canvas
      ..restore()
      ..drawCircle(
        c,
        r - 1.5,
        Paint()
          ..color = ColorName.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
  }

  @override
  bool shouldRepaint(_ThemeSwatchPainter old) =>
      old.color != color || old.dark != dark;
}
