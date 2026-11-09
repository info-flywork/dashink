import 'package:dashink/core/theme/app_spacing.dart';
import 'package:dashink/core/widgets/app_decorations.dart';
import 'package:dashink/generated/assets.gen.dart';
import 'package:dashink/generated/colors.gen.dart';
import 'package:flutter/material.dart';

/// Figma `InkMeter`: mürekkep damlası + dolum çubuğu.
class AppInkMeter extends StatelessWidget {
  const AppInkMeter({
    required this.value,
    this.color = ColorName.ink,
    this.label,
    super.key,
  });

  /// 0..1
  final double value;
  final Color color;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      value: '${(value * 100).round()}%',
      child: Row(
        children: [
          Assets.images.inkDrop.image(width: 35, height: 50),
          const SizedBox(width: 5),
          Expanded(
            child: Container(
              height: 33,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: ColorName.paperCard,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: AppDecorations.border,
                boxShadow: const [AppDecorations.shadow],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) => Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    width: constraints.maxWidth * value.clamp(0.0, 1.0),
                    height: 23,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
