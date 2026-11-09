import 'dart:async';

import 'package:dashink/core/dialogs/app_dialogs.dart';
import 'package:dashink/core/dialogs/widgets/shop_dialogs.dart';
import 'package:dashink/core/router/route_paths.dart';
import 'package:dashink/core/snackbar/app_snackbar.dart';
import 'package:dashink/core/theme/app_spacing.dart';
import 'package:dashink/core/theme/app_text_styles.dart';
import 'package:dashink/core/utils/enum/snackbar_type.dart';
import 'package:dashink/core/utils/error_messages.dart';
import 'package:dashink/core/utils/extensions/bloc_extensions.dart';
import 'package:dashink/core/utils/extensions/future_extensions.dart';
import 'package:dashink/core/utils/extensions/number_extensions.dart';
import 'package:dashink/core/utils/item_assets.dart';
import 'package:dashink/core/widgets/app_coin_pill.dart';
import 'package:dashink/core/widgets/app_decorations.dart';
import 'package:dashink/core/widgets/app_error_view.dart';
import 'package:dashink/core/widgets/app_item_art.dart';
import 'package:dashink/core/widgets/app_loading.dart';
import 'package:dashink/core/widgets/app_motion.dart';
import 'package:dashink/core/widgets/app_screen_header.dart';
import 'package:dashink/core/widgets/app_segmented.dart';
import 'package:dashink/data/model/player/player_progress.dart';
import 'package:dashink/data/model/shop/shop_catalog.dart';
import 'package:dashink/generated/assets.gen.dart';
import 'package:dashink/generated/colors.gen.dart';
import 'package:dashink/generated/locale_keys.g.dart';
import 'package:dashink/presentation/shop/bloc/shop_bloc.dart';
import 'package:dashink/presentation/shop/bloc/shop_event.dart';
import 'package:dashink/presentation/shop/bloc/shop_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'mixin/shop_view_mixin.dart';
part 'widgets/shop_card.dart';

/// Figma `magaza`.
class ShopView extends StatefulWidget {
  const ShopView({super.key});

  @override
  State<ShopView> createState() => _ShopViewState();
}

