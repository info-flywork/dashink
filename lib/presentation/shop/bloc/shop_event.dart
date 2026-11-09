import 'package:dashink/data/model/player/player_progress.dart';
import 'package:dashink/data/model/shop/shop_catalog.dart';
import 'package:equatable/equatable.dart';

sealed class ShopEvent extends Equatable {
  const ShopEvent();

  @override
  List<Object?> get props => [];
}

final class ShopStarted extends ShopEvent {
  const ShopStarted();
}

final class ShopCategoryChanged extends ShopEvent {
  const ShopCategoryChanged(this.category);

  final ShopCategory category;

  @override
  List<Object?> get props => [category];
}

/// Altınla satın al ve kuşan (onaydan sonra).
final class ShopBuyRequested extends ShopEvent {
  const ShopBuyRequested(this.item);

  final ShopItem item;

  @override
  List<Object?> get props => [item];
}

final class ShopEquipRequested extends ShopEvent {
  const ShopEquipRequested(this.item);

  final ShopItem item;

  @override
  List<Object?> get props => [item];
}

/// RevenueCat ile premium (onaydan sonra).
final class ShopPremiumRequested extends ShopEvent {
  const ShopPremiumRequested(this.item);

  final ShopItem item;

  @override
  List<Object?> get props => [item];
}

/// RevenueCat ile consumable coin paketi.
final class ShopCoinPackRequested extends ShopEvent {
  const ShopCoinPackRequested(this.pack);

  final CoinPack pack;

  @override
  List<Object?> get props => [pack];
}

/// Oyuncu ilerlemesi başka yerde değişti (altın, öğe).
final class ShopProgressChanged extends ShopEvent {
  const ShopProgressChanged(this.progress);

  final PlayerProgress progress;

  @override
  List<Object?> get props => [progress];
}
