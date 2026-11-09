part of '../splash_view.dart';

mixin SplashViewMixin on State<SplashView> {
  void onStateChanged(BuildContext context, SplashState state) {
    if (state is! SplashReady) return;
    if (state.showTutorial) {
      context.goNamed(
        RoutePaths.tutorial.name,
        extra: const TutorialArgs(firstLaunch: true),
      );
    } else {
      context.goNamed(RoutePaths.home.name);
    }
  }
}
