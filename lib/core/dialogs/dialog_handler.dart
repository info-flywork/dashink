import 'package:dashink/generated/colors.gen.dart';
import 'package:flutter/material.dart';

abstract class DialogHandler {
  Future<T?> showNormalDialog<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: ColorName.ink.withValues(alpha: .35),
      builder: (context) => child,
    );
  }

  /// Kartsız, tam ekran overlay dialog: [child] tüm ekranı kaplar, arkada
  /// [barrierColor] (varsayılan `scrimPaper`, Figma: %55 kağıt). Fade +
  /// hafif scale ile açılır.
  Future<T?> showFullScreenDialog<T>({
    required BuildContext context,
    required Widget child,
    Color? barrierColor,
    bool barrierDismissible = false,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: barrierColor ?? ColorName.scrimPaper,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, _, _) => child,
      transitionBuilder: (_, animation, _, page) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
            child: page,
          ),
        );
      },
    );
  }
}
