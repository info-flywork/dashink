import 'dart:convert';

import 'package:dashink/core/managers/shared_pref_manager.dart';
import 'package:dashink/core/utils/constants/string_constants.dart';
import 'package:dashink/data/model/shop/shop_catalog.dart';
import 'package:dashink/domain/player/player_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Premium / coin pack satın alma sonucu.
enum PremiumPurchaseResult { completed, cancelled, pending, failed }

/// Coin paketi satın alma sonucu. [creditedCoins]: sunucu eşitlemesinden
/// sonra bakiyeye yansıyan coin. `completed` iken 0 ise ödeme alınmıştır ama
/// coin henüz yüklenmemiştir (webhook kısa süre içinde yükler).
typedef CoinPackPurchase = ({PremiumPurchaseResult result, int creditedCoins});

/// Store fiyatı: gösterilecek metin (`priceString`) ve sayısal tutar.
typedef StorePrice = ({String text, double amount});

/// Paket başına "daha avantajlı" yüzdesi: en düşük birim değerli pakete göre
/// para başına kaç % fazla altın verdiği (ör. 1200 → 20). Fiyatı bilinmeyen
/// veya avantajı %5'ten az olan paket haritada olmaz.
Map<String, int> coinPackBonuses(
  List<CoinPack> packs,
  Map<String, StorePrice> prices,
) {
  final rates = <String, double>{
    for (final p in packs)
      if (prices[p.productId] case (:final amount, text: _) when amount > 0)
        p.productId: p.coins / amount,
  };
  if (rates.length < 2) return const {};
  final base = rates.values.reduce((a, b) => a < b ? a : b);
  return {
    for (final e in rates.entries)
      if (((e.value / base - 1) * 100).round() case final pct when pct >= 5)
        e.key: pct,
  };
}

/// Uygulama içi satın alma (RevenueCat). Premium (non-consumable) ve coin
/// paketleri (consumable). Krediyi istemci değil sunucu verir
/// (`PlayerRepository.syncPurchases` + RevenueCat webhook).
class PurchaseRepository {
  PurchaseRepository(
    this._playerRepository, {
    String? apiKey,
    this._cache,
  }) : _apiKey = apiKey ?? _platformKey;

  final PlayerRepository _playerRepository;
  final SharedPrefManager? _cache;
  final String _apiKey;
  bool _configured = false;

  static String get _platformKey => defaultTargetPlatform == TargetPlatform.iOS
      ? StringConstants.revenueCatAppleKey
      : StringConstants.revenueCatGoogleKey;

  bool get isEnabled => _apiKey.isNotEmpty;

  /// Mock modunda coin paketi fiyatları (coin → fiyat).
  static const Map<int, StorePrice> _mockPackPrices = {
    500: (text: r'$0.99', amount: 0.99),
    1200: (text: r'$1.99', amount: 1.99),
    3000: (text: r'$3.99', amount: 3.99),
  };
  static const StorePrice _mockPrice = (text: r'$2.99', amount: 2.99);

  /// Store fiyatları nadiren değişir: mağaza cihazdaki son fiyatlarla anında
  /// açılır, arka planda tazelenir.
  static const String _priceCacheName = 'store_prices_v1';

  /// RevenueCat'i [appUserId] (backend kullanıcı id'si) ile başlatır.
  Future<void> configure({String? appUserId}) async {
    if (!isEnabled) return;
    if (_configured) {
      if (appUserId != null) await Purchases.logIn(appUserId);
      return;
    }
    final configuration = PurchasesConfiguration(_apiKey)
      ..appUserID = appUserId;
    await Purchases.configure(configuration);
    _configured = true;
  }

  /// Cihazdaki son store fiyatları (`product_id` → fiyat); yoksa boş.
  Map<String, StorePrice> get cachedPrices {
    if (!isEnabled) return const {};
    final entry = _cache?.readCache(_priceCacheName);
    if (entry == null) return const {};
    try {
      final json = jsonDecode(entry.json) as Map<String, dynamic>;
      return json.map((id, v) {
        final m = v as Map<String, dynamic>;
        return MapEntry(id, (
          text: m['text'] as String,
          amount: (m['amount'] as num).toDouble(),
        ));
      });
    } on Object {
      return const {};
    }
  }

