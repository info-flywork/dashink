import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

extension NumberFormatting on int {
  /// Binlik ayırıcılı gösterim (tr: 1.240, en: 1,240).
  String grouped(BuildContext context) =>
      NumberFormat.decimalPattern(context.locale.toString()).format(this);
}

extension DurationFormatting on Duration {
  /// `08:12:45` biçimi (geri sayımlar).
  String get hms {
    final d = isNegative ? Duration.zero : this;
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:'
        '${two(d.inSeconds % 60)}';
  }
}
