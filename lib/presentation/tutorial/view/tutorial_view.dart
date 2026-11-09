import 'dart:async';

import 'package:dashink/core/router/route_paths.dart';
import 'package:dashink/core/theme/app_spacing.dart';
import 'package:dashink/core/theme/app_text_styles.dart';
import 'package:dashink/core/widgets/app_button.dart';
import 'package:dashink/core/widgets/app_decorations.dart';
import 'package:dashink/core/widgets/app_ink_meter.dart';
import 'package:dashink/core/widgets/app_motion.dart';
import 'package:dashink/domain/game/game_args.dart';
import 'package:dashink/generated/assets.gen.dart';
import 'package:dashink/generated/colors.gen.dart';
import 'package:dashink/generated/locale_keys.g.dart';
import 'package:dashink/presentation/tutorial/bloc/tutorial_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'mixin/tutorial_view_mixin.dart';
part 'widgets/tutorial_bubble.dart';
part 'widgets/tutorial_scene.dart';

/// Ayarlardan mı (geri döner) ilk açılıştan mı (ilk oyuna geçer) açıldı.
class TutorialArgs {
  const TutorialArgs({required this.firstLaunch});

  final bool firstLaunch;
}

/// Figma `egitim`: 3 adım (tasarımda 1. adım çizili; diğer ikisi aynı
/// sahne ve balon düzeniyle).
class TutorialView extends StatefulWidget {
  const TutorialView({required this.args, super.key});

  final TutorialArgs args;

  @override
  State<TutorialView> createState() => _TutorialViewState();
}

class _TutorialViewState extends State<TutorialView> with TutorialViewMixin {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TutorialBloc, TutorialState>(
      listener: onStateChanged,
      builder: (context, state) => Scaffold(
        backgroundColor: ColorName.paper,
        body: Stack(
          fit: StackFit.expand,
          children: [
            TutorialScene(step: state.step),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                    ),
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: AppButton(
                        label: LocaleKeys.tutorial_skip.tr(),
                        type: AppButtonType.ghost,
                        expand: false,
                        onPressed: onSkipTapped,
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: TutorialState.stepCount,
                      onPageChanged: onPageChanged,
                      itemBuilder: (context, index) => Align(
                        alignment: Alignment.topCenter,
                        child: TutorialBubble(step: index),
                      ),
                    ),
                  ),
                  _StepDots(step: state.step),
                  const SizedBox(height: AppSpacing.m),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: AppButton(
                      label: state.isLast
                          ? LocaleKeys.tutorial_got_it.tr()
                          : LocaleKeys.tutorial_next.tr(),
                      onPressed: onPrimaryTapped,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: LocaleKeys.tutorial_step_label.tr(
        namedArgs: {
          'current': '${step + 1}',
          'total': '${TutorialState.stepCount}',
        },
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < TutorialState.stepCount; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: i == step ? 28 : 10,
              height: 10,
              decoration: BoxDecoration(
                color: i == step ? ColorName.tomato : ColorName.paperCard,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: ColorName.ink,
                  width: AppStroke.regular,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
