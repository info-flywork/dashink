import 'dart:async';
import 'dart:ui' as ui;

import 'package:dashink/core/clip/clip_recorder.dart';
import 'package:dashink/core/clip/clip_share_service.dart';
import 'package:dashink/core/dialogs/app_dialogs.dart';
import 'package:dashink/core/dialogs/widgets/modal_card.dart';
import 'package:dashink/core/snackbar/app_snackbar.dart';
import 'package:dashink/core/theme/app_spacing.dart';
import 'package:dashink/core/theme/app_text_styles.dart';
import 'package:dashink/core/utils/app_settings_opener.dart';
import 'package:dashink/core/utils/enum/snackbar_type.dart';
import 'package:dashink/core/widgets/app_button.dart';
import 'package:dashink/core/widgets/app_decorations.dart';
import 'package:dashink/core/widgets/app_screen_header.dart';
import 'package:dashink/generated/assets.gen.dart';
import 'package:dashink/generated/colors.gen.dart';
import 'package:dashink/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Figma `klip-paylas`: son saniyelerin önizlemesi (MP4, yoksa GIF) +
/// lokalize metin ile PAYLAŞ / GALERİYE KAYDET. Paylaşıldıysa `true` döner.
class ClipShareDialog extends StatefulWidget {
  const ClipShareDialog({
    required this.recording,
    required this.score,
    this.service,
    super.key,
  });

  final ClipRecording recording;
  final int score;
  final ClipShareService? service;

  @override
  State<ClipShareDialog> createState() => _ClipShareDialogState();
}

class _ClipShareDialogState extends State<ClipShareDialog> {
  late final ClipShareService _service = widget.service ?? ClipShareService();
  Timer? _player;
  int _frame = 0;
  bool _busy = false;
  bool _shared = false;
  Future<String>? _export;

  ClipRecording get _clip => widget.recording;

  @override
  void initState() {
    super.initState();
    if (!_clip.isEmpty) _frame = _clip.frames.length - 1;
  }

  @override
  void dispose() {
    _player?.cancel();
    super.dispose();
  }

  void _togglePlay() {
    if (_clip.isEmpty) return;
    if (_player != null) {
      _player!.cancel();
      setState(() => _player = null);
      return;
    }
    _frame = 0;
    _player = Timer.periodic(Duration(milliseconds: 1000 ~/ _clip.fps), (t) {
      if (!mounted) return;
      setState(() {
        if (_frame >= _clip.frames.length - 1) {
          t.cancel();
          _player = null;
        } else {
          _frame++;
        }
      });
    });
    setState(() {});
  }

  /// MP4 (yoksa GIF) bir kez üretilir; paylaş ve kaydet aynı dosyayı kullanır.
  Future<String?> _exportClip() async {
    if (_clip.isEmpty) return null;
    try {
      return await (_export ??= _clip.exportForShare());
    } on Object {
      _export = null;
      return null;
    }
  }

  String _shareText({String? url}) {
    final score = '${widget.score}';
    if (url == null || url.isEmpty) {
      return LocaleKeys.clip_share_text.tr(namedArgs: {'score': score});
    }
    return LocaleKeys.clip_share_text_with_link.tr(
      namedArgs: {'score': score, 'url': url},
    );
  }

