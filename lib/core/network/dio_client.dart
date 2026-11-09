import 'package:dashink/core/managers/auth_cache_manager.dart';
import 'package:dashink/core/network/interceptors/auth_interceptor.dart';
import 'package:dashink/core/network/interceptors/expired_token_interceptor.dart';
import 'package:dashink/core/network/interceptors/language_interceptor.dart';
import 'package:dashink/core/network/interceptors/mock_interceptor.dart';
import 'package:dashink/core/utils/constants/string_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract final class DioClient {
  static BaseOptions get _options => BaseOptions(
    baseUrl: StringConstants.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  );

  static Dio create({
    required AuthCacheManager authCacheManager,
    Future<void> Function()? ensureSession,
  }) {
    final dio = Dio(_options);

    if (StringConstants.useMock) {
      dio.interceptors.add(
        MockInterceptor(scenario: StringConstants.mockScenario),
      );
      return dio;
    }

    dio.interceptors.addAll([
      LanguageInterceptor(),
      AuthInterceptor(authCacheManager, ensureSession: ensureSession),
      ExpiredTokenInterceptor(authCacheManager, Dio(_options)),
      if (kDebugMode) LogInterceptor(requestBody: true),
    ]);
    return dio;
  }
}
