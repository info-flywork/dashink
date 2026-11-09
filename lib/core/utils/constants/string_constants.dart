abstract final class StringConstants {
  /// Varsayılan: canlı backend. Yerel için
  /// `--dart-define-from-file=config/local_simulator.json` (simülatör) veya
  /// `--dart-define-from-file=config/local_device.json` (fiziksel cihaz).
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://dashink.fly-work.com',
  );

  /// Front-end modu: true iken tüm istekler `MockInterceptor` tarafından
  /// `assets/mock/` altındaki JSON dosyalarından cevaplanır ve oyuncu
  /// ilerlemesi yalnızca cihazda tutulur. Açmak için
  /// `--dart-define=USE_MOCK=true`.
  static const bool useMock = bool.fromEnvironment('USE_MOCK');

  /// Mock senaryosu: `default`, `empty` veya `error`.
  static const String mockScenario = String.fromEnvironment(
    'MOCK_SCENARIO',
    defaultValue: 'default',
  );

  /// RevenueCat public SDK anahtarları (gizli değildir; store/SDK için).
  /// Secret key (`sk_`) yalnızca backend `.env` içindedir.
  static const String revenueCatAppleKey = 'appl_AhiYQdtivSGYoOnqgxTEdEDqsNX';
  static const String revenueCatGoogleKey = 'goog_yXJlbxuvaoppvWkuUhWmFBREFze';

  /// RevenueCat ürün / entitlement kimlikleri (katalogdan da gelir).
  static const String premiumProductId = 'dashink_premium';
  static const String premiumEntitlement = 'premium';

  static const String appVersion = '1.0.0';

  /// Yasal sayfalar.
  static const String legalBaseUrl = 'https://fly-work.com/dashink';
  static const String privacyPolicyUrl = '$legalBaseUrl/privacy-policy/';
  static const String termsUrl = '$legalBaseUrl/terms/';
  static const String cookiesUrl = '$legalBaseUrl/cookies/';
  static const String childSafetyUrl = '$legalBaseUrl/csae/';
  static const String aboutUrl = '$legalBaseUrl/about/';
}
