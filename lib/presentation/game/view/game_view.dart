import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:dashink/core/clip/clip_recorder.dart';
import 'package:dashink/core/dialogs/app_dialogs.dart';
import 'package:dashink/core/dialogs/widgets/game_dialogs.dart';
import 'package:dashink/core/router/route_paths.dart';
import 'package:dashink/core/sound/sound_manager.dart';
import 'package:dashink/core/theme/app_spacing.dart';
import 'package:dashink/core/theme/app_text_styles.dart';
import 'package:dashink/core/utils/extensions/bloc_extensions.dart';
import 'package:dashink/core/utils/item_assets.dart';
import 'package:dashink/core/widgets/app_button.dart';
import 'package:dashink/core/widgets/app_coin_pill.dart';
import 'package:dashink/core/widgets/app_decorations.dart';
import 'package:dashink/core/widgets/app_ink_meter.dart';
import 'package:dashink/domain/game/game_args.dart';
import 'package:dashink/domain/game/game_record.dart';
import 'package:dashink/domain/game/game_world.dart';
import 'package:dashink/generated/assets.gen.dart';
import 'package:dashink/generated/colors.gen.dart';
import 'package:dashink/generated/locale_keys.g.dart';
import 'package:dashink/presentation/game/bloc/game_bloc.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

part 'mixin/game_view_mixin.dart';
part 'widgets/game_background.dart';
part 'widgets/game_hud.dart';
part 'widgets/game_painter.dart';

/// Oyun ekranı (Figma'da `top-dustu` anı; oyun sırasındaki görünüm aynı
/// dilde tasarlandı): top kendiliğinden yuvarlanır, oyuncu önüne mürekkeple
/// çizer, mürekkep 1 saniyede silinir.
class GameView extends StatefulWidget {
  const GameView({required this.args, super.key});

  final GameArgs args;

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver, GameViewMixin {
  @override
  Widget build(BuildContext context) {
    return BlocListener<GameBloc, GameState>(
      listenWhen: (a, b) => a.run != b.run,
      listener: (context, state) => resetRun(state),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) unawaited(onPauseTapped());
        },
        child: Scaffold(
          backgroundColor: ColorName.paper,
          body: LayoutBuilder(
            builder: (context, constraints) {
              updateViewport(constraints.biggest);
              final state = context.watch<GameBloc>().state;
              final look = lookFor(state);
              return Stack(
                fit: StackFit.expand,
                children: [
                  RepaintBoundary(
                    key: boundaryKey,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        GameBackground(themeId: state.equipped.theme),
                        CustomPaint(
                          painter: GamePainter(
                            world: world,
                            sprites: sprites,
                            look: look,
                            repaint: frame,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: onDrawStart,
                    onPanUpdate: onDrawUpdate,
                    onPanEnd: onDrawEnd,
                    onPanCancel: onDrawCancel,
                  ),
                  GameHud(
                    frame: frame,
                    world: () => world,
                    inkColor: look.ink,
                    dark: look.dark,
                    daily: state.mode == GameMode.daily,
                    showHint: () => showDrawHint,
                    onPauseTapped: onPauseTapped,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
