import 'package:dashink/core/dialogs/widgets/modal_card.dart';
import 'package:dashink/core/theme/app_text_styles.dart';
import 'package:dashink/core/utils/extensions/number_extensions.dart';
import 'package:dashink/core/utils/item_assets.dart';
import 'package:dashink/core/widgets/app_button.dart';
import 'package:dashink/core/widgets/app_coin_pill.dart';
import 'package:dashink/core/widgets/app_decorations.dart';
import 'package:dashink/core/widgets/app_item_art.dart';
import 'package:dashink/data/model/shop/shop_catalog.dart';
import 'package:dashink/generated/assets.gen.dart';
import 'package:dashink/generated/colors.gen.dart';
import 'package:dashink/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

Widget _title(String text) => FittedBox(
  fit: BoxFit.scaleDown,
  child: Text(
    text,
    textAlign: TextAlign.center,
    style: AppTextStyles.modalTitle.ink,
  ),
);

Widget _body(String text) => Text(
  text,
  textAlign: TextAlign.center,
  style: AppTextStyles.bodyMedium.inkSoft,
);

Widget _cancel(BuildContext context) => AppButton(
  label: LocaleKeys.common_cancel.tr(),
  type: AppButtonType.ghost,
  expand: false,
  onPressed: () => Navigator.of(context).pop(false),
);

/// Figma `satin-al-kusan`. Onaylanırsa `true`.
class ShopBuyDialog extends StatelessWidget {
  const ShopBuyDialog({required this.item, required this.coins, super.key});

  final ShopItem item;
  final int coins;

  @override
  Widget build(BuildContext context) {
    return ModalCard(
      children: [
        ModalHalo(child: AppItemArt(item: item, size: 136)),
        _title(ItemAssets.name(item.id)),
        _body(ItemAssets.description(item.id)),
        AppCoinPill(label: item.price.grouped(context)),
        Text(
          LocaleKeys.shop_balance_after.tr(
            namedArgs: {
              'balance': coins.grouped(context),
              'after': (coins - item.price).grouped(context),
            },
          ),
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.inkSoft,
        ),
        AppButton(
          label: LocaleKeys.shop_buy_and_equip.tr(),
          onPressed: () => Navigator.of(context).pop(true),
        ),
        _cancel(context),
      ],
    );
  }
}

/// Figma `altin-yetersiz`. "GÖREV YAP" seçilirse `true`.
/// Yetersiz altın diyaloğunda kullanıcının seçimi.
enum NotEnoughCoinsChoice { buyCoins, tasks }

/// Yetersiz altın diyaloğunda önerilen coin paketi ve store fiyatı.
typedef CoinPackOffer = ({CoinPack pack, String price});

/// Altın yetersiz. [offer] varsa "+N ALTIN · fiyat" (store fiyatı) birincil
/// buton olur ve [NotEnoughCoinsChoice.buyCoins] döner; "GÖREV YAP"
/// [NotEnoughCoinsChoice.tasks] döner.
class NotEnoughCoinsDialog extends StatelessWidget {
  const NotEnoughCoinsDialog({
    required this.item,
    required this.coins,
    this.offer,
    super.key,
  });

  final ShopItem item;
  final int coins;
  final CoinPackOffer? offer;

  @override
  Widget build(BuildContext context) {
    final missing = (item.price - coins).clamp(0, item.price);
    return ModalCard(
      children: [
        ModalHalo(
          size: 128,
          child: Assets.images.coin.image(width: 88, height: 88),
        ),
        _title(LocaleKeys.shop_not_enough_title.tr()),
        _body(
          LocaleKeys.shop_not_enough_body.tr(
            namedArgs: {
              'item': ItemAssets.name(item.id),
              'price': item.price.grouped(context),
              'missing': missing.grouped(context),
            },
          ),
        ),
        Column(
          children: [
            AppProgressBar(
              value: item.price == 0 ? 0 : coins / item.price,
              color: ColorName.gold,
              trackColor: ColorName.paper,
              height: 18,
              bordered: true,
            ),
            const SizedBox(height: 6),
            Text(
              '${coins.grouped(context)} / ${item.price.grouped(context)}',
              style: AppTextStyles.labelHeavy.ink,
            ),
          ],
        ),
        if (offer case (:final pack, :final price))
          AppButton(
            label: LocaleKeys.shop_get_coins.tr(
              namedArgs: {'coins': pack.coins.grouped(context), 'price': price},
            ),
            icon: Assets.images.coin.image(width: 26, height: 26),
            onPressed: () =>
                Navigator.of(context).pop(NotEnoughCoinsChoice.buyCoins),
          ),
        AppButton(
          label: LocaleKeys.shop_do_tasks.tr(),
          type: offer == null ? AppButtonType.primary : AppButtonType.secondary,
          icon: offer == null
              ? AppSvgIcon(Assets.icons.listChecksWhite, size: 26)
              : null,
          onPressed: () =>
              Navigator.of(context).pop(NotEnoughCoinsChoice.tasks),
        ),
        AppButton(
          label: LocaleKeys.common_cancel.tr(),
          type: AppButtonType.ghost,
          expand: false,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

/// Görevle açılan öğe (Figma'da "Görev" kartı; hedef görevler). "GÖREVLERE
/// GİT" seçilirse `true`.
class ItemLockedDialog extends StatelessWidget {
  const ItemLockedDialog({required this.item, super.key});

  final ShopItem item;

  @override
  Widget build(BuildContext context) {
    final task = item.taskId;
    return ModalCard(
      children: [
        ModalHalo(child: AppItemArt(item: item, size: 136)),
        _title(LocaleKeys.shop_locked_title.tr()),
        _body(
          LocaleKeys.shop_locked_body.tr(
            namedArgs: {
              'item': ItemAssets.name(item.id),
              'task': task == null ? '' : ItemAssets.taskName(task),
            },
          ),
        ),
        AppButton(
          label: LocaleKeys.shop_go_tasks.tr(),
          icon: AppSvgIcon(Assets.icons.listChecksWhite, size: 26),
          onPressed: () => Navigator.of(context).pop(true),
        ),
        _cancel(context),
      ],
    );
  }
}

/// Premium teklifi (Figma'da yalnızca kart var; aynı modal düzeni).
/// Satın al seçilirse `true`.
class PremiumDialog extends StatelessWidget {
  const PremiumDialog({
    required this.item,
    required this.offer,
    required this.price,
    super.key,
  });

  final ShopItem item;
  final PremiumOffer offer;

  /// Store fiyatı; alınamadıysa null (buton kapalı).
  final String? price;

  @override
  Widget build(BuildContext context) {
    final p = price;
    return ModalCard(
      children: [
        ModalHalo(child: AppItemArt(item: item, size: 136)),
        _title(LocaleKeys.shop_premium_title.tr()),
        _body(
          LocaleKeys.shop_premium_body.tr(
            args: [offer.bonusCoins.grouped(context)],
          ),
        ),
        AppButton(
          label: p == null
              ? LocaleKeys.shop_premium_unavailable.tr()
              : LocaleKeys.shop_premium_buy.tr(args: [p]),
          onPressed: p == null ? null : () => Navigator.of(context).pop(true),
        ),
        _cancel(context),
      ],
    );
  }
}
