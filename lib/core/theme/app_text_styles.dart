import 'package:dashink/generated/colors.gen.dart';
import 'package:dashink/generated/fonts.gen.dart';
import 'package:flutter/material.dart';

/// Tipografi token'ları (Figma: Luckiest Guy başlıklar, Baloo 2 metinler).
/// Renk verilmez; widget tarafında `.ink`, `.inkSoft` vb. ile verilir.
abstract final class AppTextStyles {
  /// Luckiest Guy (tek ağırlık).
  static TextStyle display(double size, {double? height}) => TextStyle(
    fontFamily: FontFamily.luckiestGuy,
    fontSize: size,
    height: height,
  );

  /// Baloo 2 (değişken font: ağırlık `wght` ekseniyle de verilir).
  static TextStyle body(double size, FontWeight weight, {double? height}) =>
      TextStyle(
        fontFamily: FontFamily.baloo2,
        fontSize: size,
        fontWeight: weight,
        fontVariations: [FontVariation.weight(weight.value.toDouble())],
        height: height,
      );

  /// Splash "flywork" (Cal Sans 64, satır 52, -3.2 harf aralığı).
  static const TextStyle splash = TextStyle(
    fontFamily: FontFamily.calSans,
    fontSize: 64,
    height: 52 / 64,
    letterSpacing: -3.2,
  );

  // Luckiest Guy
  static final TextStyle logo = display(64);
  static final TextStyle scoreHuge = display(104, height: 1);
  static final TextStyle scoreLarge = display(80, height: 1);
  static final TextStyle hudScore = display(64, height: 1);
  static final TextStyle screenTitle = display(44);
  static final TextStyle recordTitle = display(40, height: 1.1);
  static final TextStyle modalTitle = display(36, height: 1.11);
  static final TextStyle bubbleTitle = display(32);
  static final TextStyle tapToPlay = display(30);
  static final TextStyle buttonPrimary = display(26, height: 1.1);
  static final TextStyle cardTitle = display(26, height: 1.15);
  static final TextStyle scoreLabel = display(24, height: 1.17);
  static final TextStyle buttonSecondary = display(21, height: 1.1);
  static final TextStyle option = display(20, height: 1.2);
  static final TextStyle pedestal = display(32, height: 1.125);

  // Baloo 2
  static final TextStyle coinAmount = body(18, FontWeight.w800);
  static final TextStyle segment = body(17, FontWeight.w800);
  static final TextStyle bestLabel = body(18, FontWeight.w800);
  static final TextStyle valueBold = body(17, FontWeight.w800, height: 1.3);
  static final TextStyle rowLabel = body(16, FontWeight.w700, height: 1.375);
  static final TextStyle bodyMedium = body(16, FontWeight.w500, height: 1.375);
  static final TextStyle bodySemi = body(16, FontWeight.w600);
  static final TextStyle ghostButton = body(16, FontWeight.w700, height: 1.1);
  static final TextStyle price = body(18, FontWeight.w800);
  static final TextStyle labelBold = body(15, FontWeight.w700, height: 1.33);
  static final TextStyle labelHeavy = body(15, FontWeight.w800, height: 1.33);
  static final TextStyle meta = body(14, FontWeight.w700);
  static final TextStyle caption = body(13, FontWeight.w600, height: 1.38);
  static final TextStyle captionHeavy = body(13, FontWeight.w800, height: 1.38);
  static final TextStyle tab = body(12, FontWeight.w700);
  static final TextStyle badge = body(12, FontWeight.w800);
  static final TextStyle tiny = body(11, FontWeight.w800, height: 1.27);
  static final TextStyle stat = body(20, FontWeight.w800, height: 1.3);
}

extension AppTextColors on TextStyle {
  TextStyle get ink => copyWith(color: ColorName.ink);
  TextStyle get inkSoft => copyWith(color: ColorName.inkSoft);
  TextStyle get tomato => copyWith(color: ColorName.tomato);
  TextStyle get white => copyWith(color: ColorName.white);
}
