import 'dart:async';

import 'package:dashink/core/dialogs/widgets/modal_card.dart';
import 'package:dashink/core/theme/app_spacing.dart';
import 'package:dashink/core/theme/app_text_styles.dart';
import 'package:dashink/core/utils/extensions/number_extensions.dart';
import 'package:dashink/core/widgets/app_button.dart';
import 'package:dashink/core/widgets/app_coin_pill.dart';
import 'package:dashink/core/widgets/app_decorations.dart';
import 'package:dashink/core/widgets/app_motion.dart';
import 'package:dashink/domain/game/game_record.dart';
import 'package:dashink/generated/assets.gen.dart';
import 'package:dashink/generated/colors.gen.dart';
import 'package:dashink/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

enum PauseAction { resume, restart, home }

/// Oyun sonu ekranlarından seçilen aksiyon. [record]: yeni rekor
/// kutlamasına geçiş (oyun-bitti kendiliğinden ilerler).
enum GameOverAction { playAgain, share, home, record }

/// Duraklatma (Figma'da yok; kart diliyle).
class PauseDialog extends StatelessWidget {
  const PauseDialog({super.key});

  @override
  Widget build(BuildContext context) {
    void pop(PauseAction a) => Navigator.of(context).pop(a);
    return ModalCard(
      children: [
        Text(LocaleKeys.game_paused.tr(), style: AppTextStyles.modalTitle.ink),
        AppButton(
          label: LocaleKeys.game_resume.tr(),
          onPressed: () => pop(PauseAction.resume),
        ),
        AppButton(
          label: LocaleKeys.game_restart.tr(),
          type: AppButtonType.secondary,
          icon: AppSvgIcon(Assets.icons.restartBtn, size: 26),
          onPressed: () => pop(PauseAction.restart),
        ),
        AppButton(
          label: LocaleKeys.game_home.tr(),
          type: AppButtonType.ghost,
          expand: false,
          onPressed: () => pop(PauseAction.home),
        ),
      ],
    );
  }
}

/// Figma `oyun-bitti`: SKOR, EN İYİ, TEKRAR OYNA, paylaş / ana ekran.
/// Yeni rekorda "YENİ REKOR!" rozeti görünür ve kısa süre sonra
/// [GameOverAction.record] ile kutlamaya geçer.
class GameOverDialog extends StatefulWidget {
  const GameOverDialog({required this.outcome, super.key});

  final GameOutcome outcome;

  @override
  State<GameOverDialog> createState() => _GameOverDialogState();
}

class _GameOverDialogState extends State<GameOverDialog> {
  Timer? _advance;

  @override
  void initState() {
    super.initState();
    if (widget.outcome.newRecord) {
      _advance = Timer(const Duration(milliseconds: 1400), () {
        if (mounted) Navigator.of(context).pop(GameOverAction.record);
      });
    }
  }

  @override
  void dispose() {
    _advance?.cancel();
    super.dispose();
  }

  void _pop(GameOverAction action) {
    _advance?.cancel();
    Navigator.of(context).pop(action);
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.outcome;
    final dailyRank = o.daily?.rank;
    return ModalCard(
      overlay: o.newRecord
          ? const PositionedDirectional(
              top: -26,
              end: -6,
              child: _RecordBadge(),
            )
          : null,
      children: [
        Column(
          children: [
            Text(
              LocaleKeys.game_over_score.tr(),
              style: AppTextStyles.scoreLabel.inkSoft,
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: AppAnimatedCount(
                value: o.score,
                style: AppTextStyles.scoreHuge.ink,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSvgIcon(Assets.icons.crown, size: 22),
                const SizedBox(width: 6),
                Text(
                  LocaleKeys.game_over_best.tr(
                    args: [o.bestScore.grouped(context)],
                  ),
                  style: AppTextStyles.valueBold.ink,
                ),
              ],
            ),
            if (dailyRank != null || o.offline) ...[
              const SizedBox(height: 4),
              Text(
                o.offline
                    ? LocaleKeys.game_over_offline_note.tr()
                    : LocaleKeys.game_over_daily_rank.tr(args: ['$dailyRank']),
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.inkSoft,
              ),
            ],
          ],
        ),
        AppButton(
          label: LocaleKeys.game_over_play_again.tr(),
          type: AppButtonType.secondary,
          icon: AppSvgIcon(Assets.icons.restartBtn, size: 26),
          onPressed: () => _pop(GameOverAction.playAgain),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIconButton(
              icon: AppSvgIcon(Assets.icons.shareBtn, size: 26),
              semanticLabel: LocaleKeys.game_over_share.tr(),
              onTap: () => _pop(GameOverAction.share),
            ),
            const SizedBox(width: 20),
            AppIconButton(
              icon: AppSvgIcon(Assets.icons.homeBtn, size: 26),
              semanticLabel: LocaleKeys.game_over_home.tr(),
              onTap: () => _pop(GameOverAction.home),
            ),
          ],
        ),
      ],
    );
  }
}

