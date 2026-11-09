import 'dart:async';

import 'package:dashink/core/router/route_paths.dart';
import 'package:dashink/core/snackbar/app_snackbar.dart';
import 'package:dashink/core/sound/sound_manager.dart';
import 'package:dashink/core/theme/app_spacing.dart';
import 'package:dashink/core/theme/app_text_styles.dart';
import 'package:dashink/core/utils/enum/snackbar_type.dart';
import 'package:dashink/core/utils/extensions/number_extensions.dart';
import 'package:dashink/core/widgets/app_button.dart';
import 'package:dashink/core/widgets/app_coin_pill.dart';
import 'package:dashink/core/widgets/app_decorations.dart';
import 'package:dashink/core/widgets/app_motion.dart';
import 'package:dashink/domain/game/game_args.dart';
import 'package:dashink/generated/assets.gen.dart';
import 'package:dashink/generated/locale_keys.g.dart';
import 'package:dashink/presentation/home/bloc/home_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

part 'mixin/home_view_mixin.dart';
part 'widgets/home_hero.dart';

/// Figma `ana-ekran`.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with HomeViewMixin {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listenWhen: (a, b) => b.rewards.isNotEmpty && a.rewards != b.rewards,
      listener: onRewards,
      builder: (context, state) => AppPaperBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: AppCoinPill(amount: state.coins),
                ),
              ),
              Expanded(
                child: HomeHero(
                  bestScore: state.bestScore,
                  onPlayTapped: onPlayTapped,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: LocaleKeys.home_daily.tr(),
                        type: AppButtonType.secondary,
                        icon: AppSvgIcon(Assets.icons.calendarBtn, size: 26),
                        onPressed: onDailyTapped,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: AppButton(
                        label: LocaleKeys.home_leaderboard.tr(),
                        type: AppButtonType.secondary,
                        icon: AppSvgIcon(Assets.icons.trophyBtn, size: 26),
                        onPressed: onLeaderboardTapped,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
