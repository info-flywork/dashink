/// Boşluk token'ları (Figma auto-layout gap/padding değerleri).
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double s = 12;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Köşe yarıçapı token'ları.
abstract final class AppRadius {
  static const double s = 12;
  static const double m = 16;
  static const double l = 20;
  static const double xl = 24;
  static const double modal = 28;
  static const double pill = 999;
}

/// Kenarlık kalınlıkları (Figma: 2.5px ink çizgi).
abstract final class AppStroke {
  static const double regular = 2.5;
  static const double divider = 1.5;
}
