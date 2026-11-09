import 'package:dashink/core/theme/app_spacing.dart';
import 'package:dashink/core/theme/app_text_styles.dart';
import 'package:dashink/core/widgets/app_decorations.dart';
import 'package:dashink/generated/colors.gen.dart';
import 'package:flutter/material.dart';

/// Figma `Segmented`: üç seçenekli hap; seçili olan domates zemin.
class AppSegmented extends StatelessWidget {
  const AppSegmented({
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ColorName.paperCard,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: AppDecorations.border,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = 4.0;
          final count = labels.length;
          final width = (constraints.maxWidth - gap * (count - 1)) / count;
          return Stack(
            children: [
              AnimatedPositionedDirectional(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                start: selectedIndex * (width + gap),
                top: 0,
                bottom: 0,
                width: width,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: ColorName.tomato,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < count; i++) ...[
                    if (i > 0) const SizedBox(width: gap),
                    Expanded(
                      child: Semantics(
                        button: true,
                        selected: i == selectedIndex,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onChanged(i),
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 180),
                              style: i == selectedIndex
                                  ? AppTextStyles.segment.white
                                  : AppTextStyles.segment.ink,
                              child: Text(labels[i], maxLines: 1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
