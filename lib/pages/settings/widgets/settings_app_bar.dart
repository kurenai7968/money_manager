import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/widgets/base_app_bar.dart';

class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SettingsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseAppBar(title: Text(context.l10n.settings));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
