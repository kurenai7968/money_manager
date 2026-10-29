import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';

class AccountFormAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AccountFormAppBar({required this.editing, super.key});

  final bool editing;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppBar(title: Text(editing ? l10n.editAccount : l10n.newAccount));
  }
}
