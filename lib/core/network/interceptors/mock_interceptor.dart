import 'dart:convert';

import 'package:dashink/core/network/mock/mock_routes.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

/// Front-end modunda tüm istekleri `assets/mock/` JSON'larından cevaplar.
/// Repository + NetworkManager + model kodu gerçek kalır; yalnızca cevap
/// kaynağı sahtedir.
class MockInterceptor extends Interceptor {
  MockInterceptor({
    required this.scenario,
    this.delay = const Duration(milliseconds: 400),
    AssetBundle? bundle,
  }) : _bundle = bundle ?? rootBundle;

  final String scenario;
  final Duration delay;
  final AssetBundle _bundle;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await Future<void>.delayed(delay);
    final period = options.queryParameters['period'];
    final key =
        '${options.method.toUpperCase()} ${options.path}'
        '${period == null ? '' : '?period=$period'}';
    final file = resolveRoute(key);

    if (file == null) {
      return handler.reject(
        DioException(
          requestOptions: options,
          message: 'Mock route not found: $key',
        ),
      );
    }

    if (scenario == 'error') {
      return handler.resolve(
        Response<Map<String, dynamic>>(
          requestOptions: options,
          statusCode: 200,
          data: {'status': 'error', 'message': 'Mock error', 'data': null},
        ),
      );
    }

    final raw = await _load(file);
    handler.resolve(
      Response<Map<String, dynamic>>(
        requestOptions: options,
        statusCode: 200,
        data: jsonDecode(raw) as Map<String, dynamic>,
      ),
    );
  }

  /// [key]'e karşılık gelen dosya; `{n}` kalıplı rotaları da çözer.
  static String? resolveRoute(String key) {
    final exact = mockRoutes[key];
    if (exact != null) return exact;
    for (final MapEntry(key: pattern, value: file) in mockRoutes.entries) {
      if (!pattern.contains('{n}')) continue;
      final regex = RegExp(
        '^${RegExp.escape(pattern).replaceAll(r'\{n\}', r'(\d+)')}\$',
      );
      final match = regex.firstMatch(key);
      if (match != null) return file.replaceAll('{n}', match.group(1)!);
    }
    return null;
  }

  Future<String> _load(String file) async {
    if (scenario == 'empty') {
      final emptyFile = file.replaceFirst('.json', '.empty.json');
      final manifest = await AssetManifest.loadFromAssetBundle(_bundle);
      if (manifest.listAssets().contains(emptyFile)) {
        return _bundle.loadString(emptyFile);
      }
    }
    return _bundle.loadString(file);
  }
}
