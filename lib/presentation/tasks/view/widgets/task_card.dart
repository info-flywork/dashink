part of '../tasks_view.dart';

/// Figma `Task/*`: devam eden (ilerleme n/m + ödül), tamamlandı (AL),
/// alındı (soluk + ALINDI).
class TaskCard extends StatelessWidget {
  const TaskCard({required this.task, required this.onClaim, super.key});

  final GameTask task;

  /// AL'a basıldı; butonun ekrandaki konumuyla (kutlama oradan başlar).
  final ValueChanged<Rect?> onClaim;

  @override
  Widget build(BuildContext context) {
    final claimable = task.status == TaskStatus.claimable;
    final claimed = task.status == TaskStatus.claimed;
    final complete = claimable || claimed;
    final unlocks = task.unlocksItem;
    return Opacity(
      opacity: claimed ? 0.6 : 1,
      child: AppCard(
        padding: const EdgeInsets.all(12),
        shadowed: !claimed,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: claimable ? ColorName.mint : ColorName.tomatoTint,
                shape: BoxShape.circle,
              ),
              child: _icon(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ItemAssets.taskName(task.id),
                    style: AppTextStyles.rowLabel.ink,
                  ),
                  if (unlocks != null)
                    Text(
                      LocaleKeys.tasks_unlocks.tr(
                        args: [ItemAssets.name(unlocks)],
                      ),
                      style: AppTextStyles.caption.tomato,
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: AppProgressBar(
                          value: task.ratio,
                          color: complete ? ColorName.mint : ColorName.tomato,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${task.progress.clamp(0, task.target)}/${task.target}',
                        style: AppTextStyles.captionHeavy.inkSoft,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (claimed)
              Text(
                LocaleKeys.tasks_claimed.tr(),
                style: AppTextStyles.captionHeavy.inkSoft,
              )
            else if (claimable)
              _ClaimButton(reward: task.reward, onTap: onClaim)
            else
              AppCoinPill(label: '+${task.reward}'),
          ],
        ),
      ),
    );
  }

  Widget _icon() => switch (task.icon) {
    'trophy' => AppSvgIcon(Assets.icons.trophy24),
    'share' => AppSvgIcon(Assets.icons.share24),
    'calendar' => AppSvgIcon(Assets.icons.calendar24),
    'crown' => AppSvgIcon(Assets.icons.crown24),
    'coin' => Assets.images.coin.image(width: 26, height: 26),
    _ => AppSvgIcon(Assets.icons.play24),
  };
}

/// Figma `ClaimButton`: nane zemin, "AL" + ödül.
class _ClaimButton extends StatelessWidget {
  const _ClaimButton({required this.reward, required this.onTap});

  final int reward;
  final ValueChanged<Rect?> onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: () => onTap(AppRewardBurst.rectOf(context)),
        child: AppPulse(
          child: Container(
            width: 76,
            height: 48,
            decoration: BoxDecoration(
              color: ColorName.mint,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: AppDecorations.border,
              boxShadow: const [
                BoxShadow(color: ColorName.ink, offset: Offset(0, 3)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  LocaleKeys.tasks_claim.tr(),
                  style: AppTextStyles.display(20, height: 1.1).ink,
                ),
                Text('+$reward', style: AppTextStyles.tiny.ink),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
