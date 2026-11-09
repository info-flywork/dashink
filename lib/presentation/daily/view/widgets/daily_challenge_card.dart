part of '../daily_view.dart';

/// Tarih, parkur görseli, açıklama ve üç istatistik.
class DailyChallengeCard extends StatelessWidget {
  const DailyChallengeCard({
    required this.challenge,
    required this.onElapsed,
    super.key,
  });

  final DailyChallenge challenge;
  final VoidCallback onElapsed;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(challenge.date ?? '') ?? DateTime.now();
    final dateLabel = DateFormat(
      'd MMMM',
      context.locale.toString(),
    ).format(date).toUpperCase();
    final best = challenge.myBest;
    final endsAt = challenge.endsAt?.toLocal();
    return AppCard(
      radius: AppRadius.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppSvgIcon(Assets.icons.calendarTomato, size: 22),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  LocaleKeys.daily_date_label.tr(args: [dateLabel]),
                  style: AppTextStyles.labelHeavy.tomato,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Border ile clip aynı Container'da olursa köşe çizgileri kesilir;
          // çerçeve dışarıda, görsel ClipRRect ile yuvarlanır.
          Container(
            height: 190,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.m),
              border: AppDecorations.border,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                AppRadius.m - AppStroke.regular,
              ),
              child: Assets.images.gunlukParkur.image(fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            LocaleKeys.daily_description.tr(),
            style: AppTextStyles.bodyMedium.ink,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _Stat(
                value: challenge.participants.grouped(context),
                label: LocaleKeys.daily_participants.tr(),
              ),
              const SizedBox(width: AppSpacing.xs),
              _Stat(
                value: best == null ? '—' : best.grouped(context),
                label: challenge.myRank == null
                    ? LocaleKeys.daily_your_best.tr()
                    : LocaleKeys.daily_your_rank.tr(
                        args: ['${challenge.myRank}'],
                      ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _StatBox(
                  label: LocaleKeys.daily_time_left.tr(),
                  child: endsAt == null
                      ? Text('—', style: AppTextStyles.stat.ink)
                      : AppCountdownText(
                          endsAt: endsAt,
                          style: AppTextStyles.stat.ink,
                          onElapsed: onElapsed,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: _StatBox(
      label: label,
      child: Text(value, style: AppTextStyles.stat.ink),
    ),
  );
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: ColorName.paper,
        borderRadius: BorderRadius.circular(AppRadius.m),
      ),
      child: Column(
        children: [
          FittedBox(fit: BoxFit.scaleDown, child: child),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.inkSoft,
          ),
        ],
      ),
    );
  }
}
