import 'dart:convert';

import 'package:dashink/core/managers/shared_pref_manager.dart';
import 'package:dashink/core/network/network_exception.dart';
import 'package:dashink/core/network/network_manager.dart';
import 'package:dashink/core/utils/enum/request_type.dart';
import 'package:dashink/data/model/shop/shop_catalog.dart';

/// Mağaza kataloğu: `GET /shop/catalog`. Altınla alma / kuşanma
/// `PlayerRepository`, premium `PurchaseRepository`.
///
/// Son başarılı cevap cihazda saklanır: mağaza onunla anında açılır, ama
/// katalog HER açılışta ağdan tazelenir (yeni öğe / fiyat değişikliği hemen
/// görünsün; eskiden 24 saat önbellekte kalıyordu). Ağ yoksa önbellek döner.
class ShopRepository {
  ShopRepository(this._networkManager, [this._cache]);

  /// Katalog şekli değişince sürüm artırılır, eski önbellek yok sayılır.
  /// v6: 24 saatlik önbellek döneminde yazılmış eski kataloglar atılır.
  static const String _cacheName = 'shop_catalog_v6';

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

  /// Ağdan tazeler; olmazsa önbellek (yoksa hata).
  Future<ShopCatalog> catalog() async {
    try {
      return await fetchCatalog();
    } on Exception {
      final cached = cachedCatalog;
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