class _ShopViewState extends State<ShopView> with ShopViewMixin {
  @override
  Widget build(BuildContext context) {
    return AppPaperBackground(
      child: SafeArea(
        bottom: false,
        child: BlocBuilder<ShopBloc, ShopState>(
          builder: (context, state) => Column(
            children: [
              AppScreenHeader(
                title: LocaleKeys.shop_title.tr(),
                trailing: state is ShopLoaded
                    ? AppCoinPill(amount: state.progress.coins)
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: AppSegmented(
                  labels: [
                    LocaleKeys.shop_balls.tr(),
                    LocaleKeys.shop_inks.tr(),
                    LocaleKeys.shop_themes.tr(),
                  ],
                  selectedIndex: state is ShopLoaded ? state.category.index : 0,
                  onChanged: onCategoryChanged,
                ),
              ),
              Expanded(
                child: switch (state) {
                  ShopLoading() => const AppLoading(),
                  ShopError(:final error) => AppErrorView(
                    message: ErrorMessages.of(error),
                    onRetry: onRetry,
                  ),
                  final ShopLoaded loaded => _ShopGrid(
                    key: ValueKey(loaded.category),
                    state: loaded,
                    onItemTapped: (item) => onItemTapped(loaded, item),
                  ),
                },
              ),
              if (state is ShopLoaded && state.catalog.coinPacks.isNotEmpty)
                _CoinPackRow(
                  state: state,
                  onPackTapped: (pack) => onCoinPackTapped(state, pack),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mağaza kartlarının giriş animasyonu (genel 460 ms yerine kısa).
const Duration _shopEntrance = Duration(milliseconds: 240);

class _CoinPackRow extends StatelessWidget {
  const _CoinPackRow({required this.state, required this.onPackTapped});

  final ShopLoaded state;
  final ValueChanged<CoinPack> onPackTapped;

  @override
  Widget build(BuildContext context) {
    final packs = state.catalog.coinPacks;
    // Navbar'ın üst çizgisiyle aynı ayraç + yukarı doğru yumuşak gölge:
    // öğeler kayarken paketlerin altından geçtiği belli olsun.
    final row = Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: ColorName.ink, width: AppStroke.regular),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        children: [
          for (var i = 0; i < packs.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: AppEntrance(
                duration: _shopEntrance,
                child: _CoinPackCard(
                  pack: packs[i],
                  // Küçükten büyüğe: 1, 2 (yan yana), 3 (piramit) altın.
                  tier: i,
                  price: state.coinPackPrices[packs[i].productId],
                  bonusPercent: state.coinPackBonus[packs[i].productId],
                  loading: state.pricesLoading,
                  onTap: () => onPackTapped(packs[i]),
                ),
              ),
            ),
          ],
        ],
      ),
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Gölge çizginin üstüne taşar; yer kaplamaz, dokunmayı engellemez.
        Positioned(
          left: 0,
          right: 0,
          top: -14,
          height: 14,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    ColorName.ink.withValues(alpha: 0.16),
                    ColorName.ink.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
        row,
      ],
    );
  }
}

/// "+%20" / "+20%": yüzde biçimi dile göre.
String _bonusLabel(BuildContext context, int percent) {
  final format = NumberFormat.percentPattern(context.locale.toString());
  return '+${format.format(percent / 100)}';
}

/// RevenueCat coin paketi: coin, miktar, store fiyatı (`priceString`) ve
/// büyük paketlerde "+%20" gibi avantaj rozeti.
class _CoinPackCard extends StatelessWidget {
  const _CoinPackCard({
    required this.pack,
    required this.price,
    required this.onTap,
    this.tier = 0,
    this.bonusPercent,
    this.loading = false,
  });

  final CoinPack pack;

  /// Paket sırası (0 = en küçük); görseldeki altın sayısı `tier + 1`.
  final int tier;
  final String? price;

  /// En küçük pakete göre para başına fazladan altın (%); yoksa rozet yok.
  final int? bonusPercent;

  /// Fiyat henüz store'dan gelmedi.
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final price = this.price;
    final hasPrice = price != null && price.isNotEmpty;
    final bonus = bonusPercent;
    final waiting = !hasPrice && loading;
    return Semantics(
      button: true,
      label: '+${pack.coins}${hasPrice ? ', $price' : ''}',
      child: GestureDetector(
        onTap: waiting ? null : onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(6, 10, 6, 8),
              decoration: AppDecorations.card(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CoinStack(count: tier + 1),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '+${pack.coins.grouped(context)}',
                      style: AppTextStyles.price.ink,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: hasPrice ? ColorName.tomato : ColorName.paperLine,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        hasPrice
                            ? price
                            : waiting
                            ? '···'
                            : LocaleKeys.shop_premium_unavailable.tr(),
                        style: hasPrice
                            ? AppTextStyles.price.white
                            : AppTextStyles.price.inkSoft,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (bonus != null)
              Positioned(
                top: -9,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: ColorName.mint,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: AppDecorations.border,
                  ),
                  child: Text(
                    _bonusLabel(context, bonus),
                    style: AppTextStyles.badge.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Paket görseli: 1 altın; 2 altın yan yana, kısmen üst üste; 3 altın
/// piramit (alttaki ikisinin üstünde bir tane). Yükseklik sabit, kartlar
/// aynı boyda kalır.
class _CoinStack extends StatelessWidget {
  const _CoinStack({required this.count});

  final int count;

  static const double _height = 46;
  static const double _big = 34;
  static const double _small = 30;

  @override
  Widget build(BuildContext context) {
    Widget coin(double size) =>
        Assets.images.coin.image(width: size, height: size);
    return SizedBox(
      width: 64,
      height: _height,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: switch (count) {
          1 => [
            Positioned(
              bottom: (_height - _big) / 2,
              child: coin(_big),
            ),
          ],
          2 => [
            Positioned(left: 8, bottom: 4, child: coin(_small)),
            Positioned(right: 8, bottom: 4, child: coin(_small)),
          ],
          _ => [
            Positioned(left: 6, bottom: 0, child: coin(_small)),
            Positioned(right: 6, bottom: 0, child: coin(_small)),
            Positioned(top: 0, child: coin(_small)),
          ],
        },
      ),
    );
  }
}

class _ShopGrid extends StatelessWidget {
  const _ShopGrid({
    required this.state,
    required this.onItemTapped,
    super.key,
  });

  final ShopLoaded state;
  final ValueChanged<ShopItem> onItemTapped;

  @override
  Widget build(BuildContext context) {
    final items = state.visibleItems;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 13,
        crossAxisSpacing: 13,
        mainAxisExtent: 160,
      ),
      itemCount: items.length,
      // Satır satır kısa giriş: mağaza ve kategori değişimi anında hissedilsin.
      itemBuilder: (context, i) => AppEntrance(
        index: i ~/ 3,
        duration: _shopEntrance,
        child: ShopCard(
          item: items[i],
          progress: state.progress,
          onTap: () => onItemTapped(items[i]),
        ),
      ),
    );
  }
}