  /// Ürünlerin yerelleştirilmiş store fiyatları, TEK RevenueCat çağrısıyla.
  /// Bulunamayan ürün haritada olmaz. Sonuç önbelleğe yazılır.
  Future<Map<String, StorePrice>> fetchPrices(
    List<String> productIds, {
    Map<String, int> mockCoins = const {},
  }) async {
    if (productIds.isEmpty) return const {};
    if (!isEnabled) {
      return {
        for (final id in productIds)
          id: _mockPackPrices[mockCoins[id]] ?? _mockPrice,
      };
    }
    try {
      final products = await Purchases.getProducts(
        productIds,
        productCategory: ProductCategory.nonSubscription,
      );
      final prices = {
        for (final p in products)
          p.identifier: (text: p.priceString, amount: p.price),
      };
      if (prices.isNotEmpty) {
        final merged = {...cachedPrices, ...prices};
        await _cache?.writeCache(
          _priceCacheName,
          jsonEncode({
            for (final e in merged.entries)
              e.key: {'text': e.value.text, 'amount': e.value.amount},
          }),
        );
      }
      return prices;
    } on PlatformException catch (e) {
      debugPrint('PurchaseRepository: fiyatlar alınamadı: $e');
      return const {};
    }
  }

  Future<PremiumPurchaseResult> buyPremium(PremiumOffer offer) async {
    if (!isEnabled) {
      if (_playerRepository.isRemote) return PremiumPurchaseResult.failed;
      await Future<void>.delayed(const Duration(milliseconds: 700));
      await _playerRepository.grantPremiumLocal(offer.bonusCoins);
      return PremiumPurchaseResult.completed;
    }
    try {
      final products = await Purchases.getProducts(
        [offer.productId],
        productCategory: ProductCategory.nonSubscription,
      );
      if (products.isEmpty) return PremiumPurchaseResult.failed;
      await Purchases.purchase(PurchaseParams.storeProduct(products.first));
    } on PlatformException catch (e) {
      return switch (PurchasesErrorHelper.getErrorCode(e)) {
        PurchasesErrorCode.purchaseCancelledError =>
          PremiumPurchaseResult.cancelled,
        PurchasesErrorCode.paymentPendingError => PremiumPurchaseResult.pending,
        _ => PremiumPurchaseResult.failed,
      };
    }
    await _syncQuietly();
    return PremiumPurchaseResult.completed;
  }

  Future<CoinPackPurchase> buyCoinPack(CoinPack pack) async {
    if (!isEnabled) {
      // Backend'e bağlıyken coin'i yalnızca sunucu yükler; RevenueCat
      // anahtarı olmadan gerçek satın alma yapılamaz -> başarı gösterme.
      if (_playerRepository.isRemote) {
        return (result: PremiumPurchaseResult.failed, creditedCoins: 0);
      }
      await Future<void>.delayed(const Duration(milliseconds: 700));
      await _playerRepository.grantCoinsLocal(pack.coins);
      return (
        result: PremiumPurchaseResult.completed,
        creditedCoins: pack.coins,
      );
    }
    final coinsBefore = _playerRepository.progress.coins;
    try {
      final products = await Purchases.getProducts(
        [pack.productId],
        productCategory: ProductCategory.nonSubscription,
      );
      if (products.isEmpty) {
        return (result: PremiumPurchaseResult.failed, creditedCoins: 0);
      }
      await Purchases.purchase(PurchaseParams.storeProduct(products.first));
    } on PlatformException catch (e) {
      final result = switch (PurchasesErrorHelper.getErrorCode(e)) {
        PurchasesErrorCode.purchaseCancelledError =>
          PremiumPurchaseResult.cancelled,
        PurchasesErrorCode.paymentPendingError => PremiumPurchaseResult.pending,
        _ => PremiumPurchaseResult.failed,
      };
      return (result: result, creditedCoins: 0);
    }
    await _syncQuietly();
    // Webhook sync'ten önce yüklediyse de fark bakiyeye yansımıştır.
    final credited = _playerRepository.progress.coins - coinsBefore;
    return (
      result: PremiumPurchaseResult.completed,
      creditedCoins: credited > 0 ? credited : 0,
    );
  }

  /// "Satın alımları geri yükle". Premium açıksa true.
  Future<bool> restore() async {
    if (!isEnabled) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return _playerRepository.progress.premium;
    }
    await Purchases.restorePurchases();
    final progress = await _playerRepository.syncPurchases();
    return progress.premium;
  }

  /// Store'da tamamlanan satın almada sunucu eşitlemesi başarısız olsa da
  /// hata gösterilmez: webhook krediyi yine verir.
  Future<void> _syncQuietly() async {
    try {
      await _playerRepository.syncPurchases();
    } on Exception catch (e) {
      debugPrint('PurchaseRepository: eşitleme sonra yapılacak: $e');
    }
  }
}
