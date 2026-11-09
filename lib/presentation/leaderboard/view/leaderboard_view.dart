import 'package:dashink/core/router/route_paths.dart';
import 'package:dashink/core/theme/app_spacing.dart';
import 'package:dashink/core/theme/app_text_styles.dart';
import 'package:dashink/core/utils/error_messages.dart';
import 'package:dashink/core/utils/extensions/number_extensions.dart';
import 'package:dashink/core/widgets/app_decorations.dart';
import 'package:dashink/core/widgets/app_error_view.dart';
import 'package:dashink/core/widgets/app_loading.dart';
import 'package:dashink/core/widgets/app_motion.dart';
import 'package:dashink/core/widgets/app_screen_header.dart';
import 'package:dashink/core/widgets/app_segmented.dart';
import 'package:dashink/data/model/leaderboard/leaderboard.dart';
import 'package:dashink/generated/assets.gen.dart';
import 'package:dashink/generated/colors.gen.dart';
import 'package:dashink/generated/locale_keys.g.dart';
import 'package:dashink/presentation/leaderboard/bloc/leaderboard_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'mixin/leaderboard_view_mixin.dart';
part 'widgets/leaderboard_avatar.dart';
part 'widgets/leaderboard_podium.dart';
part 'widgets/leaderboard_row.dart';

/// Figma `siralama`.
class LeaderboardView extends StatefulWidget {
  const LeaderboardView({super.key});

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView>
    with LeaderboardViewMixin {
  @override
  Widget build(BuildContext context) {
    return AppPaperBackground(
      child: SafeArea(
        bottom: false,
        child: BlocBuilder<LeaderboardBloc, LeaderboardState>(
          builder: (context, state) => Column(
            children: [
              AppScreenHeader(
                title: LocaleKeys.leaderboard_title.tr(),
                trailing: AppCloseButton(onTap: onCloseTapped),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: AppSegmented(
                  labels: [
                    LocaleKeys.leaderboard_daily.tr(),
                    LocaleKeys.leaderboard_weekly.tr(),
                    LocaleKeys.leaderboard_all.tr(),
                  ],
                  selectedIndex: state.period.index,
                  onChanged: onPeriodChanged,
                ),
              ),
              Expanded(
                child: switch (state) {
                  LeaderboardLoading() => const AppLoading(),
                  LeaderboardError(:final error) => AppErrorView(
                    message: ErrorMessages.of(error),
                    onRetry: () => onPeriodChanged(state.period.index),
                  ),
                  LeaderboardLoaded(:final board) => _LeaderboardBody(
                    key: ValueKey(state.period),
                    board: board,
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaderboardBody extends StatelessWidget {
  const _LeaderboardBody({required this.board, super.key});

  final Leaderboard board;

  @override
  Widget build(BuildContext context) {
    final entries = board.entries;
    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Text(
            LocaleKeys.leaderboard_empty.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.inkSoft,
          ),
        ),
      );
    }
    final podium = entries.take(3).toList();
    final rest = entries.skip(3).toList();
    final me = board.me;
    final meInList = entries.any((e) => e.isMe);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        AppEntrance(child: LeaderboardPodium(entries: podium)),
        const SizedBox(height: AppSpacing.s),
        for (var i = 0; i < rest.length; i++) ...[
          AppEntrance(
            index: i + 1,
            child: LeaderboardRow(entry: rest[i]),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        if (me != null && !meInList)
          AppEntrance(
            index: rest.length + 1,
            child: LeaderboardRow(entry: me, highlighted: true),
          ),
      ],
    );
  }
}
