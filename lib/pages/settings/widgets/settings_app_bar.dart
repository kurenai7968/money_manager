import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';

class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SettingsAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(context.l10n.settings));
  }
}
