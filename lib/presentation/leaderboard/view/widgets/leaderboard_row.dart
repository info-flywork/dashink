part of '../leaderboard_view.dart';

/// Liste satırı. Oyuncunun kendi satırı domates tonlu.
class LeaderboardRow extends StatelessWidget {
  const LeaderboardRow({required this.entry, this.highlighted, super.key});

  final LeaderboardEntry entry;
  final bool? highlighted;

  @override
  Widget build(BuildContext context) {
    final mine = highlighted ?? entry.isMe;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 16, 8),
      decoration: BoxDecoration(
        color: mine ? ColorName.tomatoTint : ColorName.paperCard,
        borderRadius: BorderRadius.circular(AppRadius.l),
        border: Border.all(
          color: mine ? ColorName.tomato : ColorName.ink,
          width: AppStroke.regular,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${entry.rank}',
                textAlign: TextAlign.center,
                style: AppTextStyles.option.copyWith(
                  color: mine ? ColorName.tomato : ColorName.inkSoft,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          LeaderboardAvatar(
            name: leaderboardName(entry),
            size: 36,
            color: mine ? ColorName.paperCard : ColorName.paperLine,
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              leaderboardName(entry),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.rowLabel.ink,
            ),
          ),
          Text(
            entry.score.grouped(context),
            style: AppTextStyles.valueBold.ink,
          ),
        ],
      ),
    );
  }
}
