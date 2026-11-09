import 'package:dashink/core/clip/clip_recorder.dart';
import 'package:dashink/core/dialogs/dialog_handler.dart';
import 'package:dashink/core/dialogs/widgets/clip_share_dialog.dart';
import 'package:dashink/core/dialogs/widgets/game_dialogs.dart';
import 'package:dashink/core/dialogs/widgets/name_dialog.dart';
import 'package:dashink/core/dialogs/widgets/permission_dialog.dart';
import 'package:dashink/core/dialogs/widgets/shop_dialogs.dart';
import 'package:dashink/data/model/shop/shop_catalog.dart';
import 'package:dashink/domain/game/game_record.dart';
import 'package:flutter/material.dart';

/// Projedeki tüm dialog'ların tek giriş noktası.
/// Yeni dialog: `dialogs/widgets/` altına UI yaz -> buraya metod ekle.
final class AppDialogs extends DialogHandler {
  AppDialogs._init();

  static final AppDialogs _instance = AppDialogs._init();
  static AppDialogs get instance => _instance;

  // --- Mağaza ---------------------------------------------------------------

  /// Satın al ve kuşan onayı; onaylanırsa `true`.
  Future<bool> showBuyConfirm(
    BuildContext context, {
    required ShopItem item,
    required int coins,
  }) async =>
      await showFullScreenDialog<bool>(
        context: context,
        barrierDismissible: true,
        child: ShopBuyDialog(item: item, coins: coins),
      ) ??
      false;

  /// Altın yetersiz; [offer] varsa coin paketi satın alma seçeneği de sunulur.
  /// Kapatılırsa `null`.
  Future<NotEnoughCoinsChoice?> showNotEnoughCoins(
    BuildContext context, {
    required ShopItem item,
    required int coins,
    CoinPackOffer? offer,
  }) => showFullScreenDialog<NotEnoughCoinsChoice>(
    context: context,
    barrierDismissible: true,
    child: NotEnoughCoinsDialog(item: item, coins: coins, offer: offer),
  );

  /// Görevle açılan öğe; "GÖREVLERE GİT" seçilirse `true`.
  Future<bool> showItemLocked(
    BuildContext context, {
    required ShopItem item,
  }) async =>
      await showFullScreenDialog<bool>(
        context: context,
        barrierDismissible: true,
        child: ItemLockedDialog(item: item),
      ) ??
      false;

  /// Premium teklifi; satın al seçilirse `true`.
  Future<bool> showPremium(
    BuildContext context, {
    required ShopItem item,
    required PremiumOffer offer,
    required String? price,
  }) async =>
      await showFullScreenDialog<bool>(
        context: context,
        barrierDismissible: true,
        child: PremiumDialog(item: item, offer: offer, price: price),
      ) ??
      false;

  // --- Oyun -----------------------------------------------------------------

  /// Duraklatma. Seçilen aksiyonu döndürür (kapatılırsa devam).
  Future<PauseAction> showPause(BuildContext context) async =>
      await showFullScreenDialog<PauseAction>(
        context: context,
        child: const PauseDialog(),
      ) ??
      PauseAction.resume;

  /// Figma `oyun-bitti`. Yeni rekorda "YENİ REKOR!" rozeti görünür.
  Future<GameOverAction> showGameOver(
    BuildContext context, {
    required GameOutcome outcome,
  }) async =>
      await showFullScreenDialog<GameOverAction>(
        context: context,
        child: GameOverDialog(outcome: outcome),
      ) ??
      GameOverAction.home;

  /// Figma `rekor-rozeti`. "PAYLAŞ" seçilirse `true`, "DEVAM ET" `false`.
  Future<bool> showRecord(
    BuildContext context, {
    required GameOutcome outcome,
  }) async =>
      await showFullScreenDialog<bool>(
        context: context,
        child: RecordDialog(outcome: outcome),
      ) ??
      false;

  /// Figma `oyuncu-secimi`.
  Future<GameOverAction> showChoice(
    BuildContext context, {
    required int score,
  }) async =>
      await showFullScreenDialog<GameOverAction>(
        context: context,
        child: ChoiceDialog(score: score),
      ) ??
      GameOverAction.home;

  /// Galeri izni yok; "AYARLARI AÇ" seçilirse `true`.
  Future<bool> showGalleryPermission(BuildContext context) async =>
      await showFullScreenDialog<bool>(
        context: context,
        barrierDismissible: true,
        child: const GalleryPermissionDialog(),
      ) ??
      false;

  /// Figma `klip-paylas`. Paylaşıldıysa `true`.
  Future<bool> showClipShare(
    BuildContext context, {
    required ClipRecording recording,
    required int score,
  }) async =>
      await showFullScreenDialog<bool>(
        context: context,
        child: ClipShareDialog(recording: recording, score: score),
      ) ??
      false;

  // --- Ayarlar --------------------------------------------------------------

  /// Oyuncu adını düzenle. Kaydedilirse yeni adı döner.
  Future<String?> showEditName(
    BuildContext context, {
    required String currentName,
  }) => showFullScreenDialog<String>(
    context: context,
    barrierDismissible: true,
    child: NameDialog(currentName: currentName),
  );
}
