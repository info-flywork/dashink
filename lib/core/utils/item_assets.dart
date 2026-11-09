import 'package:dashink/data/model/shop/shop_catalog.dart';
import 'package:dashink/generated/assets.gen.dart';
import 'package:dashink/generated/colors.gen.dart';
import 'package:dashink/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Mağaza öğesi kimliğinden görsel / renk / ad.
abstract final class ItemAssets {
  static AssetGenImage ballImage(String id) => switch (id) {
    'ball_karpuz' => Assets.images.topKarpuz,
    'ball_gezegen' => Assets.images.topGezegen,
    'ball_goz' => Assets.images.topGoz,
    'ball_disko' => Assets.images.topDisko,
    'ball_yildiz' => Assets.images.topYildiz,
    'ball_basket' => Assets.images.topBasket,
    'ball_tenis' => Assets.images.topTenis,
    'ball_plaj' => Assets.images.topPlaj,
    'ball_ay' => Assets.images.topAy,
    'ball_bilardo' => Assets.images.topBilardo,
    'ball_buz' => Assets.images.topBuz,
    'ball_lav' => Assets.images.topLav,
    'ball_gokkusagi' => Assets.images.topGokkusagi,
    _ => Assets.images.topKlasik,
  };

  /// `#RRGGBB` -> Color; geçersizse [fallback].
  static Color parseColor(String? hex, {Color fallback = ColorName.ink}) {
    if (hex == null) return fallback;
    final value = int.tryParse(hex.replaceFirst('#', ''), radix: 16);
    return value == null ? fallback : Color(0xFF000000 | value);
  }

  static const Map<String, Color> _inkColors = {
    'ink_lacivert': ColorName.ink,
    'ink_kirmizi': ColorName.tomato,
    'ink_nane': ColorName.mint,
    'ink_mor': Color(0xFF7B4FD6),
    'ink_altin': ColorName.gold,
    'ink_turuncu': Color(0xFFFF8A1F),
    'ink_pembe': Color(0xFFF25C9A),
    'ink_mavi': Color(0xFF2F6FEB),
    'ink_turkuaz': Color(0xFF17A7B8),
    'ink_yesil': Color(0xFF3A9D23),
    'ink_kahve': Color(0xFF7A4A2A),
    'ink_bordo': Color(0xFF8E1B3A),
    'ink_gumus': Color(0xFF9AA3B5),
  };

  static const Map<String, Color> _themeColors = {
    'theme_kagit': ColorName.paper,
    'theme_nane': Color(0xFFE3F4EC),
    'theme_gunbatimi': Color(0xFFFBE3D6),
    'theme_gece': Color(0xFF2B3260),
    'theme_lavanta': Color(0xFFECE4FA),
    'theme_gokyuzu': Color(0xFFE1EEFB),
    'theme_limon': Color(0xFFFBF5D2),
    'theme_seker': Color(0xFFFBE4EE),
    'theme_orman': Color(0xFF1F3B2D),
    'theme_uzay': Color(0xFF14142B),
  };

  /// Katalog yoksa da (çevrimdışı ilk açılış) kuşanılı rengi bilir.
  static Color inkColor(String id, [ShopItem? item]) =>
      _inkColors[id] ?? parseColor(item?.color);

  static Color themeColor(String id, [ShopItem? item]) =>
      _themeColors[id] ?? parseColor(item?.color, fallback: ColorName.paper);

  /// Koyu temalar gece ızgarasıyla çizilir (kağıt dokusu yerine). Bilinmeyen
  /// (sunucudan yeni gelen) temada renk parlaklığına bakılır.
  static bool isDarkTheme(String id, [ShopItem? item]) =>
      themeColor(id, item).computeLuminance() < 0.2;

  static String name(String id) => 'items.$id.name'.tr();

  static String description(String id) => 'items.$id.desc'.tr();

  static String taskName(String id) => '${LocaleKeys.tasks_names}.$id'.tr();
}
