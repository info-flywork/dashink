part of '../leaderboard_view.dart';

/// Baş harfli yuvarlak avatar.
class LeaderboardAvatar extends StatelessWidget {
  const LeaderboardAvatar({
    required this.name,
    required this.size,
    this.color = ColorName.paperLine,
    super.key,
  });

  final String name;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty
        ? '?'
        : name.trim().characters.first.toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: ColorName.ink, width: AppStroke.regular),
      ),
      child: Text(
        initial,
        style: AppTextStyles.display(size * 0.42, height: 1).ink,
      ),
    );
  }
}

String leaderboardName(LeaderboardEntry entry) =>
    entry.isMe ? LocaleKeys.common_you.tr() : (entry.name ?? '—');
