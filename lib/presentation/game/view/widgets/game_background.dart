part of '../game_view.dart';

/// Tema zemini: kareli kağıt (renk tonuyla) veya gece.
class GameBackground extends StatelessWidget {
  const GameBackground({required this.themeId, super.key});

  final String themeId;

  @override
  Widget build(BuildContext context) {
    final paper = Assets.images.zemin.image(fit: BoxFit.cover);
    if (ItemAssets.isDarkTheme(themeId)) {
      return ColoredBox(
        color: ItemAssets.themeColor(themeId),
        child: const CustomPaint(painter: _NightGridPainter()),
      );
    }
    if (themeId == 'theme_kagit') return paper;
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        ItemAssets.themeColor(themeId),
        BlendMode.multiply,
      ),
      child: paper,
    );
  }
}

class _NightGridPainter extends CustomPainter {
  const _NightGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    const step = 22.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_NightGridPainter oldDelegate) => false;
}
