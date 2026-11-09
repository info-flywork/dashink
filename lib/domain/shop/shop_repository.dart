import 'dart:convert';

import 'package:dashink/core/managers/shared_pref_manager.dart';
import 'package:dashink/core/network/network_exception.dart';
import 'package:dashink/core/network/network_manager.dart';
import 'package:dashink/core/utils/enum/request_type.dart';
import 'package:dashink/data/model/shop/shop_catalog.dart';

/// Mağaza kataloğu: `GET /shop/catalog`. Altınla alma / kuşanma
/// `PlayerRepository`, premium `PurchaseRepository`.
///
/// Katalog nadiren değişir: son başarılı cevap cihazda saklanır, mağaza
/// onunla anında açılır; ağdan yalnızca önbellek [cacheTtl]'den eskiyse
/// tazelenir.
class ShopRepository {
  ShopRepository(this._networkManager, [this._cache]);

  static const Duration cacheTtl = Duration(hours: 24);

  /// Katalog değişince sürüm artırılır (v5: 22 yeni top / mürekkep / tema),
  /// eski önbellek yok sayılır.
  static const String _cacheName = 'shop_catalog_v5';

  final NetworkManager _networkManager;
  final SharedPrefManager? _cache;

  ShopCatalog? get cachedCatalog {
    final entry = _cache?.readCache(_cacheName);
    if (entry == null) return null;
    try {
      return ShopCatalog.fromJson(
        jsonDecode(entry.json) as Map<String, dynamic>,
      );
    } on Object {
      return null;
    }
  }

  bool get isCatalogFresh {
    final savedAt = _cache?.readCache(_cacheName)?.savedAt;
    return savedAt != null && DateTime.now().difference(savedAt) < cacheTtl;
  }

  /// Önbellek tazeyse onu, değilse ağdan çekip önbelleğe yazar.
  Future<ShopCatalog> catalog() async {
    final cached = cachedCatalog;
    if (cached != null && isCatalogFresh) return cached;
    try {
      return await fetchCatalog();
    } on Exception {
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<ShopCatalog> fetchCatalog() async {
    final result = await _networkManager.send<ShopCatalog>(
      path: '/shop/catalog',
      method: RequestType.get,
      parserModel: ShopCatalog.fromJson,
    );
    if (result == null) throw NetworkException.emptyResponse();
    if (result.items.isNotEmpty) {
      await _cache?.writeCache(_cacheName, jsonEncode(result.toJson()));
    }
    return result;
  }
}
