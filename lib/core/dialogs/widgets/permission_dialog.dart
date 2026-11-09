import 'package:dashink/core/dialogs/widgets/modal_card.dart';
import 'package:dashink/core/theme/app_text_styles.dart';
import 'package:dashink/core/widgets/app_button.dart';
import 'package:dashink/core/widgets/app_decorations.dart';
import 'package:dashink/generated/assets.gen.dart';
import 'package:dashink/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Galeri izni verilmedi (veya kalıcı reddedildi): nedenini anlatır,
/// "AYARLARI AÇ" seçilirse `true`.
class GalleryPermissionDialog extends StatelessWidget {
  const GalleryPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ModalCard(
      children: [
        ModalHalo(
          size: 128,
          child: AppSvgIcon(Assets.icons.imageBtn, size: 76),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            LocaleKeys.clip_permission_title.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.modalTitle.ink,
          ),
        ),
        Text(
          LocaleKeys.clip_permission_denied.tr(),
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.inkSoft,
        ),
        AppButton(
          label: LocaleKeys.clip_open_settings.tr(),
          onPressed: () => Navigator.of(context).pop(true),
        ),
        AppButton(
          label: LocaleKeys.common_cancel.tr(),
          type: AppButtonType.ghost,
          expand: false,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}
