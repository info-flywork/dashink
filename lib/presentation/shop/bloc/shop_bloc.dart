import 'dart:async';

import 'package:dashink/core/sound/sound_manager.dart';
import 'package:dashink/data/model/player/player_progress.dart';
import 'package:dashink/data/model/shop/shop_catalog.dart';
import 'package:dashink/domain/player/player_exceptions.dart';
import 'package:dashink/domain/player/player_repository.dart';
import 'package:dashink/domain/purchase/purchase_repository.dart';
import 'package:dashink/domain/shop/shop_repository.dart';
import 'package:dashink/presentation/shop/bloc/shop_event.dart';
import 'package:dashink/presentation/shop/bloc/shop_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Mağaza: katalog + oyuncunun sahip olduğu / kuşandığı öğeler. Satın alma
/// ve kuşanma sonucunu [ShopActionDone] / [ShopActionFailed] ile bildirir;
/// diyalogları mixin gösterir.
class ShopBloc extends Bloc<ShopEvent, ShopState> {
  ShopBloc(
    this._shopRepository,
    this._playerRepository,
    this._purchaseRepository,
    this._soundManager,
  ) : super(const ShopLoading()) {
    on<ShopStarted>(_onStarted);
    on<ShopCategoryChanged>(_onCategoryChanged);
    on<ShopBuyRequested>(_onBuy);
    on<ShopEquipRequested>(_onEquip);
    on<ShopPremiumRequested>(_onPremium);
    on<ShopCoinPackRequested>(_onCoinPack);
    on<ShopProgressChanged>(_onProgressChanged);
    _subscription = _playerRepository.changes.listen(
      (p) => add(ShopProgressChanged(p)),
    );
  }

  final ShopRepository _shopRepository;
  final PlayerRepository _playerRepository;
  final PurchaseRepository _purchaseRepository;
  final SoundManager _soundManager;
  late final StreamSubscription<PlayerProgress> _subscription;

  ShopCatalog _catalog = const ShopCatalog();
  ShopCategory _category = ShopCategory.ball;
  String? _premiumPrice;
  Map<String, String> _coinPackPrices = const {};
  Map<String, int> _coinPackBonus = const {};
  bool _pricesLoading = false;

  ShopLoaded _loaded() => ShopLoaded(
    catalog: _catalog,
    progress: _playerRepository.progress,
    category: _category,
    premiumPrice: _premiumPrice,
    coinPackPrices: _coinPackPrices,
    coinPackBonus: _coinPackBonus,
    pricesLoading: _pricesLoading,
  );

  /// Mağaza önbellekteki katalog ve fiyatlarla ANINDA açılır; katalog ve
  /// store fiyatları arka planda paralel tazelenir (tek RevenueCat çağrısı).
  Future<void> _onStarted(ShopStarted event, Emitter<ShopState> emit) async {
    final cached = _shopRepository.cachedCatalog;
    _applyPrices(_purchaseRepository.cachedPrices);
    if (cached != null) {
      _catalog = cached;
      _pricesLoading = _missingPrices(cached);
      emit(_loaded());
    } else {
      emit(const ShopLoading());
    }
    final early = cached == null ? null : _fetchPrices(cached);
    try {
      _catalog = await _shopRepository.catalog();
    } on Exception catch (e) {
      if (cached == null) return emit(ShopError(e));
    }
    _pricesLoading = _missingPrices(_catalog);
    emit(_loaded());
    final sameProducts =
        cached != null &&
        listEquals(_productIds(cached), _productIds(_catalog));
    final prices = early != null && sameProducts
        ? await early
        : await _fetchPrices(_catalog);
    _applyPrices(prices);
    _pricesLoading = false;
    emit(_loaded());
  }

  /// Fiyatı sorulacak ürünler: coin paketleri + (coin ile alınamayan premium
  /// öğe varsa) premium ürünü. Store'da olmayan ürünü sormak yavaşlatır.
  List<String> _productIds(ShopCatalog catalog) => [
    for (final p in catalog.coinPacks) p.productId,
    if (catalog.premium case final offer?
        when catalog.items.any(
          (i) => i.unlock == ShopUnlock.premium && !i.isCoinBuyable,
        ))
      offer.productId,
  ];

  bool _missingPrices(ShopCatalog catalog) =>
      catalog.coinPacks.any((p) => !_coinPackPrices.containsKey(p.productId));

  Future<Map<String, StorePrice>> _fetchPrices(ShopCatalog catalog) =>
      _purchaseRepository.fetchPrices(
        _productIds(catalog),
        mockCoins: {for (final p in catalog.coinPacks) p.productId: p.coins},
      );

