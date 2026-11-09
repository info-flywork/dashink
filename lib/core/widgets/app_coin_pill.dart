import 'package:dashink/core/theme/app_spacing.dart';
import 'package:dashink/core/theme/app_text_styles.dart';
import 'package:dashink/core/utils/extensions/number_extensions.dart';
import 'package:dashink/core/widgets/app_decorations.dart';
import 'package:dashink/core/widgets/app_motion.dart';
import 'package:dashink/generated/assets.gen.dart';
import 'package:dashink/generated/colors.gen.dart';
import 'package:flutter/material.dart';

/// Figma `CoinPill`: altın ikonu + miktar. [amount] verilirse sayarak
/// değişir; [label] sabit metin içindir ("+50").
class AppCoinPill extends StatelessWidget {
  const AppCoinPill({this.amount, this.label, this.onTap, super.key})
    : assert(amount != null || label != null, 'amount veya label gerekli');

  final int? amount;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.coinAmount.ink;
    final value = amount;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 5, 14, 5),
        decoration: BoxDecoration(
          color: ColorName.paperCard,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: AppDecorations.border,
          boxShadow: const [AppDecorations.shadowSmall],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.images.coin.image(width: 28, height: 28),
            const SizedBox(width: 6),
            if (value != null)
              AppAnimatedCount(
                value: value,
                style: style,
                format: (v) => v.grouped(context),
              )
            else
              Text(label!, style: style),
          ],
        ),
      ),
    );
  }
}
