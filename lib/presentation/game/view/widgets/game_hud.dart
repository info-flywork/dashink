part of '../game_view.dart';

/// Figma `HUD` + `InkMeterWrap`: duraklat, skor, altın; altta mürekkep.
class GameHud extends StatelessWidget {
  const GameHud({
    required this.frame,
    required this.world,
    required this.inkColor,
    required this.daily,
    required this.showHint,
    required this.onPauseTapped,
    this.dark = false,
    super.key,
  });

  /// Koyu temada skor açık renkte yazılır (lacivert zeminde okunsun).
  final bool dark;

  /// Her karede artar.
  final ValueListenable<int> frame;

  /// Güncel dünya (yeniden başlatmada değişir).
  final GameWorld Function() world;
  final Color inkColor;
  final bool daily;
  final bool Function() showHint;
  final VoidCallback onPauseTapped;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder<int>(
        valueListenable: frame,
        builder: (context, _, _) {
          final w = world();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 15, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppIconButton(
                      size: 50,
                      icon: AppSvgIcon(Assets.icons.pause, size: 26),
                      semanticLabel: LocaleKeys.game_pause.tr(),
                      onTap: onPauseTapped,
                    ),
                    Expanded(
                      child: IgnorePointer(
                        child: Column(
                          children: [
                            Text(
                              '${w.score}',
                              style: AppTextStyles.hudScore.copyWith(
                                color: dark
                                    ? const Color(0xFFE8E4F5)
                                    : ColorName.ink,
                              ),
                            ),
                            if (daily) const _DailyBadge(),
                          ],
                        ),
                      ),
                    ),
                    IgnorePointer(
                      child: AppCoinPill(label: '${w.coinsCollected}'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: showHint() ? 1 : 0,
                    child: Align(
                      alignment: const Alignment(0, -0.35),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: AppDecorations.card(radius: AppRadius.xl),
                        child: Text(
                          LocaleKeys.game_draw_hint.tr(),
                          style: AppTextStyles.buttonSecondary.ink,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 15, 12),
                  child: AppInkMeter(
                    value: w.ink,
                    color: inkColor,
                    label: LocaleKeys.game_ink_label.tr(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DailyBadge extends StatelessWidget {
  const _DailyBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: ColorName.tomato,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        LocaleKeys.game_daily_badge.tr(),
        style: AppTextStyles.badge.white,
      ),
    );
  }
}
