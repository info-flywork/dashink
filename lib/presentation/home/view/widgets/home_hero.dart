part of '../home_view.dart';

/// Logo, en iyi skor, hero görseli ve "OYNAMAK İÇİN DOKUN". Alanın tamamı
/// oyunu başlatır.
class HomeHero extends StatelessWidget {
  const HomeHero({
    required this.bestScore,
    required this.onPlayTapped,
    super.key,
  });

  final int bestScore;
  final VoidCallback onPlayTapped;

  @override
  Widget build(BuildContext context) {
    final best = bestScore > 0 ? bestScore.grouped(context) : '—';
    return Semantics(
      button: true,
      label: LocaleKeys.home_tap_to_play.tr(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPlayTapped,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'DASHINK',
                      style: AppTextStyles.logo.ink.copyWith(letterSpacing: 1),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppSvgIcon(Assets.icons.crown),
                      const SizedBox(width: 6),
                      Text(
                        LocaleKeys.home_best.tr(args: [best]),
                        style: AppTextStyles.bestLabel.ink,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250),
                child: AppFloat(
                  amplitude: 4,
                  child: Assets.images.anaHero.image(
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                LocaleKeys.home_tap_to_play.tr(),
                style: AppTextStyles.tapToPlay.ink,
              ),
            ),
            const SizedBox(height: 6),
            AppPulse(child: AppSvgIcon(Assets.icons.hand, size: 44)),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
