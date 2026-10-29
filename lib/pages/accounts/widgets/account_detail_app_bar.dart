import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/routes/app_routes.dart';

class AccountDetailAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const AccountDetailAppBar({required this.accountId, super.key});

  final String accountId;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final matches = context.watch<AccountsBloc>().state.accounts.where(
      (account) => account.id == accountId,
    );
    final title = matches.isEmpty
        ? l10n.accounts
        : matches.first.labelFor(context.categoryLanguageCode);
    return AppBar(
      title: Text(title),
      actions: [
        if (matches.isNotEmpty)
          TextButton(
            onPressed: () => context.push(AppRoutes.editAccount(accountId)),
            child: Text(l10n.edit),
          ),
      ],
    );
  }
}
