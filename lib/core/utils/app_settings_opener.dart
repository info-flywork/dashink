import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Uygulamanın sistem ayarları sayfasını açar (kalıcı reddedilen izinler).
/// iOS: `app-settings:`; Android: `MainActivity` içindeki kanal.
abstract final class AppSettingsOpener {
  static const MethodChannel _channel = MethodChannel('dashink/app_settings');

  static Future<bool> open() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return await _channel.invokeMethod<bool>('open') ?? false;
      }
      return await launchUrl(Uri.parse('app-settings:'));
    } on Exception {
      return false;
    }
  }
}
