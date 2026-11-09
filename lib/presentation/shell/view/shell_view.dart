import 'package:dashink/core/sound/sound_manager.dart';
import 'package:dashink/core/widgets/app_tab_bar.dart';
import 'package:dashink/generated/colors.gen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Alt sekmeli kabuk (Oyna / Mağaza / Görevler / Ayarlar). Her sekme kendi
/// gezinme yığınını korur; Sıralama ve Günlük, Oyna sekmesinin altındadır.
class ShellView extends StatelessWidget {
  const ShellView({
    required this.navigationShell,
    required this.soundManager,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final SoundManager soundManager;

  void _onTabTapped(int index) {
    soundManager.play(GameSound.tap, volume: 0.4);
    // Aynı sekmeye tekrar dokunmak o sekmenin köküne döner.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorName.paper,
      body: navigationShell,
      bottomNavigationBar: KeyedSubtree(
        key: AppTabBar.anchorKey,
        child: AppTabBar(
          // Dil değişince tab etiketleri anında yenilensin.
          key: ValueKey(context.locale.languageCode),
          currentIndex: navigationShell.currentIndex,
          onTap: _onTabTapped,
        ),
      ),
    );
  }
}
