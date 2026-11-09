import 'package:dashink/data/model/player/player_progress.dart';
import 'package:dashink/data/model/shop/shop_catalog.dart';
import 'package:equatable/equatable.dart';

enum ShopAction {
  bought,
  equipped,
  premium,
  premiumPending,
  coins,
  coinsPending,

  /// Ödeme alındı, coin henüz yüklenmedi (webhook birazdan yükler).
  coinsProcessing,
}

enum ShopFailure { notEnoughCoins, locked, cancelled, error }

sealed class ShopState extends Equatable {
  const ShopState();

  @override
  List<Object?> get props => [];
}

final class ShopLoading extends ShopState {
  const ShopLoading();
}

final class ShopError extends ShopState {
  const ShopError(this.error);

  final Object error;

  @override
  List<Object?> get props => [error];
}

final class ShopLoaded extends ShopState {
  const ShopLoaded({
    required this.catalog,
    required this.progress,
    this.category = ShopCategory.ball,
    this.premiumPrice,
    this.coinPackPrices = const {},
    this.coinPackBonus = const {},
    this.pricesLoading = false,
  });

  final ShopCatalog catalog;
  final PlayerProgress progress;
  final ShopCategory category;

  /// Premium store fiyatı (yoksa null).
  final String? premiumPrice;

  /// Coin paketi store fiyatları (`product_id` → metin).
  final Map<String, String> coinPackPrices;

  /// Paketin en küçük pakete göre para başına fazladan verdiği altın (%).
  final Map<String, int> coinPackBonus;

  /// Store fiyatları henüz gelmedi (kartta "fiyat yok" yerine yükleniyor).
  final bool pricesLoading;

  List<ShopItem> get visibleItems => catalog.byCategory(category);

  @override
  List<Object?> get props => [
    catalog,
    progress,
    category,
    premiumPrice,
    coinPackPrices,
    coinPackBonus,
    pricesLoading,
  ];
}

final class ShopActionDone extends ShopLoaded {
  const ShopActionDone({
    required super.catalog,
    required super.progress,
    required this.action,
    this.item,
    this.pack,
    this.creditedCoins = 0,
    super.category,
    super.premiumPrice,
    super.coinPackPrices,
    super.coinPackBonus,
  });

  final ShopAction action;
  final ShopItem? item;
  final CoinPack? pack;

  /// [ShopAction.coins]: sunucunun bakiyeye yüklediği coin.
  final int creditedCoins;

  @override
  List<Object?> get props => [
    ...super.props,
    action,
    item,
    pack,
    creditedCoins,
  ];
}

final class ShopActionFailed extends ShopLoaded {
  const ShopActionFailed({
    required super.catalog,
    required super.progress,
    required this.failure,
    this.item,
    this.pack,
    super.category,
    super.premiumPrice,
    super.coinPackPrices,
    super.coinPackBonus,
    this.error,
  });

  final ShopFailure failure;
  final ShopItem? item;
  final CoinPack? pack;
  final Object? error;

  @override
  List<Object?> get props => [...super.props, failure, item, pack, error];
}
