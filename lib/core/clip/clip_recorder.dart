import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Son [maxSeconds] saniyenin küçük kareleri (klip önizleme / paylaşım).
class ClipRecording {
  ClipRecording(this.frames, {required this.fps});

  static const _channel = MethodChannel('com.flywork.dashink/clip');

  final List<ui.Image> frames;
  final int fps;

  bool get isEmpty => frames.isEmpty;

  int get seconds => (frames.length / fps).ceil();

  void dispose() {
    for (final frame in frames) {
      frame.dispose();
    }
    frames.clear();
  }

  /// Paylaşım / galeri için medya dosyası: mümkünse MP4, değilse GIF.
  Future<String> exportForShare() async {
    final mp4 = await exportMp4();
    if (mp4 != null) return mp4;
    return exportGif();
  }

  /// Kareleri H.264 MP4'e çevirir (iOS native). Başarısızsa `null`.
  Future<String?> exportMp4() async {
    if (frames.isEmpty) return null;
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final framesDir = Directory('${dir.path}/dashink_frames_$stamp')
      ..createSync(recursive: true);
    final paths = <String>[];
    try {
      for (var i = 0; i < frames.length; i++) {
        final data = await frames[i].toByteData(
          format: ui.ImageByteFormat.png,
        );
        if (data == null) continue;
        final path =
            '${framesDir.path}/frame_${i.toString().padLeft(4, '0')}.png';
        await File(path).writeAsBytes(data.buffer.asUint8List(), flush: true);
        paths.add(path);
      }
      if (paths.isEmpty) return null;
      final output = '${dir.path}/dashink_$stamp.mp4';
      final result = await _channel.invokeMethod<String>('encodeMp4', {
        'paths': paths,
        'fps': fps,
        'outputPath': output,
      });
      if (result == null || !File(result).existsSync()) return null;
      return result;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    } finally {
      if (framesDir.existsSync()) {
        framesDir.deleteSync(recursive: true);
      }
    }
  }

  /// Kareleri animasyonlu GIF'e çevirir (ayrı isolate) ve geçici dosyaya
  /// yazar. Dosya yolunu döndürür.
  Future<String> exportGif() async {
    final raw = <_RawFrame>[];
    for (final frame in frames) {
      final data = await frame.toByteData();
      if (data == null) continue;
      raw.add(
        _RawFrame(
          frame.width,
          frame.height,
          TransferableTypedData.fromList([data.buffer.asUint8List()]),
        ),
      );
    }
    final bytes = await compute(
      _encodeGif,
      _GifJob(raw, (100 / fps).round()),
    );
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/dashink_${DateTime.now().millisecondsSinceEpoch}.gif',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}

class _RawFrame {
  const _RawFrame(this.width, this.height, this.bytes);

  final int width;
  final int height;
  final TransferableTypedData bytes;
}

class _GifJob {
  const _GifJob(this.frames, this.delayCentis);

  final List<_RawFrame> frames;
  final int delayCentis;
}

Uint8List _encodeGif(_GifJob job) {
  final encoder = img.GifEncoder(samplingFactor: 20);
  for (final f in job.frames) {
    final frame = img.Image.fromBytes(
      width: f.width,
      height: f.height,
      bytes: f.bytes.materialize(),
      numChannels: 4,
      order: img.ChannelOrder.rgba,
    )..frameDuration = job.delayCentis;
    encoder.addFrame(frame, duration: job.delayCentis);
  }
  return encoder.finish() ?? Uint8List(0);
}

/// Oyun alanının (RepaintBoundary) karelerini yakalar; yalnızca son
/// [maxSeconds] saniye tutulur. 8 fps / 200 px kasmalı görünüyordu; 20 fps /
/// 360 px daha akıcı MP4 verir, bellek de makul kalır.
class ClipRecorder {
  ClipRecorder({this.fps = 20, this.maxSeconds = 5, this.targetWidth = 360});

  final int fps;
  final int maxSeconds;
  final double targetWidth;

  final List<ui.Image> _frames = [];
  Timer? _timer;
  bool _capturing = false;

  void start(GlobalKey boundaryKey) {
    stop();
    _clear();
    _timer = Timer.periodic(
      Duration(milliseconds: 1000 ~/ fps),
      (_) => unawaited(_capture(boundaryKey)),
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Kayıt durur; kareler sahibine (önizleme / dışa aktarma) geçer.
  ClipRecording take() {
    stop();
    final recording = ClipRecording(List.of(_frames), fps: fps);
    _frames.clear();
    return recording;
  }

  Future<void> _capture(GlobalKey key) async {
    if (_capturing) return;
    final boundary = key.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary || boundary.debugNeedsPaint) {
      return;
    }
    _capturing = true;
    try {
      final ratio = targetWidth / boundary.size.width;
      final image = await boundary.toImage(pixelRatio: ratio);
      if (_timer == null) {
        image.dispose();
        return;
      }
      _frames.add(image);
      while (_frames.length > fps * maxSeconds) {
        _frames.removeAt(0).dispose();
      }
    } on Object catch (e) {
      debugPrint('ClipRecorder: kare alınamadı: $e');
    } finally {
      _capturing = false;
    }
  }

  void _clear() {
    for (final frame in _frames) {
      frame.dispose();
    }
    _frames.clear();
  }

  void dispose() {
    stop();
    _clear();
  }
}
