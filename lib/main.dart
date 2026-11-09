import 'package:dashink/app.dart';
import 'package:dashink/core/di/injection.dart';
import 'package:dashink/core/init/app_init.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  await AppInit.initialize();
  configureDependencies();
  runApp(
    EasyLocalization(
      supportedLocales: AppInit.supportedLocales,
      fallbackLocale: AppInit.fallbackLocale,
      path: AppInit.translationsPath,
      useOnlyLangCode: true,
      child: const App(),
    ),
  );
}
