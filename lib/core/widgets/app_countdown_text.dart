import 'dart:async';

import 'package:dashink/core/utils/extensions/number_extensions.dart';
import 'package:flutter/material.dart';

/// [endsAt]'e kalan süreyi saniyede bir `08:12:45` biçiminde gösterir;
/// süre dolunca [onElapsed] bir kez çağrılır.
class AppCountdownText extends StatefulWidget {
  const AppCountdownText({
    required this.endsAt,
    this.style,
    this.builder,
    this.onElapsed,
    super.key,
  });

  final DateTime endsAt;
  final TextStyle? style;

  /// Metni sarmak için ("Yenilenmesine {}").
  final String Function(String remaining)? builder;
  final VoidCallback? onElapsed;

  @override
  State<AppCountdownText> createState() => _AppCountdownTextState();
}

class _AppCountdownTextState extends State<AppCountdownText> {
  Timer? _timer;
  bool _fired = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (!mounted) return;
    setState(() {});
    if (!_fired && !widget.endsAt.isAfter(DateTime.now())) {
      _fired = true;
      widget.onElapsed?.call();
    }
  }

  @override
  void didUpdateWidget(AppCountdownText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endsAt != widget.endsAt) _fired = false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.endsAt.difference(DateTime.now()).hms;
    return Text(
      widget.builder?.call(remaining) ?? remaining,
      style: widget.style,
    );
  }
}
