import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Uygulama genelindeki hareket ayarları.
abstract final class AppMotion {
  /// Sonsuz döngülü süs animasyonları (süzülme, nabız, arka plan nefesi).
  /// Testlerde kapalıdır (`pumpAndSettle` bitebilsin, golden'lar sabit
  /// kalsın); erişilebilirlikte "hareketi azalt" açıksa da çalışmaz.
  static bool idleEnabled(BuildContext context) =>
      !_isTest && !MediaQuery.disableAnimationsOf(context);

  static final bool _isTest = Platform.environment.containsKey('FLUTTER_TEST');

  static const Duration entrance = Duration(milliseconds: 460);
  static const Duration stagger = Duration(milliseconds: 70);
}

/// Ekran açılırken içeriğin belirmesi: saydamlık + kayma (+ istersen ölçek).
/// [delay] ile sıralı (stagger) girişler yapılır. Tek bir controller ve
/// Interval eğrisi kullanır; zamanlayıcı yoktur.
class AppEntrance extends StatefulWidget {
  const AppEntrance({
    required this.child,
    this.delay = Duration.zero,
    this.index = 0,
    this.duration = AppMotion.entrance,
    this.offset = const Offset(0, 24),
    this.scaleFrom = 1,
    this.curve = Curves.easeOutCubic,
    super.key,
  });

  final Widget child;

  /// Başlangıç gecikmesi; [index] > 0 ise üstüne `index × stagger` eklenir
  /// (listelerde sıralı giriş).
  final Duration delay;
  final int index;
  final Duration duration;

  /// Başlangıç kayması (piksel); `Offset(0, 24)` aşağıdan yukarı.
  final Offset offset;

  /// Başlangıç ölçeği (1 = ölçeksiz).
  final double scaleFrom;
  final Curve curve;

  Duration get totalDelay => delay + AppMotion.stagger * index;

  @override
  State<AppEntrance> createState() => _AppEntranceState();
}

class _AppEntranceState extends State<AppEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.totalDelay + widget.duration,
  );

  late final Animation<double> _t = CurvedAnimation(
    parent: _controller,
    curve: Interval(
      widget.totalDelay.inMicroseconds /
          (widget.totalDelay + widget.duration).inMicroseconds,
      1,
      curve: widget.curve,
    ),
  );

  /// Animasyon bitince sarmalayıcılar kalkar; içerik state'ini kaybetmesin
  /// diye aynı GlobalKey ile taşınır.
  final GlobalKey _childKey = GlobalKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isAnimating || _controller.isCompleted) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward().ignore();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      child: KeyedSubtree(key: _childKey, child: widget.child),
      builder: (context, child) {
        final t = _t.value;
        // Bitince sarmalayıcı katman kalmasın (piksel birebir aynı çizim).
        if (t >= 1) return child!;
        final scale = widget.scaleFrom + (1 - widget.scaleFrom) * t;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: widget.offset * (1 - t),
            child: scale == 1
                ? child
                : Transform.scale(scale: scale, child: child),
          ),
        );
      },
    );
  }
}

/// Hafif süzülme: [child] yavaşça yukarı-aşağı salınır (logo vb.).
class AppFloat extends StatefulWidget {
  const AppFloat({
    required this.child,
    this.amplitude = 6,
    this.period = const Duration(milliseconds: 3200),
    super.key,
  });

  final Widget child;
  final double amplitude;
  final Duration period;

  @override
  State<AppFloat> createState() => _AppFloatState();
}

class _AppFloatState extends State<AppFloat>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.idleEnabled(context)) {
      if (!_controller.isAnimating) _controller.repeat().ignore();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) => Transform.translate(
        offset: Offset(
          0,
          math.sin(_controller.value * 2 * math.pi) * widget.amplitude,
        ),
        child: child,
      ),
    );
  }
}

/// "Nefes alan" vurgu: [child] hafifçe büyüyüp küçülür (ana buton).
class AppPulse extends StatefulWidget {
  const AppPulse({
    required this.child,
    this.enabled = true,
    this.scale = 1.035,
    this.period = const Duration(milliseconds: 1600),
    super.key,
  });

  final Widget child;
  final bool enabled;
  final double scale;
  final Duration period;

  @override
  State<AppPulse> createState() => _AppPulseState();
}

class _AppPulseState extends State<AppPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  void _sync() {
    if (widget.enabled && AppMotion.idleEnabled(context)) {
      if (!_controller.isAnimating) _controller.repeat().ignore();
    } else {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant AppPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) _sync();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final wave = (1 - math.cos(_controller.value * 2 * math.pi)) / 2;
        return Transform.scale(
          scale: 1 + (widget.scale - 1) * wave,
          child: child,
        );
      },
    );
  }
}

/// Arka plan "nefesi": görsel çok yavaş yakınlaşıp uzaklaşır (Ken Burns).
class AppBackdropDrift extends StatefulWidget {
  const AppBackdropDrift({
    required this.child,
    this.zoom = 1.04,
    this.period = const Duration(seconds: 14),
    this.introZoom = 1.08,
    super.key,
  });

  final Widget child;
  final double zoom;
  final Duration period;

  /// Açılışta bu ölçekten 1'e yumuşakça iner (ilk ~1.4 sn).
  final double introZoom;

  @override
  State<AppBackdropDrift> createState() => _AppBackdropDriftState();
}

class _AppBackdropDriftState extends State<AppBackdropDrift>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: widget.period,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final idle = AppMotion.idleEnabled(context);
    if (!idle) {
      _intro.value = 1;
      _drift.stop();
      return;
    }
    if (!_intro.isAnimating && !_intro.isCompleted) _intro.forward().ignore();
    if (!_drift.isAnimating) _drift.repeat(reverse: true).ignore();
  }

  @override
  void dispose() {
    _intro.dispose();
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_intro, _drift]),
      child: widget.child,
      builder: (context, child) {
        final intro = Curves.easeOutCubic.transform(_intro.value);
        final drift = Curves.easeInOut.transform(_drift.value);
        final scale =
            widget.introZoom +
            (1 - widget.introZoom) * intro +
            (widget.zoom - 1) * drift;
        return Transform.scale(scale: scale, child: child);
      },
    );
  }
}

/// Sayı değişince eskisinden yenisine sayarak geçer (coin bakiyesi).
class AppAnimatedCount extends StatelessWidget {
  const AppAnimatedCount({
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 700),
    this.format,
    super.key,
  });

  final int value;
  final TextStyle? style;
  final Duration duration;

  /// Gösterim biçimi (binlik ayırıcı vb.); yoksa düz sayı.
  final String Function(int value)? format;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) =>
          Text(format?.call(v.round()) ?? '${v.round()}', style: style),
    );
  }
}
