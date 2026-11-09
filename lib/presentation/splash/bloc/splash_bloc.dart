import 'dart:async';

import 'package:dashink/core/sound/sound_manager.dart';
import 'package:dashink/domain/auth/auth_repository.dart';
import 'package:dashink/domain/player/player_repository.dart';
import 'package:dashink/domain/purchase/purchase_repository.dart';
import 'package:dashink/presentation/splash/bloc/splash_event.dart';
import 'package:dashink/presentation/splash/bloc/splash_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Açılış: sesler, anonim oturum, RevenueCat ve oyuncu ilerlemesi.
/// Ağ yoksa oyun cihazdaki son ilerlemeyle açılır (bekletmez).
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc(
    this._authRepository,
    this._playerRepository,
    this._purchaseRepository,
    this._soundManager, {
    this.minDuration = const Duration(milliseconds: 1900),
  }) : super(const SplashLoading()) {
    on<SplashStarted>(_onStarted);
  }

  final AuthRepository _authRepository;
  final PlayerRepository _playerRepository;
  final PurchaseRepository _purchaseRepository;
  final SoundManager _soundManager;

  /// Daktilo animasyonunun bitmesi için en kısa bekleme (Figma: 2 sn).
  final Duration minDuration;

  Future<void> _onStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    final minimum = Future<void>.delayed(minDuration);
    await Future.wait([
      _soundManager.preload(),
      _prepareSession().timeout(
        const Duration(seconds: 5),
        onTimeout: () => debugPrint('SplashBloc: oturum zaman aşımı'),
      ),
    ]);
    await minimum;
    unawaited(_soundManager.syncMusic());
    emit(SplashReady(showTutorial: !_playerRepository.isTutorialSeen));
  }

  Future<void> _prepareSession() async {
    try {
      final user = await _authRepository.ensureSession();
      await _purchaseRepository.configure(appUserId: user?.id);
      await _playerRepository.refresh();
    } on Object catch (e) {
      debugPrint('SplashBloc: çevrimdışı açılış: $e');
    }
  }
}
