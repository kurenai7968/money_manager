import 'package:material_ui/material_ui.dart';
import 'package:money_manager/themes/ledger_palette.dart';

class CategoryIconChoice extends StatelessWidget {
  const CategoryIconChoice({
    required this.iconKey,
    required this.selected,
    required this.color,
    required this.onPressed,
    super.key,
  });

  final String iconKey;
  final bool selected;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = selected ? scheme.onPrimary : scheme.onSurfaceVariant;
    return IconButton(
      tooltip: iconKey,
      isSelected: selected,
      style: IconButton.styleFrom(
        backgroundColor: selected ? color : Colors.transparent,
        foregroundColor: foreground,
      ),
      onPressed: onPressed,
      icon: Icon(LedgerPalette.icon(iconKey), color: foreground),
    );
  }
}
