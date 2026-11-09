part of '../splash_view.dart';

/// Harf harf beliren metin (Figma motion: karakter başına 166 ms gecikme,
/// opaklık 0→1, cubic-bezier(0, 0, .58, 1)).
class SplashTypewriter extends StatefulWidget {
  const SplashTypewriter({required this.text, super.key});

  final String text;

  @override
  State<SplashTypewriter> createState() => _SplashTypewriterState();
}

class _SplashTypewriterState extends State<SplashTypewriter>
    with SingleTickerProviderStateMixin {
  static const _step = Duration(milliseconds: 166);
  static const _curve = Cubic(0, 0, 0.58, 1);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _step * (widget.text.length + 1),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const style = AppTextStyles.splash;
    final chars = widget.text.characters.toList();
    final total = _controller.duration!.inMilliseconds;
    return Semantics(
      label: widget.text,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final ms = _controller.value * total;
            return Text.rich(
              TextSpan(
                children: [
                  for (var i = 0; i < chars.length; i++)
                    TextSpan(
                      text: chars[i],
                      style: style.copyWith(
                        color: ColorName.black.withValues(
                          alpha: _curve.transform(
                            ((ms - i * _step.inMilliseconds) /
                                    _step.inMilliseconds)
                                .clamp(0.0, 1.0),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
