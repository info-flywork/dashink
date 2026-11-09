import 'package:dashink/core/theme/app_spacing.dart';
import 'package:dashink/core/widgets/app_decorations.dart';
import 'package:dashink/generated/colors.gen.dart';
import 'package:flutter/material.dart';

/// Figma `Modal` / `ScoreCard`: ortada, yatayda 16px boşluklu kağıt kart
/// (r28, 28/24 iç boşluk, 14 aralık). Arka plan (kağıt %55 scrim)
/// `DialogHandler.showFullScreenDialog`'dan gelir.
class ModalCard extends StatelessWidget {
  const ModalCard({
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(24, 28, 24, 24),
    this.overlay,
    super.key,
  });

  final List<Widget> children;
  final EdgeInsets padding;

  /// Kartın üstüne taşan öğe (ör. "YENİ REKOR!" rozeti).
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    // Klavye açıksa kart klavyenin üstünde kalan alanda ortalanır (ör. isim
    // diyaloğunun "Kaydet" butonu klavyenin altında kalmasın).
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: keyboard),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Material(
              type: MaterialType.transparency,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    padding: padding,
                    decoration: AppDecorations.card(
                      radius: AppRadius.modal,
                      shadowStyle: const BoxShadow(
                        color: ColorName.inkShadow,
                        offset: Offset(0, 6),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < children.length; i++) ...[
                          if (i > 0) const SizedBox(height: 14),
                          children[i],
                        ],
                      ],
                    ),
                  ),
                  ?overlay,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Domates tonlu yuvarlak hale içinde görsel (satın al, altın yetersiz).
class ModalHalo extends StatelessWidget {
  const ModalHalo({required this.child, this.size = 168, super.key});

  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: ColorName.tomatoTint,
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}
