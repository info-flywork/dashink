import 'package:dashink/core/di/injection.dart';
import 'package:dashink/core/router/app_page_transitions.dart';
import 'package:dashink/core/router/route_paths.dart';
import 'package:dashink/data/model/leaderboard/leaderboard.dart';
import 'package:dashink/data/model/task/task_list.dart';
import 'package:dashink/domain/game/game_args.dart';
import 'package:dashink/presentation/daily/bloc/daily_bloc.dart';
import 'package:dashink/presentation/daily/view/daily_view.dart';
import 'package:dashink/presentation/game/bloc/game_bloc.dart';
import 'package:dashink/presentation/game/view/game_view.dart';
import 'package:dashink/presentation/home/bloc/home_bloc.dart';
import 'package:dashink/presentation/home/view/home_view.dart';
import 'package:dashink/presentation/leaderboard/bloc/leaderboard_bloc.dart';
import 'package:dashink/presentation/leaderboard/view/leaderboard_view.dart';
import 'package:dashink/presentation/settings/bloc/settings_bloc.dart';
import 'package:dashink/presentation/settings/view/settings_view.dart';
import 'package:dashink/presentation/shell/view/shell_view.dart';
import 'package:dashink/presentation/shop/bloc/shop_bloc.dart';
import 'package:dashink/presentation/shop/bloc/shop_event.dart';
import 'package:dashink/presentation/shop/view/shop_view.dart';
import 'package:dashink/presentation/splash/bloc/splash_bloc.dart';
import 'package:dashink/presentation/splash/bloc/splash_event.dart';
import 'package:dashink/presentation/splash/view/splash_view.dart';
import 'package:dashink/presentation/tasks/bloc/tasks_bloc.dart';
import 'package:dashink/presentation/tasks/view/tasks_view.dart';
import 'package:dashink/presentation/tutorial/bloc/tutorial_bloc.dart';
import 'package:dashink/presentation/tutorial/view/tutorial_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Splash -> (ilk açılış) Eğitim -> Oyun; sonra alt sekmeli kabuk:
/// Oyna (Sıralama, Günlük) / Mağaza / Görevler / Ayarlar. Oyun tam ekran.
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: RoutePaths.splash.path,
  routes: [
    GoRoute(
      path: RoutePaths.splash.path,
      name: RoutePaths.splash.name,
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<SplashBloc>()..add(const SplashStarted()),
        child: const SplashView(),
      ),
    ),
    GoRoute(
      path: RoutePaths.tutorial.path,
      name: RoutePaths.tutorial.name,
      pageBuilder: (context, state) => AppPageTransitions.fadeUp(
        state,
        BlocProvider(
          create: (_) => getIt<TutorialBloc>(),
          child: TutorialView(
            args: state.extra is TutorialArgs
                ? state.extra! as TutorialArgs
                : const TutorialArgs(firstLaunch: false),
          ),
        ),
      ),
    ),
    GoRoute(
      path: RoutePaths.game.path,
      name: RoutePaths.game.name,
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) => AppPageTransitions.zoom(
        state,
        BlocProvider(
          create: (_) => getIt<GameBloc>(),
          child: GameView(
            args: state.extra is GameArgs
                ? state.extra! as GameArgs
                : const GameArgs(),
          ),
        ),
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) =>
          ShellView(navigationShell: shell, soundManager: getIt()),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.home.path,
              name: RoutePaths.home.name,
              pageBuilder: (context, state) => AppPageTransitions.fadeScale(
                state,
                BlocProvider(
                  create: (_) => getIt<HomeBloc>()..add(const HomeStarted()),
                  child: const HomeView(),
                ),
              ),
              routes: [
                GoRoute(
                  path: RoutePaths.leaderboard.path,
                  name: RoutePaths.leaderboard.name,
                  pageBuilder: (context, state) => AppPageTransitions.fadeUp(
                    state,
                    BlocProvider(
                      create: (_) => getIt<LeaderboardBloc>()
                        ..add(
                          const LeaderboardPeriodSelected(
                            LeaderboardPeriod.daily,
                          ),
                        ),
                      child: const LeaderboardView(),
                    ),
                  ),
                ),
                GoRoute(
                  path: RoutePaths.daily.path,
                  name: RoutePaths.daily.name,
                  pageBuilder: (context, state) => AppPageTransitions.fadeUp(
                    state,
                    BlocProvider(
                      create: (_) =>
                          getIt<DailyBloc>()..add(const DailyRequested()),
                      child: const DailyView(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.shop.path,
              name: RoutePaths.shop.name,
              builder: (context, state) => BlocProvider(
                create: (_) => getIt<ShopBloc>()..add(const ShopStarted()),
                child: const ShopView(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.tasks.path,
              name: RoutePaths.tasks.name,
              builder: (context, state) => BlocProvider(
                create: (_) =>
                    getIt<TasksBloc>()
                      ..add(const TasksPeriodSelected(TaskPeriod.daily)),
                child: const TasksView(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.settings.path,
              name: RoutePaths.settings.name,
              builder: (context, state) => BlocProvider(
                create: (_) => getIt<SettingsBloc>(),
                child: const SettingsView(),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
