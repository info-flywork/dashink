// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_catalog.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShopItem _$ShopItemFromJson(Map<String, dynamic> json) => ShopItem(
  id: json['id'] as String,
  category: $enumDecodeNullable(
    _$ShopCategoryEnumMap,
    json['category'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
  price: (json['price'] as num?)?.toInt() ?? 0,
  unlock: $enumDecodeNullable(
    _$ShopUnlockEnumMap,
    json['unlock'],
    unknownValue: JsonKey.nullForUndefinedEnumValue,
  ),
  taskId: json['task_id'] as String?,
  color: json['color'] as String?,
);

Map<String, dynamic> _$ShopItemToJson(ShopItem instance) => <String, dynamic>{
  'id': instance.id,
  'category': _$ShopCategoryEnumMap[instance.category],
  'price': instance.price,
  'unlock': _$ShopUnlockEnumMap[instance.unlock],
  'task_id': instance.taskId,
  'color': instance.color,
};

const _$ShopCategoryEnumMap = {
  ShopCategory.ball: 'ball',
  ShopCategory.ink: 'ink',
  ShopCategory.theme: 'theme',
};

const _$ShopUnlockEnumMap = {
  ShopUnlock.byDefault: 'default',
  ShopUnlock.coins: 'coins',
  ShopUnlock.task: 'task',
  ShopUnlock.premium: 'premium',
};

PremiumOffer _$PremiumOfferFromJson(Map<String, dynamic> json) => PremiumOffer(
  productId: json['product_id'] as String? ?? 'dashink_premium',
  entitlement: json['entitlement'] as String? ?? 'premium',
  bonusCoins: (json['bonus_coins'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PremiumOfferToJson(PremiumOffer instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'entitlement': instance.entitlement,
      'bonus_coins': instance.bonusCoins,
    };

CoinPack _$CoinPackFromJson(Map<String, dynamic> json) => CoinPack(
  productId: json['product_id'] as String,
  coins: (json['coins'] as num).toInt(),
);

Map<String, dynamic> _$CoinPackToJson(CoinPack instance) => <String, dynamic>{
  'product_id': instance.productId,
  'coins': instance.coins,
};

ShopCatalog _$ShopCatalogFromJson(Map<String, dynamic> json) => ShopCatalog(
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => ShopItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  premium: json['premium'] == null
      ? null
      : PremiumOffer.fromJson(json['premium'] as Map<String, dynamic>),
  coinPacks:
      (json['coin_packs'] as List<dynamic>?)
          ?.map((e) => CoinPack.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ShopCatalogToJson(ShopCatalog instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'premium': instance.premium?.toJson(),
      'coin_packs': instance.coinPacks.map((e) => e.toJson()).toList(),
    };
