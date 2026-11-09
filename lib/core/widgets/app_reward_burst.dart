import 'dart:async';
import 'dart:math' as math;

import 'package:dashink/core/theme/app_spacing.dart';
import 'package:dashink/core/theme/app_text_styles.dart';
import 'package:dashink/core/widgets/app_decorations.dart';
import 'package:dashink/generated/assets.gen.dart';
import 'package:dashink/generated/colors.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Ödül kutlaması: [from] noktasından altınlar patlar, [to] (ör. üstteki
/// altın sayacı) noktasına uçar; üstte "+50" gibi bir etiket zıplar.
/// Snackbar yerine görev / başarım ödüllerinde kullanılır. Kendi kendini
/// overlay'den kaldırır; ekranı kilitlemez.
abstract final class AppRewardBurst {
  static void show(
    BuildContext context, {
    required Rect from,
    required String label,
    Rect? to,
    Widget? badge,
    int coins = 9,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    unawaited(HapticFeedback.mediumImpact());
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _RewardBurst(
        from: from,
        to: to,
        label: label,
        badge: badge,
        coins: coins,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  /// Bir widget'ın ekrandaki dikdörtgeni (yoksa null).
  static Rect? rectOf(BuildContext? context) {
    final box = context?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }
}

class _RewardBurst extends StatefulWidget {
  const _RewardBurst({
    required this.from,
    required this.label,
    required this.coins,
    required this.onDone,
    this.to,
    this.badge,
  });

  final Rect from;
  final Rect? to;
  final String label;
  final Widget? badge;
  final int coins;
  final VoidCallback onDone;

  @override
  State<_RewardBurst> createState() => _RewardBurstState();
}

class _RewardBurstState extends State<_RewardBurst>
    with SingleTickerProviderStateMixin {
  static const _coinSize = 26.0;
  late final AnimationController _c;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    );
    unawaited(_c.forward().whenComplete(widget.onDone));
    final rnd = math.Random();
    _particles = List.generate(widget.coins, (i) {
      final angle = (i / widget.coins) * 2 * math.pi + rnd.nextDouble() * 0.5;
      return _Particle(
        angle: angle,
        radius: 46 + rnd.nextDouble() * 34,
        delay: i * 0.025,
        spin: (rnd.nextDouble() - 0.5) * 2,
      );
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final origin = widget.from.center;
    final target = widget.to?.center;
    return IgnorePointer(
      // Overlay'de Material yok: metin varsayılan hata stiliyle çizilmesin.
      child: Material(
        type: MaterialType.transparency,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            return Stack(
              children: [
                for (final p in _particles) _coin(p, t, origin, target),
                _labelWidget(t, origin),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _coin(_Particle p, double t, Offset origin, Offset? target) {
    // 0–0.32: dışa patlama; 0.32–1: hedefe uçuş (yoksa yerinde sönme).
    final local = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
    final burst = Curves.easeOutBack.transform((local / 0.32).clamp(0.0, 1.0));
    final scattered =
        origin +
        Offset(math.cos(p.angle), math.sin(p.angle)) * p.radius * burst;
    var pos = scattered;
    var scale = 0.4 + 0.6 * burst;
    var opacity = 1.0;
    if (local > 0.32) {
      final fly = Curves.easeInCubic.transform((local - 0.32) / 0.68);
      if (target != null) {
        pos = Offset.lerp(scattered, target, fly)!;
        scale = 1 - 0.45 * fly;
      } else {
        opacity = 1 - fly;
      }
    }
    if (local >= 1) opacity = 0;
    return Positioned(
      left: pos.dx - _coinSize / 2,
      top: pos.dy - _coinSize / 2,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: p.spin * local * math.pi,
          child: Transform.scale(
            scale: scale,
            child: Assets.images.coin.image(
              width: _coinSize,
              height: _coinSize,
            ),
          ),
        ),
      ),
    );
  }

  Widget _labelWidget(double t, Offset origin) {
    final pop = Curves.elasticOut.transform((t / 0.45).clamp(0.0, 1.0));
    final fade = t < 0.7 ? 1.0 : 1 - (t - 0.7) / 0.3;
    final rise = 70 * Curves.easeOut.transform(t);
    return Positioned(
      left: 0,
      right: 0,
      top: origin.dy - 56 - rise,
      child: Opacity(
        opacity: fade.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 0.6 + 0.4 * pop,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: ColorName.mint,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: AppDecorations.border,
                boxShadow: const [
                  BoxShadow(color: ColorName.ink, offset: Offset(0, 3)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.badge case final badge?) ...[
                    SizedBox.square(dimension: 28, child: badge),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    widget.label,
                    style: AppTextStyles.display(22, height: 1.1).white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Particle {
  const _Particle({
    required this.angle,
    required this.radius,
    required this.delay,
    required this.spin,
  });

  final double angle;
  final double radius;
  final double delay;
  final double spin;
}
