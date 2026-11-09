import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:dashink/core/managers/shared_pref_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Ses efektleri (`assets/sounds/`, scripts/generate_sounds.py).
enum GameSound {
  tap('tap'),
  coin('coin'),
  draw('draw'),
  fall('fall'),
  record('record'),
  purchase('purchase');

  const GameSound(this.file);

  final String file;
}

/// Ayarlardaki "Ses efektleri", "Müzik" ve "Titreşim" tercihlerine uyarak
/// efektleri, müzik döngüsünü ve dokunsal geri bildirimi yönetir. iOS'ta
/// sessiz moda saygı duyar (ambient kategori).
class SoundManager {
  SoundManager(this._prefs);

  final SharedPrefManager _prefs;
  final Map<GameSound, AudioPool> _pools = {};
  AudioPlayer? _music;
  Future<void>? _loading;

  /// Splash'te bir kez çağrılır; hata olursa oyun sessiz devam eder.
  Future<void> preload() => _loading ??= _load();

  Future<void> _load() async {
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContextConfig(respectSilence: true).build(),
      );
      for (final sound in GameSound.values) {
        _pools[sound] = await AudioPool.createFromAsset(
          path: 'sounds/${sound.file}.wav',
          maxPlayers: sound == GameSound.coin ? 4 : 2,
        );
      }
    } on Object catch (e) {
      debugPrint('SoundManager: sesler yüklenemedi: $e');
    }
  }

  void play(GameSound sound, {double volume = 0.7}) {
    if (!_prefs.isSfxEnabled) return;
    final pool = _pools[sound];
    if (pool == null) return;
    unawaited(pool.start(volume: volume).then((_) {}, onError: (_) {}));
  }

  /// Hafif dokunsal geri bildirim (Titreşim açıksa).
  void haptic({bool heavy = false}) {
    if (!_prefs.isVibrationEnabled) return;
    unawaited(
      heavy ? HapticFeedback.heavyImpact() : HapticFeedback.selectionClick(),
    );
  }

  /// Müzik açıksa döngüyü başlatır; kapalıysa durdurur.
  Future<void> syncMusic() async {
    try {
      if (!_prefs.isMusicEnabled) {
        await _music?.pause();
        return;
      }
      final player = _music ??= AudioPlayer();
      if (player.state == PlayerState.playing) return;
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setVolume(0.35);
      await player.play(AssetSource('sounds/music.wav'));
    } on Object catch (e) {
      debugPrint('SoundManager: müzik çalınamadı: $e');
    }
  }

  /// Uygulama arka plana geçince müziği durdurur.
  Future<void> pauseMusic() async {
    try {
      await _music?.pause();
    } on Object {
      // yut
    }
  }
}
