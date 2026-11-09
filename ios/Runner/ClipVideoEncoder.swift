import AVFoundation
import Flutter
import UIKit

/// PNG karelerinden H.264 MP4 üretir (paylaşım / galeri).
enum ClipVideoEncoder {
  static func encode(
    imagePaths: [String],
    fps: Int,
    outputPath: String,
    completion: @escaping (String?) -> Void
  ) {
    DispatchQueue.global(qos: .userInitiated).async {
      let result = encodeSync(
        imagePaths: imagePaths,
        fps: max(fps, 1),
        outputPath: outputPath
      )
      DispatchQueue.main.async { completion(result) }
    }
  }

  private static func encodeSync(
    imagePaths: [String],
    fps: Int,
    outputPath: String
  ) -> String? {
    guard let firstPath = imagePaths.first,
          let first = UIImage(contentsOfFile: firstPath),
          let cgFirst = first.cgImage
    else { return nil }

    // H.264 çift boyut ister.
    let width = max(2, cgFirst.width - cgFirst.width % 2)
    let height = max(2, cgFirst.height - cgFirst.height % 2)
    let outputURL = URL(fileURLWithPath: outputPath)
    try? FileManager.default.removeItem(at: outputURL)

    guard let writer = try? AVAssetWriter(outputURL: outputURL, fileType: .mp4)
    else { return nil }

    let settings: [String: Any] = [
      AVVideoCodecKey: AVVideoCodecType.h264,
      AVVideoWidthKey: width,
      AVVideoHeightKey: height,
      AVVideoCompressionPropertiesKey: [
        AVVideoAverageBitRateKey: width * height * 4,
        AVVideoProfileLevelKey: AVVideoProfileLevelH264BaselineAutoLevel,
      ],
    ]
    let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
    input.expectsMediaDataInRealTime = false

    let attrs: [String: Any] = [
      kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
      kCVPixelBufferWidthKey as String: width,
      kCVPixelBufferHeightKey as String: height,
    ]
    let adaptor = AVAssetWriterInputPixelBufferAdaptor(
      assetWriterInput: input,
      sourcePixelBufferAttributes: attrs
    )

    guard writer.canAdd(input) else { return nil }
    writer.add(input)
    guard writer.startWriting() else { return nil }
    writer.startSession(atSourceTime: .zero)

    let frameDuration = CMTime(value: 1, timescale: CMTimeScale(fps))
    var frameIndex = 0

    for path in imagePaths {
      guard let image = UIImage(contentsOfFile: path)?.cgImage else { continue }
      while !input.isReadyForMoreMediaData {
        Thread.sleep(forTimeInterval: 0.01)
      }
      guard let buffer = pixelBuffer(from: image, width: width, height: height)
      else { continue }
      let time = CMTimeMultiply(frameDuration, multiplier: Int32(frameIndex))
      if !adaptor.append(buffer, withPresentationTime: time) {
        return nil
      }
      frameIndex += 1
    }

    guard frameIndex > 0 else { return nil }

    let finished = DispatchSemaphore(value: 0)
    input.markAsFinished()
    writer.endSession(
      atSourceTime: CMTimeMultiply(frameDuration, multiplier: Int32(frameIndex))
    )
    writer.finishWriting { finished.signal() }
    finished.wait()

    return writer.status == .completed ? outputPath : nil
  }

  private static func pixelBuffer(
    from image: CGImage,
    width: Int,
    height: Int
  ) -> CVPixelBuffer? {
    var buffer: CVPixelBuffer?
    let status = CVPixelBufferCreate(
      kCFAllocatorDefault,
      width,
      height,
      kCVPixelFormatType_32ARGB,
      [
        kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
        kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!,
      ] as CFDictionary,
      &buffer
    )
    guard status == kCVReturnSuccess, let pixelBuffer = buffer else { return nil }

    CVPixelBufferLockBaseAddress(pixelBuffer, [])
    defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }

    guard let context = CGContext(
      data: CVPixelBufferGetBaseAddress(pixelBuffer),
      width: width,
      height: height,
      bitsPerComponent: 8,
      bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
      space: CGColorSpaceCreateDeviceRGB(),
      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
    ) else { return nil }

    context.interpolationQuality = .high
    context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
    return pixelBuffer
  }
}

final class ClipVideoEncoderPlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.flywork.dashink/clip",
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(ClipVideoEncoderPlugin(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "encodeMp4",
          let args = call.arguments as? [String: Any],
          let paths = args["paths"] as? [String],
          let fps = args["fps"] as? Int,
          let outputPath = args["outputPath"] as? String,
          !paths.isEmpty
    else {
      result(FlutterError(code: "bad_args", message: nil, details: nil))
      return
    }

    ClipVideoEncoder.encode(
      imagePaths: paths,
      fps: fps,
      outputPath: outputPath
    ) { path in
      result(path)
    }
  }
}
