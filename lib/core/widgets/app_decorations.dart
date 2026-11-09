import 'package:dashink/core/theme/app_spacing.dart';
import 'package:dashink/generated/assets.gen.dart';
import 'package:dashink/generated/colors.gen.dart';
import 'package:flutter/material.dart';

/// Figma'daki "kağıt kart" dili: krem zemin, 2.5px lacivert çizgi, altta
/// sert gölge (0, 4, ink %18).
abstract final class AppDecorations {
  static const BoxShadow shadow = BoxShadow(
    color: ColorName.inkShadow,
    offset: Offset(0, 4),
  );

  static const BoxShadow shadowSmall = BoxShadow(
    color: ColorName.inkShadow,
    offset: Offset(0, 3),
  );

  static const Border border = Border.fromBorderSide(
    BorderSide(color: ColorName.ink, width: AppStroke.regular),
  );

  static BoxDecoration card({
    double radius = AppRadius.l,
    Color color = ColorName.paperCard,
    Color borderColor = ColorName.ink,
    double borderWidth = AppStroke.regular,
    bool shadowed = true,
    BoxShadow shadowStyle = shadow,
  }) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: borderColor, width: borderWidth),
    boxShadow: shadowed ? [shadowStyle] : null,
  );
}

/// Lucide SVG ikonu; [color] verilirse tek renge boyanır.
class AppSvgIcon extends StatelessWidget {
  const AppSvgIcon(this.icon, {this.size = 24, this.color, super.key});

  final SvgGenImage icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => icon.svg(
    width: size,
    height: size,
    colorFilter: color == null
        ? null
        : ColorFilter.mode(color!, BlendMode.srcIn),
  );
}

/// Kareli kağıt zemin (Figma `img/zemin`). Ekranı kaplar.
class AppPaperBackground extends StatelessWidget {
  const AppPaperBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Assets.images.zemin.image(fit: BoxFit.cover),
        child,
      ],
    );
  }
}

/// Kağıt kartı: krem zemin + ink çizgi + gölge.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.m),
    this.radius = AppRadius.l,
    this.color = ColorName.paperCard,
    this.borderColor = ColorName.ink,
    this.shadowed = true,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final Color borderColor;
  final bool shadowed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: AppDecorations.card(
        radius: radius,
        color: color,
        borderColor: borderColor,
        shadowed: shadowed,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// İlerleme çubuğu (görevler, altın yetersiz).
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    required this.value,
    required this.color,
    this.height = 10,
    this.trackColor = ColorName.paperLine,
    this.bordered = false,
    super.key,
  });

  final double value;
  final Color color;
  final double height;
  final Color trackColor;

  /// Figma "altin-yetersiz": çerçeveli, 3px iç boşluklu çubuk.
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    final fill = LayoutBuilder(
      builder: (context, constraints) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          width: constraints.maxWidth * clamped,
          height: double.infinity,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
      ),
    );
    return Container(
      height: height,
      padding: bordered ? const EdgeInsets.all(3) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: bordered
            ? Border.all(color: ColorName.ink, width: AppStroke.regular)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: fill,
    );
  }
}
