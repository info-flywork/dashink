import 'dart:async';

import 'package:dashink/core/theme/app_spacing.dart';
import 'package:dashink/core/theme/app_text_styles.dart';
import 'package:dashink/core/utils/enum/snackbar_type.dart';
import 'package:dashink/core/widgets/app_tab_bar.dart';
import 'package:dashink/generated/colors.gen.dart';
import 'package:flutter/material.dart';

/// Tüm snackbar'ların tek giriş noktası (overlay tabanlı).
/// `ScaffoldMessenger` kullanılmaz.
final class AppSnackbar {
  AppSnackbar._();

  static OverlayEntry? _current;
  static Timer? _timer;

  static void show({
    required BuildContext context,
    required String text,
    required SnackBarType type,
    SnackBarPosition position = SnackBarPosition.bottom,
    Duration duration = const Duration(seconds: 2),
  }) {
    _dismiss();
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    // Sekmeli kabuktaki ekranlarda (en yakın Scaffold'un alt çubuğu var)
    // mesaj sekme çubuğunun hemen üstünde çıkar.
    final inShell =
        Scaffold.maybeOf(context)?.widget.bottomNavigationBar != null;
    final tabBarTop = inShell ? AppTabBar.topOnScreen() : null;

    final entry = OverlayEntry(
      builder: (context) => _SnackContent(
        text: text,
        type: type,
        position: position,
        tabBarTop: tabBarTop,
      ),
    );
    _current = entry;
    overlay.insert(entry);
    _timer = Timer(duration, _dismiss);
  }

  static void _dismiss() {
    _timer?.cancel();
    _timer = null;
    _current?.remove();
    _current = null;
  }
}

class _SnackContent extends StatelessWidget {
  const _SnackContent({
    required this.text,
    required this.type,
    required this.position,
    this.tabBarTop,
  });

  final String text;
  final SnackBarType type;
  final SnackBarPosition position;

  /// Sekme çubuğunun üst kenarı; varsa alt mesaj onun üstüne oturur.
  final double? tabBarTop;

  @override
  Widget build(BuildContext context) {
    final isTop = position == SnackBarPosition.top;
    final media = MediaQuery.of(context);
    final tabBarTop = this.tabBarTop;
    final bottom = tabBarTop != null
        ? media.size.height - tabBarTop + AppSpacing.s
        : media.padding.bottom + AppSpacing.m;
    return Positioned(
      left: AppSpacing.m,
      right: AppSpacing.m,
      top: isTop ? media.padding.top + AppSpacing.xs : null,
      bottom: isTop ? null : bottom,
      child: Material(
        color: type.color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.l),
          side: const BorderSide(
            color: ColorName.ink,
            width: AppStroke.regular,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              Icon(type.icon, color: ColorName.white),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  text,
                  style: AppTextStyles.rowLabel.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