/// Figma `RecordBadge`: nane zemin, -8° eğik.
class _RecordBadge extends StatelessWidget {
  const _RecordBadge();

  @override
  Widget build(BuildContext context) {
    return AppEntrance(
      scaleFrom: 0.6,
      offset: Offset.zero,
      child: Transform.rotate(
        angle: -0.14,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: ColorName.mint,
            borderRadius: BorderRadius.circular(AppRadius.s),
            border: AppDecorations.border,
          ),
          child: Text(
            LocaleKeys.game_over_new_record.tr(),
            style: AppTextStyles.option.white.copyWith(),
          ),
        ),
      ),
    );
  }
}

/// Figma `rekor-rozeti`. PAYLAŞ -> `true`, DEVAM ET -> `false`.
class RecordDialog extends StatelessWidget {
  const RecordDialog({required this.outcome, super.key});

  final GameOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final o = outcome;
    return ModalCard(
      children: [
        AppEntrance(
          scaleFrom: 0.4,
          offset: Offset.zero,
          curve: Curves.elasticOut,
          duration: const Duration(milliseconds: 900),
          child: Assets.images.rekorRozet.image(width: 168, height: 168),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            LocaleKeys.record_title.tr(),
            style: AppTextStyles.recordTitle.ink,
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            o.score.grouped(context),
            style: AppTextStyles.scoreLarge.ink,
          ),
        ),
        Text(
          LocaleKeys.record_previous.tr(
            namedArgs: {
              'previous': o.previousBest.grouped(context),
              'diff': o.improvement.grouped(context),
            },
          ),
          textAlign: TextAlign.center,
          style: AppTextStyles.labelBold.inkSoft,
        ),
        if (o.recordReward > 0) AppCoinPill(label: '+${o.recordReward}'),
        AppButton(
          label: LocaleKeys.record_continue.tr(),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppButton(
          label: LocaleKeys.record_share.tr(),
          type: AppButtonType.secondary,
          icon: AppSvgIcon(Assets.icons.shareBtn, size: 26),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}

/// Figma `oyuncu-secimi`.
class ChoiceDialog extends StatelessWidget {
  const ChoiceDialog({required this.score, super.key});

  final int score;

  @override
  Widget build(BuildContext context) {
    void pop(GameOverAction a) => Navigator.of(context).pop(a);
    return ModalCard(
      children: [
        Column(
          children: [
            Text(
              LocaleKeys.game_over_score.tr(),
              style: AppTextStyles.scoreLabel.inkSoft,
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                score.grouped(context),
                style: AppTextStyles.scoreLarge.ink,
              ),
            ),
          ],
        ),
        Text(
          LocaleKeys.choice_question.tr(),
          style: AppTextStyles.labelBold.inkSoft,
        ),
        _ChoiceOption(
          primary: true,
          icon: AppSvgIcon(Assets.icons.rotateCcwWhite, size: 32),
          title: LocaleKeys.choice_play_again.tr(),
          subtitle: LocaleKeys.choice_play_again_sub.tr(),
          onTap: () => pop(GameOverAction.playAgain),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ChoiceOption(
                icon: AppSvgIcon(Assets.icons.share32, size: 32),
                title: LocaleKeys.choice_share.tr(),
                subtitle: LocaleKeys.choice_share_sub.tr(),
                onTap: () => pop(GameOverAction.share),
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: _ChoiceOption(
                icon: AppSvgIcon(Assets.icons.house32, size: 32),
                title: LocaleKeys.choice_home.tr(),
                subtitle: LocaleKeys.choice_home_sub.tr(),
                onTap: () => pop(GameOverAction.home),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChoiceOption extends StatelessWidget {
  const _ChoiceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.primary = false,
  });

  final Widget icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 18, 12, 16),
          decoration: primary
              ? BoxDecoration(
                  color: ColorName.tomato,
                  borderRadius: BorderRadius.circular(AppRadius.l),
                  boxShadow: const [
                    BoxShadow(
                      color: ColorName.tomatoDark,
                      offset: Offset(0, 5),
                    ),
                  ],
                )
              : AppDecorations.card(),
          child: Column(
            children: [
              icon,
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: primary
                      ? AppTextStyles.option.white
                      : AppTextStyles.option.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: primary
                    ? AppTextStyles.caption.white
                    : AppTextStyles.caption.inkSoft,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