  /// Gelen fiyatları uygular; boş cevap (ağ/store hatası) eldekileri silmez.
  void _applyPrices(Map<String, StorePrice> prices) {
    if (prices.isEmpty) return;
    _coinPackPrices = {
      ..._coinPackPrices,
      for (final e in prices.entries) e.key: e.value.text,
    };
    _premiumPrice = prices[_catalog.premium?.productId]?.text ?? _premiumPrice;
    _coinPackBonus = coinPackBonuses(_catalog.coinPacks, prices);
  }

  void _onCategoryChanged(ShopCategoryChanged event, Emitter<ShopState> emit) {
    _category = event.category;
    if (state is ShopLoaded) emit(_loaded());
  }

  void _onProgressChanged(ShopProgressChanged event, Emitter<ShopState> emit) {
    if (state is ShopLoaded) emit(_loaded());
  }

  Future<void> _onBuy(ShopBuyRequested event, Emitter<ShopState> emit) async {
    try {
      await _playerRepository.buyItem(event.item);
      _soundManager.play(GameSound.purchase);
      emit(_done(ShopAction.bought, item: event.item));
    } on InsufficientCoinsException {
      emit(_failed(ShopFailure.notEnoughCoins, item: event.item));
    } on ItemLockedException {
      emit(_failed(ShopFailure.locked, item: event.item));
    } on Exception catch (e) {
      emit(_failed(ShopFailure.error, item: event.item, error: e));
    }
  }

  Future<void> _onEquip(
    ShopEquipRequested event,
    Emitter<ShopState> emit,
  ) async {
    try {
      await _playerRepository.equip(event.item);
      _soundManager
        ..play(GameSound.tap)
        ..haptic();
      emit(_done(ShopAction.equipped, item: event.item));
    } on Exception catch (e) {
      emit(_failed(ShopFailure.error, item: event.item, error: e));
    }
  }

  Future<void> _onPremium(
    ShopPremiumRequested event,
    Emitter<ShopState> emit,
  ) async {
    final offer = _catalog.premium ?? const PremiumOffer();
    try {
      final result = await _purchaseRepository.buyPremium(offer);
      switch (result) {
        case PremiumPurchaseResult.completed:
          _soundManager.play(GameSound.record);
          emit(_done(ShopAction.premium, item: event.item));
        case PremiumPurchaseResult.pending:
          emit(_done(ShopAction.premiumPending, item: event.item));
        case PremiumPurchaseResult.cancelled:
          emit(_failed(ShopFailure.cancelled, item: event.item));
        case PremiumPurchaseResult.failed:
          emit(_failed(ShopFailure.error, item: event.item));
      }
    } on Exception catch (e) {
      emit(_failed(ShopFailure.error, item: event.item, error: e));
    }
  }

  Future<void> _onCoinPack(
    ShopCoinPackRequested event,
    Emitter<ShopState> emit,
  ) async {
    try {
      final (:result, :creditedCoins) = await _purchaseRepository.buyCoinPack(
        event.pack,
      );
      switch (result) {
        case PremiumPurchaseResult.completed when creditedCoins > 0:
          _soundManager.play(GameSound.purchase);
          emit(
            _done(
              ShopAction.coins,
              pack: event.pack,
              creditedCoins: creditedCoins,
            ),
          );
        case PremiumPurchaseResult.completed:
          emit(_done(ShopAction.coinsProcessing, pack: event.pack));
        case PremiumPurchaseResult.pending:
          emit(_done(ShopAction.coinsPending, pack: event.pack));
        case PremiumPurchaseResult.cancelled:
          emit(_failed(ShopFailure.cancelled, pack: event.pack));
        case PremiumPurchaseResult.failed:
          emit(_failed(ShopFailure.error, pack: event.pack));
      }
    } on Exception catch (e) {
      emit(_failed(ShopFailure.error, pack: event.pack, error: e));
    }
  }

  ShopActionDone _done(
    ShopAction action, {
    ShopItem? item,
    CoinPack? pack,
    int creditedCoins = 0,
  }) => ShopActionDone(
    catalog: _catalog,
    progress: _playerRepository.progress,
    category: _category,
    premiumPrice: _premiumPrice,
    coinPackPrices: _coinPackPrices,
    coinPackBonus: _coinPackBonus,
    action: action,
    item: item,
    pack: pack,
    creditedCoins: creditedCoins,
  );

  ShopActionFailed _failed(
    ShopFailure failure, {
    ShopItem? item,
    CoinPack? pack,
    Object? error,
  }) => ShopActionFailed(
    catalog: _catalog,
    progress: _playerRepository.progress,
    category: _category,
    premiumPrice: _premiumPrice,
    coinPackPrices: _coinPackPrices,
    coinPackBonus: _coinPackBonus,
    failure: failure,
    item: item,
    pack: pack,
    error: error,
  );

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
