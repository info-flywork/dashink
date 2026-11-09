import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences singleton. `AppInit` içinde `init()` çağrılır.
final class SharedPrefManager {
  SharedPrefManager._();

  static final SharedPrefManager instance = SharedPrefManager._();

  late SharedPreferences _prefs;

  static const _tutorialSeenKey = 'tutorial_seen';
  static const _sfxEnabledKey = 'sfx_enabled';
  static const _musicEnabledKey = 'music_enabled';
  static const _vibrationEnabledKey = 'vibration_enabled';
  static const _notificationsEnabledKey = 'notifications_enabled';
  static const _progressKey = 'player_progress';
  static const _pendingEventsKey = 'pending_events';
  static const _localClaimsKey = 'local_task_claims';
  static const _cachePrefix = 'cache.';

  /// easy_localization'ın kaydettiği dil anahtarı
  static const easyLocaleKey = 'locale';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Seçili uygulama dili (API Accept-Language). Yoksa null.
  String? get localeCode {
    final raw = _prefs.getString(easyLocaleKey);
    if (raw == null || raw.isEmpty) return null;
    return raw.split(RegExp('[_-]')).first;
  }

  /// Eğitim bir kez tamamlandı/atlandı mı (ilk açılış kararı).
  bool get isTutorialSeen => _prefs.getBool(_tutorialSeenKey) ?? false;

  Future<void> setTutorialSeen() => _prefs.setBool(_tutorialSeenKey, true);

  bool get isSfxEnabled => _prefs.getBool(_sfxEnabledKey) ?? true;

  Future<void> setSfxEnabled({required bool enabled}) =>
      _prefs.setBool(_sfxEnabledKey, enabled);

  bool get isMusicEnabled => _prefs.getBool(_musicEnabledKey) ?? true;

  Future<void> setMusicEnabled({required bool enabled}) =>
      _prefs.setBool(_musicEnabledKey, enabled);

  bool get isVibrationEnabled => _prefs.getBool(_vibrationEnabledKey) ?? false;

  Future<void> setVibrationEnabled({required bool enabled}) =>
      _prefs.setBool(_vibrationEnabledKey, enabled);

  bool get isNotificationsEnabled =>
      _prefs.getBool(_notificationsEnabledKey) ?? true;

  Future<void> setNotificationsEnabled({required bool enabled}) =>
      _prefs.setBool(_notificationsEnabledKey, enabled);

  /// Son bilinen oyuncu ilerlemesi (JSON); yoksa null.
  String? get progressJson => _prefs.getString(_progressKey);

  Future<void> setProgressJson(String json) =>
      _prefs.setString(_progressKey, json);

  /// Çevrimdışıyken sunucuya gönderilemeyen oyun olayları (JSON).
  List<String> get pendingEvents =>
      _prefs.getStringList(_pendingEventsKey) ?? const [];

  Future<void> setPendingEvents(List<String> events) =>
      _prefs.setStringList(_pendingEventsKey, events);

  /// Mock modunda alınan görev ödülleri (`<görev>|<dönem>`).
  List<String> get localTaskClaims =>
      _prefs.getStringList(_localClaimsKey) ?? const [];

  Future<void> setLocalTaskClaims(List<String> claims) =>
      _prefs.setStringList(_localClaimsKey, claims);

  /// Basit JSON önbelleği: değer ve kaydedilme zamanı. Bozuk/eksikse null.
  ({String json, DateTime savedAt})? readCache(String name) {
    final json = _prefs.getString('$_cachePrefix$name');
    final savedAt = _prefs.getInt('$_cachePrefix$name.at');
    if (json == null || savedAt == null) return null;
    return (
      json: json,
      savedAt: DateTime.fromMillisecondsSinceEpoch(savedAt),
    );
  }

  Future<void> writeCache(String name, String json) async {
    await _prefs.setString('$_cachePrefix$name', json);
    await _prefs.setInt(
      '$_cachePrefix$name.at',
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}
