import 'dart:ui';

import 'package:dashink/core/managers/shared_pref_manager.dart';
import 'package:dio/dio.dart';

/// API'ye seçilen uygulama dilini gönderir (cihaz dili değil).
class LanguageInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.headers['Accept-Language'] = _languageCode();
    handler.next(options);
  }

  static String _languageCode() {
    try {
      final saved = SharedPrefManager.instance.localeCode;
      if (saved != null && saved.isNotEmpty) return saved;
    } on Object {
      // SharedPref henüz hazır değilse platform diline düş.
    }
    return PlatformDispatcher.instance.locale.languageCode;
  }
}
