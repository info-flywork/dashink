import 'package:dashink/core/theme/app_spacing.dart';
import 'package:dashink/core/theme/app_text_styles.dart';
import 'package:dashink/core/widgets/app_decorations.dart';
import 'package:dashink/generated/colors.gen.dart';
import 'package:flutter/material.dart';

/// Figma `Button` bileşeni.
enum AppButtonType {
  /// Domates zemin, beyaz Luckiest Guy 26, h64, koyu alt gölge.
  primary,

  /// Krem zemin, ink çizgi, Luckiest Guy 21, h56.
  secondary,

  /// Zeminsiz Baloo 16 metin, h44 ("Geç", "Vazgeç").
  ghost,
}

/// Basınca gölgesine doğru "çöken" buton.
class AppButton extends StatefulWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.icon,
    this.expand = true,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;

  /// 26px ikon (rengi çağıran verir).
  final Widget? icon;

  /// Genişliği doldur.
  final bool expand;
  final String? semanticLabel;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.type;
    final enabled = widget.onPressed != null;
    final shadowDepth = switch (type) {
      AppButtonType.primary => 5.0,
      AppButtonType.secondary => 4.0,
      AppButtonType.ghost => 0.0,
    };
    final dy = _pressed ? shadowDepth : 0.0;
    final height = switch (type) {
      AppButtonType.primary => 64.0,
      AppButtonType.secondary => 56.0,
      AppButtonType.ghost => 44.0,
    };
    final textStyle = switch (type) {
      AppButtonType.primary => AppTextStyles.buttonPrimary.white,
      AppButtonType.secondary => AppTextStyles.buttonSecondary.ink,
      AppButtonType.ghost => AppTextStyles.ghostButton.inkSoft,
    };
    final decoration = switch (type) {
      AppButtonType.primary => BoxDecoration(
        color: ColorName.tomato,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: [
          BoxShadow(
            color: ColorName.tomatoDark,
            offset: Offset(0, shadowDepth - dy),
          ),
        ],
      ),
      AppButtonType.secondary => BoxDecoration(
        color: ColorName.paperCard,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: AppDecorations.border,
        boxShadow: [
          BoxShadow(
            color: ColorName.inkShadow,
            offset: Offset(0, shadowDepth - dy),
          ),
        ],
      ),
      AppButtonType.ghost => const BoxDecoration(),
    };

    final content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          SizedBox.square(dimension: 26, child: widget.icon),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(widget.label, style: textStyle, maxLines: 1),
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: widget.onPressed,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: enabled ? 1 : 0.5,
          child: Padding(
            padding: EdgeInsets.only(bottom: shadowDepth),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              transform: Matrix4.translationValues(0, dy, 0),
              height: height,
              padding: EdgeInsets.symmetric(
                horizontal: type == AppButtonType.ghost ? 12 : 28,
              ),
              decoration: decoration,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

/// Figma `IconButton`: daire, krem zemin, ink çizgi (56 veya 50).
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
    this.size = 56,
    super.key,
  });

  final Widget icon;
  final VoidCallback? onTap;
  final String semanticLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        // Dokunma alanı en az 44px (Figma denetim notu).
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ColorName.paperCard,
            shape: BoxShape.circle,
            border: Border.all(color: ColorName.ink, width: AppStroke.regular),
            boxShadow: const [AppDecorations.shadow],
          ),
          child: SizedBox.square(dimension: 26, child: icon),
        ),
      ),
    );
  }
}
