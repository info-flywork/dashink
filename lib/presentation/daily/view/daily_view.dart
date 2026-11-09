import 'dart:async';

import 'package:dashink/core/router/route_paths.dart';
import 'package:dashink/core/theme/app_spacing.dart';
import 'package:dashink/core/theme/app_text_styles.dart';
import 'package:dashink/core/utils/error_messages.dart';
import 'package:dashink/core/utils/extensions/number_extensions.dart';
import 'package:dashink/core/widgets/app_button.dart';
import 'package:dashink/core/widgets/app_coin_pill.dart';
import 'package:dashink/core/widgets/app_countdown_text.dart';
import 'package:dashink/core/widgets/app_decorations.dart';
import 'package:dashink/core/widgets/app_error_view.dart';
import 'package:dashink/core/widgets/app_loading.dart';
import 'package:dashink/core/widgets/app_motion.dart';
import 'package:dashink/core/widgets/app_screen_header.dart';
import 'package:dashink/data/model/daily/daily_challenge.dart';
import 'package:dashink/domain/game/game_args.dart';
import 'package:dashink/domain/game/game_record.dart';
import 'package:dashink/generated/assets.gen.dart';
import 'package:dashink/generated/colors.gen.dart';
import 'package:dashink/generated/locale_keys.g.dart';
import 'package:dashink/presentation/daily/bloc/daily_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'mixin/daily_view_mixin.dart';
part 'widgets/daily_challenge_card.dart';
part 'widgets/daily_reward_card.dart';

/// Figma `gunluk-meydan-okuma`.
class DailyView extends StatefulWidget {
  const DailyView({super.key});

  @override
  State<DailyView> createState() => _DailyViewState();
}

class _DailyViewState extends State<DailyView> with DailyViewMixin {
  @override
  Widget build(BuildContext context) {
    return AppPaperBackground(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppScreenHeader(
              title: LocaleKeys.daily_title.tr(),
              trailing: AppCloseButton(onTap: onCloseTapped),
            ),
            Expanded(
              child: BlocBuilder<DailyBloc, DailyState>(
                builder: (context, state) => switch (state) {
                  DailyLoading() => const AppLoading(),
                  DailyError(:final error) => AppErrorView(
                    message: ErrorMessages.of(error),
                    onRetry: onRetry,
                  ),
                  DailyLoaded(:final challenge) => ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      AppEntrance(
                        child: DailyChallengeCard(
                          challenge: challenge,
                          onElapsed: onRetry,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s),
                      AppEntrance(
                        index: 1,
                        child: DailyRewardCard(challenge: challenge),
                      ),
                      const SizedBox(height: AppSpacing.s),
                      AppEntrance(
                        index: 2,
                        child: AppButton(
                          label: LocaleKeys.daily_start.tr(),
                          icon: AppSvgIcon(Assets.icons.playBtnWhite, size: 26),
                          onPressed: () => onStartTapped(challenge),
                        ),
                      ),
                    ],
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
