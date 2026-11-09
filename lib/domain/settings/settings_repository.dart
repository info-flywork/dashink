import 'package:dashink/core/managers/notification_manager.dart';
import 'package:dashink/core/managers/shared_pref_manager.dart';
import 'package:dashink/core/sound/sound_manager.dart';

/// Cihaz tercihleri: ses efektleri, müzik, titreşim, bildirimler.
class SettingsRepository {
  SettingsRepository(this._prefs, this._sound, this._notifications);

  final SharedPrefManager _prefs;
  final SoundManager _sound;
  final NotificationManager _notifications;

  bool get isSfxEnabled => _prefs.isSfxEnabled;
  bool get isMusicEnabled => _prefs.isMusicEnabled;
  bool get isVibrationEnabled => _prefs.isVibrationEnabled;
  bool get isNotificationsEnabled => _prefs.isNotificationsEnabled;

  Future<void> setSfxEnabled({required bool enabled}) =>
      _prefs.setSfxEnabled(enabled: enabled);

  Future<void> setMusicEnabled({required bool enabled}) async {
    await _prefs.setMusicEnabled(enabled: enabled);
    await _sound.syncMusic();
  }

  Future<void> setVibrationEnabled({required bool enabled}) async {
    await _prefs.setVibrationEnabled(enabled: enabled);
    _sound.haptic(heavy: true);
  }

  /// Açarken izin ister; izin verilmezse kapalı kalır ve false döner.
  Future<bool> setNotificationsEnabled({
    required bool enabled,
    required String title,
    required String body,
  }) async {
    if (!enabled) {
      await _notifications.disableDaily();
      await _prefs.setNotificationsEnabled(enabled: false);
      return true;
    }
    final ok = await _notifications.enableDaily(title: title, body: body);
    await _prefs.setNotificationsEnabled(enabled: ok);
    return ok;
  }
}
