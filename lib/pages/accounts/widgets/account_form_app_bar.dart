import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/widgets/base_app_bar.dart';

class AccountFormAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool editing;

  const AccountFormAppBar({required this.editing, super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return BaseAppBar(
      title: Text(editing ? context.l10n.editAccount : context.l10n.newAccount),
    );
  }
}
