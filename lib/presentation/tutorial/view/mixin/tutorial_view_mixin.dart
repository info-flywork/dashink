part of '../tutorial_view.dart';

mixin TutorialViewMixin on State<TutorialView> {
  TutorialBloc get _bloc => context.read<TutorialBloc>();

  final PageController pageController = PageController();

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int index) => _bloc.add(TutorialPageChanged(index));

  void onSkipTapped() => _bloc.add(const TutorialFinished());

  void onPrimaryTapped() {
    final state = _bloc.state;
    if (state.isLast) {
      _bloc.add(const TutorialFinished());
      return;
    }
    unawaited(
      pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void onStateChanged(BuildContext context, TutorialState state) {
    if (!state.finished) return;
    if (widget.args.firstLaunch) {
      // İlk açılış: eğitimden doğrudan ilk oyuna; oyundan dönüş ana ekrana.
      context.goNamed(RoutePaths.home.name);
      unawaited(
        context.pushNamed(RoutePaths.game.name, extra: const GameArgs()),
      );
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(RoutePaths.home.name);
    }
  }
}
