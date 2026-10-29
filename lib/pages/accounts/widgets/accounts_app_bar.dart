import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/routes/app_routes.dart';

class AccountsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AccountsAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppBar(
      title: Text(l10n.accounts),
      actions: [
        TextButton(
          onPressed: () => context.push(AppRoutes.accountNew.path),
          child: Text(l10n.add),
        ),
      ],
    );
  }
}
