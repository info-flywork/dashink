import 'package:dashink/core/network/network_exception.dart';
import 'package:dashink/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

/// Hataları kullanıcıya gösterilecek yerelleştirilmiş metne çevirir.
abstract final class ErrorMessages {
  static String of(Object? error) {
    if (error is NetworkException && error.statusCode == null) {
      return LocaleKeys.common_offline.tr();
    }
    return LocaleKeys.common_unexpected_error.tr();
  }
}
