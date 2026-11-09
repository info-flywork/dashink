import 'package:dashink/core/theme/app_text_styles.dart';
import 'package:dashink/core/widgets/app_button.dart';
import 'package:dashink/core/widgets/app_decorations.dart';
import 'package:dashink/generated/assets.gen.dart';
import 'package:dashink/generated/colors.gen.dart';
import 'package:dashink/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Figma `Header`: büyük Luckiest Guy başlık + sağda öğe (altın / kapat).
class AppScreenHeader extends StatelessWidget {
  const AppScreenHeader({required this.title, this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: AppTextStyles.screenTitle.ink,
                  maxLines: 1,
                ),
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Başlıktaki kapat (X) butonu.
class AppCloseButton extends StatelessWidget {
  const AppCloseButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppIconButton(
    icon: AppSvgIcon(Assets.icons.close, size: 26, color: ColorName.ink),
    onTap: onTap,
    semanticLabel: LocaleKeys.common_close.tr(),
  );
}
