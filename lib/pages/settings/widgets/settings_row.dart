import 'package:material_ui/material_ui.dart';
import 'package:money_manager/themes/app_themes.dart';

class SettingsRow extends StatelessWidget {
  final String title;
  final String value;
  final List<Color> swatches;
  final VoidCallback onTap;

  const SettingsRow({
    required this.title,
    required this.value,
    required this.onTap,
    this.swatches = const [],
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final swatch in swatches) ...[
            DecoratedBox(
              decoration: BoxDecoration(color: swatch, shape: BoxShape.circle),
              child: const SizedBox.square(dimension: 12),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          if (swatches.isNotEmpty) const SizedBox(width: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }
}
