part of '../settings_view.dart';

/// Dil seçimi — kaydırılabilir liste (36 dil).
class SettingsLanguageSheet extends StatelessWidget {
  const SettingsLanguageSheet({required this.current, super.key});

  final Locale current;

  @override
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.7;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AppCard(
          radius: AppRadius.modal,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: SizedBox(
            height: sheetHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.settings_language_title.tr(),
                  style: AppTextStyles.cardTitle.ink,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: AppInit.supportedLocales.length,
                    itemBuilder: (context, index) {
                      final locale = AppInit.supportedLocales[index];
                      final selected =
                          locale.languageCode == current.languageCode;
                      return SizedBox(
                        height: 56,
                        child: SettingsActionRow(
                          label: AppLanguages.nativeName(locale.languageCode),
                          value: selected ? '✓' : null,
                          showChevron: false,
                          onTap: () => Navigator.of(context).pop(locale),
                        ),
                      );
                    },
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
