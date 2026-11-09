part of '../shop_view.dart';

mixin ShopViewMixin on State<ShopView> {
  ShopBloc get _bloc => context.read<ShopBloc>();

  void onRetry() => _bloc.add(const ShopStarted());

  void onCategoryChanged(int index) =>
      _bloc.add(ShopCategoryChanged(ShopCategory.values[index]));

  /// Kart durumuna göre: kuşanılı -> yok; sahip -> kuşan; altınla alınabilir
  /// (coin ve 3000 altınlık premium öğeler) -> satın al (veya altın yetersiz);
  /// görev -> kilit; fiyatsız premium -> premium teklifi.
  Future<void> onItemTapped(ShopLoaded state, ShopItem item) async {
    final progress = state.progress;
    if (progress.isEquipped(item.id)) return;
    if (progress.owns(item.id)) {
      return _run(ShopEquipRequested(item));
    }
    if (item.isCoinBuyable) {
      if (progress.coins < item.price) {
        return _notEnough(state, item, progress.coins);
      }
      final confirmed = await AppDialogs.instance.showBuyConfirm(
        context,
        item: item,
        coins: progress.coins,
      );
      if (confirmed && mounted) await _run(ShopBuyRequested(item));
      return;
    }
    switch (item.unlock) {
      case ShopUnlock.task:
        final go = await AppDialogs.instance.showItemLocked(
          context,
          item: item,
        );
        if (go && mounted) context.goNamed(RoutePaths.tasks.name);
      case ShopUnlock.premium:
        final buy = await AppDialogs.instance.showPremium(
          context,
          item: item,
          offer: state.catalog.premium ?? const PremiumOffer(),
          price: state.premiumPrice,
        );
        if (buy && mounted) await _run(ShopPremiumRequested(item));
      // coins: yukarıda isCoinBuyable ile ele alındı.
      case ShopUnlock.coins || ShopUnlock.byDefault || null:
        return _run(ShopEquipRequested(item));
    }
  }

  Future<void> onCoinPackTapped(ShopLoaded state, CoinPack pack) async {
    final price = state.coinPackPrices[pack.productId];
    if (price == null || price.isEmpty) {
      AppSnackbar.show(
        context: context,
        text: LocaleKeys.shop_premium_unavailable.tr(),
        type: SnackBarType.failure,
      );
      return;
    }
    await _run(ShopCoinPackRequested(pack));
  }

  Future<void> _notEnough(ShopLoaded state, ShopItem item, int coins) async {
    final offer = _coinPackOffer(state, item.price - coins);
    final choice = await AppDialogs.instance.showNotEnoughCoins(
      context,
      item: item,
      coins: coins,
      offer: offer,
    );
    if (!mounted) return;
    switch (choice) {
      case NotEnoughCoinsChoice.buyCoins when offer != null:
        await _run(ShopCoinPackRequested(offer.pack));
      case NotEnoughCoinsChoice.tasks:
        context.goNamed(RoutePaths.tasks.name);
      case _:
        break;
    }
  }

  /// Eksik altını karşılayan en küçük fiyatlı paket; hiçbiri yetmiyorsa en
  /// büyüğü. Store fiyatı alınamadıysa öneri yok (yalnız görev seçeneği).
  CoinPackOffer? _coinPackOffer(ShopLoaded state, int missing) {
    final priced = [
      for (final pack in state.catalog.coinPacks)
        if (state.coinPackPrices[pack.productId] case final price?
            when price.isNotEmpty)
          (pack: pack, price: price),
    ]..sort((a, b) => a.pack.coins.compareTo(b.pack.coins));
    if (priced.isEmpty) return null;
    return priced.firstWhere(
      (o) => o.pack.coins >= missing,
      orElse: () => priced.last,
    );
  }

  /// Çift dokunuş tek işlem sayılır: yükleme diyaloğu ekranı kilitler.
  Future<void> _run(ShopEvent event) async {
    final state = await _bloc
        .addAndWait(
          event,
          until: (s) => s is ShopActionDone || s is ShopActionFailed,
        )
        .withLoading(context);
    if (!mounted) return;
    switch (state) {
      case ShopActionDone(action: ShopAction.premium):
        AppSnackbar.show(
          context: context,
          text: LocaleKeys.shop_purchase_success.tr(),
          type: SnackBarType.success,
        );
      case ShopActionDone(action: ShopAction.premiumPending):
      case ShopActionDone(action: ShopAction.coinsPending):
        AppSnackbar.show(
          context: context,
          text: LocaleKeys.shop_purchase_pending.tr(),
          type: SnackBarType.info,
        );
      case ShopActionDone(action: ShopAction.coins, :final creditedCoins):
        AppSnackbar.show(
          context: context,
          text: LocaleKeys.shop_coins_pack_success.tr(
            args: ['$creditedCoins'],
          ),
          type: SnackBarType.success,
        );
      case ShopActionDone(action: ShopAction.coinsProcessing):
        AppSnackbar.show(
          context: context,
          text: LocaleKeys.shop_coins_pack_processing.tr(),
          type: SnackBarType.info,
        );
      case ShopActionDone(:final item):
        if (item == null) break;
        AppSnackbar.show(
          context: context,
          text: LocaleKeys.shop_equipped_toast.tr(
            args: [ItemAssets.name(item.id)],
          ),
          type: SnackBarType.success,
        );
      case ShopActionFailed(failure: ShopFailure.cancelled):
        break;
      case ShopActionFailed(failure: ShopFailure.notEnoughCoins, :final item):
        if (item == null) break;
        await _notEnough(state, item, state.progress.coins);
      case ShopActionFailed(:final item, :final pack, :final error):
        final isIap =
            pack != null ||
            (item?.unlock == ShopUnlock.premium && !item!.isCoinBuyable);
        AppSnackbar.show(
          context: context,
          text: isIap && error == null
              ? LocaleKeys.shop_purchase_failed.tr()
              : ErrorMessages.of(error),
          type: SnackBarType.failure,
        );
      case _:
        break;
    }
  }
}