  Rect? get _shareOrigin {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Future<void> _withBusy(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _onShare() => _withBusy(() async {
    final path = await _exportClip();
    if (!mounted) return;
    if (!_clip.isEmpty && path == null) {
      _toast(LocaleKeys.clip_save_failed.tr(), SnackBarType.failure);
      return;
    }
    // CDN'e yükle (başarısız olsa da yerel dosya + metin paylaşılır).
    final cdnUrl = path == null ? null : await _service.uploadToCdn(path);
    if (!mounted) return;
    final ok = await _service.share(
      text: _shareText(url: cdnUrl),
      filePath: path,
      sharePositionOrigin: _shareOrigin,
    );
    if (ok) _shared = true;
  });

  Future<void> _onSave() => _withBusy(() async {
    // Önce izin: klip hazırlanmadan (birkaç saniye sürer) sorulur.
    if (!await _service.ensureGalleryAccess()) {
      if (!mounted) return;
      final open = await AppDialogs.instance.showGalleryPermission(context);
      if (open) await AppSettingsOpener.open();
      return;
    }
    if (!mounted) return;
    final path = await _exportClip();
    if (!mounted) return;
    if (path == null) {
      _toast(LocaleKeys.clip_save_failed.tr(), SnackBarType.failure);
      return;
    }
    final result = await _service.saveToGallery(path);
    if (!mounted) return;
    switch (result) {
      case GallerySaveResult.saved:
        _toast(LocaleKeys.clip_saved.tr(), SnackBarType.success);
      case GallerySaveResult.denied:
        _toast(LocaleKeys.clip_permission_denied.tr(), SnackBarType.info);
      case GallerySaveResult.failed:
        _toast(LocaleKeys.clip_save_failed.tr(), SnackBarType.failure);
    }
  });

  void _toast(String text, SnackBarType type) =>
      AppSnackbar.show(context: context, text: text, type: type);

  @override
  Widget build(BuildContext context) {
    final seconds = _clip.isEmpty ? 0 : _clip.seconds;
    return PopScope(
      canPop: !_busy,
      child: ModalCard(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  LocaleKeys.clip_title.tr(),
                  style: AppTextStyles.cardTitle.ink,
                ),
              ),
              AppCloseButton(
                onTap: () {
                  if (!_busy) Navigator.of(context).pop(_shared);
                },
              ),
            ],
          ),
          _Preview(
            frame: _clip.isEmpty ? null : _clip.frames[_frame],
            playing: _player != null,
            seconds: seconds,
            onTap: _togglePlay,
          ),
          Text(
            _busy
                ? LocaleKeys.clip_preparing.tr()
                : _clip.isEmpty
                ? LocaleKeys.clip_no_clip.tr()
                : LocaleKeys.clip_subtitle.tr(
                    namedArgs: {
                      'seconds': '$seconds',
                      'score': '${widget.score}',
                    },
                  ),
            style: AppTextStyles.caption.inkSoft,
          ),
          AppButton(
            label: LocaleKeys.clip_share.tr(),
            icon: AppSvgIcon(Assets.icons.shareWhite, size: 26),
            onPressed: _busy ? null : _onShare,
          ),
          if (!_clip.isEmpty)
            AppButton(
              label: LocaleKeys.clip_save.tr(),
              type: AppButtonType.secondary,
              icon: AppSvgIcon(Assets.icons.imageBtn, size: 26),
              onPressed: _busy ? null : _onSave,
            ),
        ],
      ),
    );
  }
}

/// Figma `ClipPreview`: 200×356, r20, ink çerçeve, ortada oynat, solda süre.
class _Preview extends StatelessWidget {
  const _Preview({
    required this.frame,
    required this.playing,
    required this.seconds,
    required this.onTap,
  });

  final ui.Image? frame;
  final bool playing;
  final int seconds;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final image = frame;
    return Semantics(
      button: true,
      label: LocaleKeys.clip_play.tr(),
      child: GestureDetector(
        onTap: onTap,
        // Border ile clip aynı Container'da olursa köşe çizgileri kesilir;
        // çerçeve dışarıda, içerik ClipRRect ile yuvarlanır.
        child: Container(
          width: 200,
          height: 356,
          decoration: BoxDecoration(
            color: ColorName.paper,
            borderRadius: BorderRadius.circular(AppRadius.l),
            border: AppDecorations.border,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              AppRadius.l - AppStroke.regular,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (image != null)
                  RawImage(image: image, fit: BoxFit.cover)
                else
                  Assets.images.klipOnizleme.image(fit: BoxFit.cover),
                if (!playing)
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: ColorName.tomato,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: ColorName.tomatoDark,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: AppSvgIcon(Assets.icons.playWhite, size: 28),
                    ),
                  ),
                PositionedDirectional(
                  start: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: ColorName.ink,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      '0:${seconds.toString().padLeft(2, '0')}',
                      style: AppTextStyles.captionHeavy.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
