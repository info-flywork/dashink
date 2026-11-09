part of '../settings_view.dart';

/// Figma `Group/*`: küçük başlık + kart içinde ayırıcılı satırlar.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({required this.title, required this.rows, super.key});

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.captionHeavy.inkSoft),
        const SizedBox(height: 6),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++)
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: i == rows.length - 1
                        ? null
                        : const Border(
                            bottom: BorderSide(
                              color: ColorName.paperLine,
                              width: AppStroke.divider,
                            ),
                          ),
                  ),
                  child: SizedBox(height: 56, child: rows[i]),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Aç-kapa satırı (Figma `Toggle/On|Off`).
class SettingsToggleRow extends StatelessWidget {
  const SettingsToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppTextStyles.rowLabel.ink)),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: (value ? Assets.icons.toggleOn : Assets.icons.toggleOff)
                  .svg(key: ValueKey(value), width: 52, height: 32),
            ),
          ],
        ),
      ),
    );
  }
}

/// Değer + isteğe bağlı "›" satırı.
class SettingsActionRow extends StatelessWidget {
  const SettingsActionRow({
    required this.label,
    required this.onTap,
    this.value,
    this.showChevron = true,
    super.key,
  });

  final String label;
  final String? value;
  final bool showChevron;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final trailing = [
      ?value,
      if (showChevron) '›',
    ].join(' ');
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          children: [
            Text(label, style: AppTextStyles.rowLabel.ink),
            if (trailing.isNotEmpty) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  trailing,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.rowLabel.inkSoft,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
