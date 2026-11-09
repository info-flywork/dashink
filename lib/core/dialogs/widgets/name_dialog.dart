import 'package:dashink/core/dialogs/widgets/modal_card.dart';
import 'package:dashink/core/theme/app_spacing.dart';
import 'package:dashink/core/theme/app_text_styles.dart';
import 'package:dashink/core/widgets/app_button.dart';
import 'package:dashink/domain/player/player_exceptions.dart';
import 'package:dashink/generated/colors.gen.dart';
import 'package:dashink/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Oyuncu görünen adını düzenleme. Kaydedilirse yeni adı döner, iptalde null.
class NameDialog extends StatefulWidget {
  const NameDialog({required this.currentName, super.key});

  final String currentName;

  @override
  State<NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<NameDialog> {
  late final TextEditingController _controller;
  late final FocusNode _focus;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Mevcut ad seçili gelir: yazmaya başlayınca yerine geçer.
    _controller = TextEditingController(text: widget.currentName)
      ..selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.currentName.length,
      );
    _focus = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    final raw = _controller.text;
    try {
      final name = normalizePlayerName(raw);
      Navigator.of(context).pop(name);
    } on InvalidPlayerNameException {
      setState(() => _error = LocaleKeys.settings_name_invalid.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalCard(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            LocaleKeys.settings_name_title.tr(),
            style: AppTextStyles.modalTitle.ink,
          ),
        ),
        TextField(
          controller: _controller,
          focusNode: _focus,
          // Klavye diyalogla birlikte açılır (kare sonrası beklemeden).
          autofocus: true,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.words,
          maxLength: playerNameMax,
          style: AppTextStyles.valueBold.ink,
          cursorColor: ColorName.ink,
          inputFormatters: [
            LengthLimitingTextInputFormatter(playerNameMax),
          ],
          decoration: InputDecoration(
            hintText: LocaleKeys.settings_name_hint.tr(),
            hintStyle: AppTextStyles.valueBold.inkSoft,
            counterText: '',
            errorText: _error,
            errorStyle: AppTextStyles.caption.tomato,
            filled: true,
            fillColor: ColorName.paperCard,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.m),
              borderSide: const BorderSide(
                color: ColorName.ink,
                width: AppStroke.regular,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.m),
              borderSide: const BorderSide(
                color: ColorName.ink,
                width: AppStroke.regular,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.m),
              borderSide: const BorderSide(
                color: ColorName.tomato,
                width: AppStroke.regular,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.m),
              borderSide: const BorderSide(
                color: ColorName.tomato,
                width: AppStroke.regular,
              ),
            ),
          ),
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          onSubmitted: (_) => _submit(),
        ),
        AppButton(
          label: LocaleKeys.settings_name_save.tr(),
          onPressed: _submit,
        ),
        AppButton(
          label: LocaleKeys.common_cancel.tr(),
          type: AppButtonType.ghost,
          expand: false,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
