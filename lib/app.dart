import 'package:dashink/core/di/injection.dart';
import 'package:dashink/core/init/app_init.dart';
import 'package:dashink/core/router/app_router.dart';
import 'package:dashink/core/sound/sound_manager.dart';
import 'package:dashink/core/theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Arka planda müzik durur, dönünce devam eder.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final sound = getIt<SoundManager>();
    if (state == AppLifecycleState.resumed) {
      sound.syncMusic().ignore();
    } else if (state == AppLifecycleState.paused) {
      sound.pauseMusic().ignore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppInit.systemUiOverlayStyle,
      child: MaterialApp.router(
        title: 'Dashink',
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        theme: AppTheme.lightTheme,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
      ),
    );
  }
}
