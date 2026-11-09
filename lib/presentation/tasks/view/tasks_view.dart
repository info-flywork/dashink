import 'package:dashink/core/snackbar/app_snackbar.dart';
import 'package:dashink/core/theme/app_spacing.dart';
import 'package:dashink/core/theme/app_text_styles.dart';
import 'package:dashink/core/utils/enum/snackbar_type.dart';
import 'package:dashink/core/utils/error_messages.dart';
import 'package:dashink/core/utils/item_assets.dart';
import 'package:dashink/core/widgets/app_coin_pill.dart';
import 'package:dashink/core/widgets/app_countdown_text.dart';
import 'package:dashink/core/widgets/app_decorations.dart';
import 'package:dashink/core/widgets/app_error_view.dart';
import 'package:dashink/core/widgets/app_loading.dart';
import 'package:dashink/core/widgets/app_motion.dart';
import 'package:dashink/core/widgets/app_reward_burst.dart';
import 'package:dashink/core/widgets/app_screen_header.dart';
import 'package:dashink/core/widgets/app_segmented.dart';
import 'package:dashink/data/model/task/task_list.dart';
import 'package:dashink/domain/player/player_exceptions.dart';
import 'package:dashink/generated/assets.gen.dart';
import 'package:dashink/generated/colors.gen.dart';
import 'package:dashink/generated/locale_keys.g.dart';
import 'package:dashink/presentation/tasks/bloc/tasks_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'mixin/tasks_view_mixin.dart';
part 'widgets/task_card.dart';

/// Figma `gorevler`.
class TasksView extends StatefulWidget {
  const TasksView({super.key});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> with TasksViewMixin {
  @override
  Widget build(BuildContext context) {
    return AppPaperBackground(
      child: SafeArea(
        bottom: false,
        child: BlocConsumer<TasksBloc, TasksState>(
          listener: onStateChanged,
          builder: (context, state) => Column(
            children: [
              AppScreenHeader(
                title: LocaleKeys.tasks_title.tr(),
                trailing: AppCoinPill(key: coinPillKey, amount: state.coins),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: AppSegmented(
                  labels: [
                    LocaleKeys.tasks_daily.tr(),
                    LocaleKeys.tasks_weekly.tr(),
                    LocaleKeys.tasks_achievements.tr(),
                  ],
                  selectedIndex: state.period.index,
                  onChanged: onPeriodChanged,
                ),
              ),
              Expanded(
                child: switch (state) {
                  TasksLoading() => const AppLoading(),
                  TasksError(:final error) => AppErrorView(
                    message: ErrorMessages.of(error),
                    onRetry: onRefresh,
                  ),
                  TasksLoaded(:final list) => _TaskList(
                    key: ValueKey(state.period),
                    list: list,
                    onClaim: onClaimTapped,
                    onElapsed: onRefresh,
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

class _TaskList extends StatelessWidget {
  const _TaskList({
    required this.list,
    required this.onClaim,
    required this.onElapsed,
    super.key,
  });

  final TaskList list;
  final void Function(GameTask task, Rect? from) onClaim;
  final VoidCallback onElapsed;

  @override
  Widget build(BuildContext context) {
    final resetsAt = list.resetsAt?.toLocal();
    final caption = AppTextStyles.caption.inkSoft;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Row(
          children: [
            AppSvgIcon(
              Assets.icons.calendar24,
              size: 18,
              color: ColorName.inkSoft,
            ),
            const SizedBox(width: 6),
            if (resetsAt != null)
              AppCountdownText(
                endsAt: resetsAt,
                style: caption,
                builder: (r) => LocaleKeys.tasks_resets_in.tr(args: [r]),
                onElapsed: onElapsed,
              )
            else
              Text(LocaleKeys.tasks_achievements_note.tr(), style: caption),
          ],
        ),
        const SizedBox(height: 10),
        if (list.tasks.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xl),
            child: Text(
              LocaleKeys.tasks_empty.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.inkSoft,
            ),
          ),
        for (var i = 0; i < list.tasks.length; i++) ...[
          // Kısa giriş; uzun listede (başarımlar) gecikme ilk 5 kartla sınırlı.
          AppEntrance(
            index: i < 5 ? i : 5,
            duration: const Duration(milliseconds: 280),
            child: TaskCard(
              task: list.tasks[i],
              onClaim: (from) => onClaim(list.tasks[i], from),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
