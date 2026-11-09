import 'dart:async';

import 'package:dashink/core/dialogs/app_dialogs.dart';
import 'package:dashink/core/init/app_init.dart';
import 'package:dashink/core/l10n/app_languages.dart';
import 'package:dashink/core/router/route_paths.dart';
import 'package:dashink/core/snackbar/app_snackbar.dart';
import 'package:dashink/core/theme/app_spacing.dart';
import 'package:dashink/core/theme/app_text_styles.dart';
import 'package:dashink/core/utils/constants/string_constants.dart';
import 'package:dashink/core/utils/enum/snackbar_type.dart';
import 'package:dashink/core/utils/extensions/bloc_extensions.dart';
import 'package:dashink/core/utils/extensions/future_extensions.dart';
import 'package:dashink/core/widgets/app_decorations.dart';
import 'package:dashink/core/widgets/app_screen_header.dart';
import 'package:dashink/generated/assets.gen.dart';
import 'package:dashink/generated/colors.gen.dart';
import 'package:dashink/generated/locale_keys.g.dart';
import 'package:dashink/presentation/settings/bloc/settings_bloc.dart';
import 'package:dashink/presentation/tutorial/view/tutorial_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

part 'mixin/settings_view_mixin.dart';
part 'widgets/settings_group.dart';
part 'widgets/settings_language_sheet.dart';

/// Figma `ayarlar`.
class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> with SettingsViewMixin {
  @override
  Widget build(BuildContext context) {
    return AppPaperBackground(
      child: SafeArea(
        bottom: false,
        child: BlocConsumer<SettingsBloc, SettingsState>(
          listenWhen: (a, b) => b.effect != SettingsEffect.none,
          listener: onEffect,
          builder: (context, state) => Column(
            children: [
              AppScreenHeader(title: LocaleKeys.settings_title.tr()),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    SettingsGroup(
                      title: LocaleKeys.settings_sound.tr(),
                      rows: [
                        SettingsToggleRow(
                          label: LocaleKeys.settings_sfx.tr(),
                          value: state.sfx,
                          onChanged: (v) => onToggle(SettingsToggle.sfx, v),
                        ),
                        SettingsToggleRow(
                          label: LocaleKeys.settings_music.tr(),
                          value: state.music,
                          onChanged: (v) => onToggle(SettingsToggle.music, v),
                        ),
                        SettingsToggleRow(
                          label: LocaleKeys.settings_vibration.tr(),
                          value: state.vibration,
                          onChanged: (v) =>
                              onToggle(SettingsToggle.vibration, v),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s),
                    SettingsGroup(
                      title: LocaleKeys.settings_game.tr(),
                      rows: [
                        SettingsActionRow(
                          label: LocaleKeys.settings_language.tr(),
                          value: LocaleKeys.settings_language_name.tr(),
                          onTap: onLanguageTapped,
                        ),
                        SettingsToggleRow(
                          label: LocaleKeys.settings_notifications.tr(),
                          value: state.notifications,
                          onChanged: (v) =>
                              onToggle(SettingsToggle.notifications, v),
                        ),
                        SettingsActionRow(
                          label: LocaleKeys.settings_replay_tutorial.tr(),
                          onTap: onReplayTutorialTapped,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s),
                    SettingsGroup(
                      title: LocaleKeys.settings_account.tr(),
                      rows: [
                        SettingsActionRow(
                          label: LocaleKeys.settings_name.tr(),
                          value: state.playerName.isEmpty
                              ? null
                              : state.playerName,
                          onTap: onNameTapped,
                        ),
                        SettingsActionRow(
                          label: LocaleKeys.settings_restore.tr(),
                          onTap: onRestoreTapped,
                        ),
                        SettingsActionRow(
                          label: LocaleKeys.settings_privacy.tr(),
                          onTap: onPrivacyTapped,
                        ),
                        SettingsActionRow(
                          label: LocaleKeys.settings_terms.tr(),
                          onTap: () => onLegalTapped(StringConstants.termsUrl),
                        ),
                        SettingsActionRow(
                          label: LocaleKeys.settings_cookies.tr(),
                          onTap: () =>
                              onLegalTapped(StringConstants.cookiesUrl),
                        ),
                        SettingsActionRow(
                          label: LocaleKeys.settings_child_safety.tr(),
                          onTap: () =>
                              onLegalTapped(StringConstants.childSafetyUrl),
                        ),
                        SettingsActionRow(
                          label: LocaleKeys.settings_about.tr(),
                          onTap: () => onLegalTapped(StringConstants.aboutUrl),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      LocaleKeys.settings_version.tr(
                        args: [StringConstants.appVersion],
                      ),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.inkSoft,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
