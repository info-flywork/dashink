import 'package:dashink/core/managers/auth_cache_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Bearer token ekler. Token yoksa (ör. açılışta ağ yoktu ya da iOS yerel
/// ağ izni sorulurken ilk istek düştü) önce [ensureSession] ile anonim
/// oturumu açar; eşzamanlı istekler aynı girişi bekler.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._authCacheManager, {this.ensureSession});

  final AuthCacheManager _authCacheManager;

  /// `AuthRepository.ensureSession` (döngüsel bağımlılık olmasın diye geç
  /// çözülen bir callback).
  final Future<void> Function()? ensureSession;

  Future<void>? _pending;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    var token = await _authCacheManager.getAccessToken();
    final restore = ensureSession;
    if ((token == null || token.isEmpty) &&
        restore != null &&
        !options.path.startsWith('/auth')) {
      try {
        await (_pending ??= restore().whenComplete(() => _pending = null));
      } on Object catch (e) {
        debugPrint('AuthInterceptor: oturum açılamadı: $e');
      }
      token = await _authCacheManager.getAccessToken();
    }
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
