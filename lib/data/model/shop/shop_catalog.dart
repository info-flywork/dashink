import 'package:dashink/core/base/model/base_model.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'shop_catalog.g.dart';

enum ShopCategory { ball, ink, theme }

/// Öğenin nasıl açıldığı.
enum ShopUnlock {
  @JsonValue('default')
  byDefault,
  coins,
  task,
  premium,
}

/// Mağaza öğesi. Ad/açıklama istemcide [id] ile yerelleştirilir.
@JsonSerializable()
class ShopItem extends Equatable {
  const ShopItem({
    required this.id,
    this.category,
    this.price = 0,
    this.unlock,
    this.taskId,
    this.color,
  });

  factory ShopItem.fromJson(Map<String, dynamic> json) =>
      _$ShopItemFromJson(json);

  final String id;
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  final ShopCategory? category;
  final int price;
  @JsonKey(unknownEnumValue: JsonKey.nullForUndefinedEnumValue)
  final ShopUnlock? unlock;
  final String? taskId;

  /// Mürekkep/tema rengi (`#RRGGBB`).
  final String? color;

  /// Altınla alınabilir mi: coin öğeleri ve fiyatı olan premium öğeler
  /// (premium öğeler 3000 altın; premium satın alınmışsa zaten açıktır).
  bool get isCoinBuyable =>
      unlock == ShopUnlock.coins || (unlock == ShopUnlock.premium && price > 0);

  Map<String, dynamic> toJson() => _$ShopItemToJson(this);

  @override
  List<Object?> get props => [id, category, price, unlock, taskId, color];
}

/// RevenueCat premium teklifi.
@JsonSerializable()
class PremiumOffer extends Equatable {
  const PremiumOffer({
    this.productId = 'dashink_premium',
    this.entitlement = 'premium',
    this.bonusCoins = 0,
  });

  factory PremiumOffer.fromJson(Map<String, dynamic> json) =>
      _$PremiumOfferFromJson(json);

  final String productId;
  final String entitlement;
  final int bonusCoins;

  Map<String, dynamic> toJson() => _$PremiumOfferToJson(this);

  @override
  List<Object?> get props => [productId, entitlement, bonusCoins];
}

/// RevenueCat consumable coin paketi.
@JsonSerializable()
class CoinPack extends Equatable {
  const CoinPack({required this.productId, required this.coins});

  factory CoinPack.fromJson(Map<String, dynamic> json) =>
      _$CoinPackFromJson(json);

  final String productId;
  final int coins;

  Map<String, dynamic> toJson() => _$CoinPackToJson(this);

  @override
  List<Object?> get props => [productId, coins];
}

/// `GET /shop/catalog`.
@JsonSerializable()
class ShopCatalog extends Equatable implements BaseModel<ShopCatalog> {
  const ShopCatalog({
    this.items = const [],
    this.premium,
    this.coinPacks = const [],
  });

  factory ShopCatalog.fromJson(Map<String, dynamic> json) =>
      _$ShopCatalogFromJson(json);

  final List<ShopItem> items;
  final PremiumOffer? premium;
  final List<CoinPack> coinPacks;

  List<ShopItem> byCategory(ShopCategory category) => [
    for (final item in items)
      if (item.category == category) item,
  ];

  ShopItem? find(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  ShopCatalog fromJson(Map<String, dynamic> json) => ShopCatalog.fromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ShopCatalogToJson(this);

  @override
  List<Object?> get props => [items, premium, coinPacks];
}
