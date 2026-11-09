import 'package:dashink/core/theme/app_spacing.dart';
import 'package:dashink/core/theme/app_text_styles.dart';
import 'package:dashink/core/widgets/app_button.dart';
import 'package:dashink/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Yükleme hatası: mesaj + "Tekrar dene".
class AppErrorView extends StatelessWidget {
  const AppErrorView({required this.message, required this.onRetry, super.key});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.inkSoft,
            ),
            const SizedBox(height: AppSpacing.m),
            AppButton(
              label: LocaleKeys.common_retry.tr(),
              type: AppButtonType.secondary,
              expand: false,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
