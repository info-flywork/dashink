part of '../shop_view.dart';

/// Figma `ShopCard`: Equipped (nane çerçeve + KUŞANILDI), Price, Locked
/// (Görev), Premium. Sahip olunan ama kuşanılmamış öğe "Kuşan" gösterir.
class ShopCard extends StatelessWidget {
  const ShopCard({
    required this.item,
    required this.progress,
    required this.onTap,
    super.key,
  });

  final ShopItem item;
  final PlayerProgress progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final equipped = progress.isEquipped(item.id);
    final owned = progress.owns(item.id);
    return Semantics(
      button: true,
      label: ItemAssets.name(item.id),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: AppDecorations.card(
            borderColor: equipped ? ColorName.mint : ColorName.ink,
            borderWidth: equipped ? 3 : AppStroke.regular,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(child: AppItemArt(item: item, size: 92)),
              const SizedBox(height: 8),
              _meta(context, equipped: equipped, owned: owned),
            ],
          ),
        ),
      ),
    );
  }

  Widget _meta(
    BuildContext context, {
    required bool equipped,
    required bool owned,
  }) {
    if (equipped) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: ColorName.mint,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          LocaleKeys.shop_equipped.tr(),
          style: AppTextStyles.badge.white,
        ),
      );
    }
    if (owned) {
      return Text(LocaleKeys.shop_equip.tr(), style: AppTextStyles.meta.ink);
    }
    final (Widget icon, String label) = switch (item.unlock) {
      ShopUnlock.task => (
        AppSvgIcon(Assets.icons.lock, size: 18),
        LocaleKeys.shop_task.tr(),
      ),
      // Premium öğe: taç + altın fiyatı (3000); fiyatsızsa "Premium".
      ShopUnlock.premium => (
        AppSvgIcon(Assets.icons.crown, size: 18),
        item.price > 0
            ? item.price.grouped(context)
            : LocaleKeys.shop_premium.tr(),
      ),
      _ => (
        Assets.images.coin.image(width: 20, height: 20),
        item.price.grouped(context),
      ),
    };
    final style = item.isCoinBuyable
        ? AppTextStyles.price.ink
        : AppTextStyles.meta.ink;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 4),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label, style: style),
          ),
        ),
      ],
    );
  }
}
