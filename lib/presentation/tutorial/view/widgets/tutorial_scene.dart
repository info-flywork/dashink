part of '../tutorial_view.dart';

/// Figma `egitim` sahnesi: 430×930 tasarım çerçevesinde öğeler birebir
/// konumlanır ve ekranı kaplayacak şekilde ölçeklenir. Adıma göre vurgu
/// değişir: 1) el çizgiyi çizer, 2) altın parlar, 3) mürekkep çubuğu.
class TutorialScene extends StatefulWidget {
  const TutorialScene({required this.step, super.key});

  final int step;

  @override
  State<TutorialScene> createState() => _TutorialSceneState();
}

class _TutorialSceneState extends State<TutorialScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.idleEnabled(context)) {
      unawaited(_loop.repeat());
    } else {
      _loop.value = 1;
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    return FittedBox(
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: 430,
        height: 930,
        child: AnimatedBuilder(
          animation: _loop,
          builder: (context, _) {
            final t = _loop.value;
            // Çizim ilerlemesi: ilk %60'ta çizilir, sonra 1 sn'de silinir.
            final drawn = step == 0 ? (t / 0.6).clamp(0.0, 1.0) : 1.0;
            final fade = step == 0 && t > 0.75 ? 1 - (t - 0.75) / 0.25 : 1.0;
            final coinPulse = step == 1
                ? 1 + 0.18 * (0.5 - (t - 0.5).abs()) * 2
                : 1.0;
            return Stack(
              children: [
                Positioned.fill(
                  child: Assets.images.egitimSahne.image(fit: BoxFit.cover),
                ),
                _place(12, 50, 120, 62, Assets.images.eCloud),
                _place(282, 44, 70, 72, Assets.images.eSun),
                _place(0, 524, 154, 97, Assets.images.ePlatL),
                _place(305, 524, 125, 93, Assets.images.ePlatR),
                _place(0, 630, 430, 34, Assets.images.eHills),
                _place(48, 481, 103, 43, Assets.images.eBall),
                Positioned(
                  left: 146,
                  top: 466,
                  width: 141,
                  height: 55,
                  child: Opacity(
                    opacity: fade.clamp(0.0, 1.0),
                    child: ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: drawn,
                        child: Assets.images.eArc.image(
                          width: 141,
                          height: 55,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                if (step == 0)
                  Positioned(
                    left: 146 + 136 * drawn,
                    top: 466 + 20 * (1 - drawn),
                    width: 50,
                    height: 72,
                    child: Assets.images.eHand.image(fit: BoxFit.contain),
                  ),
                Positioned(
                  left: 368,
                  top: 506,
                  width: 21,
                  height: 36,
                  child: Transform.scale(
                    scale: coinPulse,
                    child: Assets.images.eCoin.image(fit: BoxFit.contain),
                  ),
                ),
                if (step == 2)
                  Positioned(
                    left: 40,
                    right: 40,
                    top: 700,
                    child: AppInkMeter(
                      value: 1 - (t < 0.5 ? t : 1 - t),
                      label: LocaleKeys.game_ink_label.tr(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _place(
    double left,
    double top,
    double width,
    double height,
    AssetGenImage image,
  ) => Positioned(
    left: left,
    top: top,
    width: width,
    height: height,
    child: image.image(fit: BoxFit.contain),
  );
}
