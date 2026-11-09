part of '../game_view.dart';

/// Oyun döngüsü (Ticker), çizim jestleri, duraklatma ve oyun sonu akışı:
/// top düştü -> (rekorsa rozet + kutlama -> seçim) / oyun bitti.
mixin GameViewMixin
    on
        State<GameView>,
        SingleTickerProviderStateMixin<GameView>,
        WidgetsBindingObserver {
  GameBloc get _bloc => context.read<GameBloc>();
  SoundManager get _sound => GetIt.instance<SoundManager>();

  final GlobalKey boundaryKey = GlobalKey();
  final ValueNotifier<int> frame = ValueNotifier(0);
  final ClipRecorder _recorder = ClipRecorder();

  late GameWorld world = GameWorld(seed: 0);
  GameSprites? sprites;
  String? _spritesBall;

  late final Ticker _ticker = createTicker(_onTick);
  Duration _lastTick = Duration.zero;
  bool _paused = false;
  bool _ending = false;
  bool _hasDrawn = false;
  double _scale = 1;
  DateTime _lastDrawSound = DateTime(0);

  /// İlk çizime kadar ipucu gösterilir.
  bool get showDrawHint => !_hasDrawn && world.time < 4 && !world.isOver;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bloc.add(GameStarted(widget.args));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _recorder.dispose();
    frame.dispose();
    sprites?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (!_paused && !_ending && _ticker.isActive) {
        unawaited(onPauseTapped());
      }
    }
  }

  void updateViewport(Size size) {
    _scale = size.width / GamePainter.designWidth;
    world.viewWidth = size.width / _scale;
  }

  GameLook lookFor(GameState state) => GameLook(
    ink: ItemAssets.inkColor(state.equipped.ink),
    dark: ItemAssets.isDarkTheme(state.equipped.theme),
    background: ItemAssets.themeColor(state.equipped.theme),
  );

  /// Yeni oyun (ilk açılış / tekrar oyna): dünya, görseller ve kayıt.
  Future<void> resetRun(GameState state) async {
    _ticker.stop();
    world = GameWorld(seed: state.seed)..viewWidth = GamePainter.designWidth;
    _ending = false;
    _paused = false;
    _hasDrawn = false;
    _lastTick = Duration.zero;
    final ballId = state.equipped.ball;
    if (_spritesBall != ballId) {
      final loaded = await GameSprites.load(ballId);
      if (!mounted) return loaded.dispose();
      final old = sprites;
      setState(() {
        sprites = loaded;
        _spritesBall = ballId;
      });
      old?.dispose();
    } else {
      setState(() {});
    }
    _recorder.start(boundaryKey);
    unawaited(_ticker.start());
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    if (_ending) {
      // Fizik durdu; diyalog gelene kadar ölüm animasyonu oynar (donma yok).
      world.advanceDeath(dt);
      frame.value++;
      return;
    }
    if (_paused) return;
    final collected = world.step(dt);
    if (collected > 0) {
      _sound
        ..play(GameSound.coin, volume: 0.5)
        ..haptic();
    }
    frame.value++;
    if (world.isOver) unawaited(_onGameOver());
  }

  // --- Çizim ----------------------------------------------------------------

  Vec2 _toWorld(Offset local) => Vec2(
    local.dx / _scale + world.cameraX,
    local.dy / _scale + world.cameraY,
  );

  void onDrawStart(DragStartDetails d) {
    if (_paused || _ending) return;
    _hasDrawn = true;
    world.beginStroke(_toWorld(d.localPosition));
  }

  void onDrawUpdate(DragUpdateDetails d) {
    if (_paused || _ending) return;
    final added = world.extendStroke(_toWorld(d.localPosition));
    final now = DateTime.now();
    if (added > 0 && now.difference(_lastDrawSound).inMilliseconds > 160) {
      _lastDrawSound = now;
      _sound.play(GameSound.draw, volume: 0.25);
    }
  }

  void onDrawEnd(DragEndDetails d) => world.endStroke();

  void onDrawCancel() => world.endStroke();

  // --- Duraklatma -----------------------------------------------------------

  Future<void> onPauseTapped() async {
    if (_paused || _ending) return;
    _paused = true;
    world.endStroke();
    _recorder.stop();
    final action = await AppDialogs.instance.showPause(context);
    if (!mounted) return;
    switch (action) {
      case PauseAction.resume:
        _paused = false;
        _recorder.start(boundaryKey);
      case PauseAction.restart:
        _bloc.add(const GameRestarted());
      case PauseAction.home:
        _goHome();
    }
  }

  // --- Oyun sonu ------------------------------------------------------------

  Future<void> _onGameOver() async {
    if (_ending) return;
    _ending = true;
    world.endStroke();
    _sound
      ..play(GameSound.fall)
      ..haptic(heavy: true);
    final recording = _recorder.take();
    final score = world.score;
    // Ölüm anı kısa bir patlama animasyonuyla ekranda kalır; sunucu cevabı
    // genelde bu süre içinde gelir.
    final submitted = _bloc.addAndWait(
      GameEnded(
        score: score,
        coinsCollected: world.coinsCollected,
        durationMs: math.max(1, (world.time * 1000).round()),
      ),
      until: (s) => s is GameOver,
    );
    await Future<void>.delayed(GamePainter.deathAnimation);
    final state = await submitted;
    _ticker.stop();
    if (!mounted || state is! GameOver) return recording.dispose();

    final outcome = state.outcome;
    final dialogs = AppDialogs.instance;
    var action = await dialogs.showGameOver(context, outcome: outcome);
    if (!mounted) return recording.dispose();

    var next = () => dialogs.showGameOver(context, outcome: outcome);
    if (action == GameOverAction.record) {
      final share = await dialogs.showRecord(context, outcome: outcome);
      if (!mounted) return recording.dispose();
      if (share) await _share(recording, score);
      if (!mounted) return recording.dispose();
      next = () => dialogs.showChoice(context, score: score);
      action = await next();
    }
    while (action == GameOverAction.share && mounted) {
      await _share(recording, score);
      if (!mounted) break;
      action = await next();
    }
    recording.dispose();
    if (!mounted) return;
    switch (action) {
      case GameOverAction.playAgain:
        _bloc.add(const GameRestarted());
      case GameOverAction.home || GameOverAction.share || GameOverAction.record:
        _goHome();
    }
  }

  Future<void> _share(ClipRecording recording, int score) async {
    final shared = await AppDialogs.instance.showClipShare(
      context,
      recording: recording,
      score: score,
    );
    if (shared) _bloc.add(const GameShared());
  }

  void _goHome() {
    _ticker.stop();
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(RoutePaths.home.name);
    }
  }
}
