import 'package:dashink/core/l10n/app_languages.dart';
import 'package:dashink/core/managers/shared_pref_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Uygulama başlangıç sırası.
abstract final class AppInit {
  /// Kağıt zemin üzerinde koyu saat / pil ikonları.
  static const SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFFFFFBF2),
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  /// Desteklenen diller. Cihaz dili listede yoksa [fallbackLocale].
  static List<Locale> get supportedLocales => AppLanguages.locales;

  static const Locale fallbackLocale = Locale('en');
  static const String translationsPath = 'assets/translations';

  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    await EasyLocalization.ensureInitialized();
    await initializeDateFormatting();
    await SharedPrefManager.instance.init();
  }
}
