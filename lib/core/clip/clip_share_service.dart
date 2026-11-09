import 'dart:io';

import 'package:dashink/core/di/injection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

enum GallerySaveResult { saved, denied, failed }

/// Sistem paylaşım sayfası, galeri ve Bunny CDN yükleme.
class ClipShareService {
  /// MP4'ü backend üzerinden Bunny CDN'e yükler; public URL döner.
  /// Başarısızsa `null` (yerel paylaşım devam eder).
  Future<String?> uploadToCdn(String filePath) async {
    if (!filePath.toLowerCase().endsWith('.mp4')) return null;
    final file = File(filePath);
    if (!file.existsSync()) return null;
    try {
      final bytes = await file.readAsBytes();
      final res = await getIt<Dio>().post<Map<String, dynamic>>(
        '/clips',
        data: bytes,
        options: Options(
          contentType: 'video/mp4',
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 30),
          responseType: ResponseType.json,
          headers: {'Content-Type': 'video/mp4'},
        ),
      );
      final data = res.data?['data'];
      if (data is Map<String, dynamic>) {
        final url = data['url'];
        if (url is String && url.isNotEmpty) return url;
      }
      return null;
    } on Object {
      return null;
    }
  }

  /// Klip dosyası (mp4/gif) + lokalize metin. İkisi birden gider.
  Future<bool> share({
    required String text,
    String? filePath,
    Rect? sharePositionOrigin,
  }) async {
    final files = <XFile>[];
    if (filePath != null && File(filePath).existsSync()) {
      files.add(
        XFile(
          filePath,
          mimeType: _mimeFor(filePath),
          name: filePath.split(Platform.pathSeparator).last,
        ),
      );
    }
    final result = await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: text,
        files: files.isEmpty ? null : files,
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
    return result.status != ShareResultStatus.dismissed;
  }

  /// Galeri izni: varsa hemen true; yoksa sistem izin penceresini açar.
  /// Albüm kullanılmaz: iOS'ta yalnızca "fotoğraf ekleme" izni istenir
  /// (albüm, tüm arşive tam erişim ister). Android 11+ izinsiz kaydeder;
  /// 10 ve altında WRITE_EXTERNAL_STORAGE istenir (manifest'te tanımlı).
  Future<bool> ensureGalleryAccess() async {
    try {
      if (await Gal.hasAccess()) return true;
      return await Gal.requestAccess();
    } on GalException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// İzin [ensureGalleryAccess] ile önceden alınmış olmalı.
  Future<GallerySaveResult> saveToGallery(String filePath) async {
    try {
      if (!await Gal.hasAccess()) {
        return GallerySaveResult.denied;
      }
      if (filePath.toLowerCase().endsWith('.mp4')) {
        await Gal.putVideo(filePath);
      } else {
        await Gal.putImage(filePath);
      }
      return GallerySaveResult.saved;
    } on GalException catch (e) {
      return e.type == GalExceptionType.accessDenied
          ? GallerySaveResult.denied
          : GallerySaveResult.failed;
    }
  }

  static String _mimeFor(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.mp4')) return 'video/mp4';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.png')) return 'image/png';
    return 'application/octet-stream';
  }
}
