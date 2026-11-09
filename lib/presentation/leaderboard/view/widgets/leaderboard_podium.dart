part of '../leaderboard_view.dart';

/// İlk üç: 2 - 1 - 3 sıralı kürsü (1. altın, taçlı).
class LeaderboardPodium extends StatelessWidget {
  const LeaderboardPodium({required this.entries, super.key});

  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    LeaderboardEntry? at(int i) => i < entries.length ? entries[i] : null;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _Place(entry: at(1), place: 2)),
          const SizedBox(width: AppSpacing.s),
          Expanded(child: _Place(entry: at(0), place: 1)),
          const SizedBox(width: AppSpacing.s),
          Expanded(child: _Place(entry: at(2), place: 3)),
        ],
      ),
    );
  }
}

class _Place extends StatelessWidget {
  const _Place({required this.entry, required this.place});

  final LeaderboardEntry? entry;
  final int place;

  @override
  Widget build(BuildContext context) {
    final e = entry;
    final first = place == 1;
    final pedestalColor = switch (place) {
      1 => ColorName.gold,
      2 => ColorName.paperCard,
      _ => ColorName.tomatoTint,
    };
    final pedestalHeight = switch (place) {
      1 => 100.0,
      2 => 72.0,
      _ => 56.0,
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (first) AppSvgIcon(Assets.icons.crown28, size: 28),
        if (e != null) ...[
          const SizedBox(height: 4),
          LeaderboardAvatar(
            name: leaderboardName(e),
            size: first ? 64 : 52,
            color: first ? ColorName.gold : ColorName.paperLine,
          ),
          const SizedBox(height: 4),
          Text(
            leaderboardName(e),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelBold.ink,
          ),
          Text(e.score.grouped(context), style: AppTextStyles.valueBold.ink),
          const SizedBox(height: 4),
        ],
        Container(
          height: pedestalHeight,
          width: double.infinity,
          padding: const EdgeInsets.only(top: 10),
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
            color: pedestalColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.m),
            ),
            border: Border.all(color: ColorName.ink, width: AppStroke.regular),
            boxShadow: const [AppDecorations.shadow],
          ),
          child: Text('$place', style: AppTextStyles.pedestal.ink),
        ),
      ],
    );
  }
}
