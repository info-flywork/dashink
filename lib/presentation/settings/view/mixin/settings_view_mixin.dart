part of '../settings_view.dart';

mixin SettingsViewMixin on State<SettingsView> {
  SettingsBloc get _bloc => context.read<SettingsBloc>();

  void onToggle(SettingsToggle toggle, bool enabled) => _bloc.add(
    SettingsToggled(
      toggle,
      enabled: enabled,
      notificationTitle: LocaleKeys.notifications_daily_title.tr(),
      notificationBody: LocaleKeys.notifications_daily_body.tr(),
    ),
  );

  void onReplayTutorialTapped() => context.pushNamed(
    RoutePaths.tutorial.name,
    extra: const TutorialArgs(firstLaunch: false),
  );

  Future<void> onLanguageTapped() async {
    final locale = await showModalBottomSheet<Locale>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SettingsLanguageSheet(current: context.locale),
    );
    if (locale == null || !mounted) return;
    await context.setLocale(locale);
  }

  Future<void> onNameTapped() async {
    final name = await AppDialogs.instance.showEditName(
      context,
      currentName: _bloc.state.playerName,
    );
    if (name == null || !mounted) return;
    await _bloc
        .addAndWait(SettingsNameSaveRequested(name), until: (s) => !s.busy)
        .withLoading(context);
  }

  Future<void> onRestoreTapped() async {
    await _bloc
        .addAndWait(const SettingsRestoreRequested(), until: (s) => !s.busy)
        .withLoading(context);
  }

  Future<void> onPrivacyTapped() =>
      onLegalTapped(StringConstants.privacyPolicyUrl);

  /// Yasal sayfa (gizlilik, koşullar, çerezler, çocuk güvenliği, hakkında)
  /// uygulama içi tarayıcıda açılır.
  Future<void> onLegalTapped(String url) async {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.inAppBrowserView,
    );
    if (!ok && mounted) {
      AppSnackbar.show(
        context: context,
        text: LocaleKeys.common_unexpected_error.tr(),
        type: SnackBarType.failure,
      );
    }
  }

  void onEffect(BuildContext context, SettingsState state) {
    final (text, type) = switch (state.effect) {
      SettingsEffect.notificationsDenied => (
        LocaleKeys.settings_notifications_denied.tr(),
        SnackBarType.info,
      ),
      SettingsEffect.restored => (
        LocaleKeys.settings_restore_success.tr(),
        SnackBarType.success,
      ),
      SettingsEffect.nothingToRestore => (
        LocaleKeys.settings_restore_none.tr(),
        SnackBarType.info,
      ),
      SettingsEffect.nameSaved => (
        LocaleKeys.settings_name_saved.tr(),
        SnackBarType.success,
      ),
      SettingsEffect.nameInvalid => (
        LocaleKeys.settings_name_invalid.tr(),
        SnackBarType.failure,
      ),
      _ => (LocaleKeys.common_unexpected_error.tr(), SnackBarType.failure),
    };
    AppSnackbar.show(context: context, text: text, type: type);
  }
}
