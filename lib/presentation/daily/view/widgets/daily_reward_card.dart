part of '../daily_view.dart';

/// "ÖDÜL · İlk 100'e gir, altını kap · +100".
class DailyRewardCard extends StatelessWidget {
  const DailyRewardCard({required this.challenge, super.key});

  final DailyChallenge challenge;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      shadowed: false,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 12, 12),
      child: Row(
        children: [
          AppSvgIcon(Assets.icons.trophy, size: 28),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.daily_reward_title.tr(),
                  style: AppTextStyles.option.ink,
                ),
                Text(
                  LocaleKeys.daily_reward_body.tr(
                    args: ['${challenge.rewardTop}'],
                  ),
                  style: AppTextStyles.caption.inkSoft,
                ),
              ],
            ),
          ),
          AppCoinPill(label: '+${challenge.reward}'),
        ],
      ),
    );
  }
}
