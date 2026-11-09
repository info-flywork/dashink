import 'package:dashink/core/theme/app_spacing.dart';
import 'package:dashink/core/theme/app_text_styles.dart';
import 'package:dashink/core/widgets/app_decorations.dart';
import 'package:dashink/generated/assets.gen.dart';
import 'package:dashink/generated/colors.gen.dart';
import 'package:dashink/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Figma `TabBar`: Oyna / Mağaza / Görevler / Ayarlar.
class AppTabBar extends StatelessWidget {
  const AppTabBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Kabuktaki sekme çubuğunun konumu; `AppSnackbar` mesajı bunun hemen
  /// üstüne yerleştirir.
  static final GlobalKey anchorKey = GlobalKey(debugLabel: 'AppTabBar');

  /// Sekme çubuğunun ekrandaki üst kenarı (yoksa null).
  static double? topOnScreen() {
    final box = anchorKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero).dy;
  }

  @override
  Widget build(BuildContext context) {
    // go_router kabuğu dil değişiminde kendiliğinden rebuild olmayabilir;
    // InheritedWidget bağımlılığı etiketleri anında günceller.
    final _ = context.locale;
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    final tabs = [
      (Assets.icons.tabPlay, LocaleKeys.tabs_play.tr()),
      (Assets.icons.tabShoppingBag, LocaleKeys.tabs_shop.tr()),
      (Assets.icons.tabListChecks, LocaleKeys.tabs_tasks.tr()),
      (Assets.icons.tabSettings, LocaleKeys.tabs_settings.tr()),
    ];
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, bottom > 0 ? bottom - 10 : 12),
      decoration: const BoxDecoration(
        color: ColorName.paperCard,
        border: Border(
          top: BorderSide(color: ColorName.ink, width: AppStroke.regular),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: _TabItem(
                icon: tabs[i].$1,
                label: tabs[i].$2,
                selected: i == currentIndex,
                onTap: () => onTap(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final SvgGenImage icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? ColorName.tomato : ColorName.inkSoft;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? ColorName.tomatoTint : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.s),
              ),
              child: AppSvgIcon(icon, color: color),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.tab.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
