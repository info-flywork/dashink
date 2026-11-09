part of '../tutorial_view.dart';

/// Figma `Bubble`: başlık (Luckiest Guy 32) + açıklama (Baloo 16).
class TutorialBubble extends StatelessWidget {
  const TutorialBubble({required this.step, super.key});

  final int step;

  @override
  Widget build(BuildContext context) {
    final (title, body) = switch (step) {
      0 => (LocaleKeys.tutorial_step1_title, LocaleKeys.tutorial_step1_body),
      1 => (LocaleKeys.tutorial_step2_title, LocaleKeys.tutorial_step2_body),
      _ => (LocaleKeys.tutorial_step3_title, LocaleKeys.tutorial_step3_body),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      child: AppEntrance(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: AppDecorations.card(radius: AppRadius.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bubbleTitle.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySemi.inkSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
