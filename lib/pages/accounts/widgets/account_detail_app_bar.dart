import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/pages/accounts/bloc/account_detail_bloc.dart';
import 'package:money_manager/routes/app_routes.dart';

class AccountDetailAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String accountId;

  const AccountDetailAppBar({required this.accountId, super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final account = context.watch<AccountDetailBloc>().state.account;
    final title = account == null
        ? l10n.accounts
        : account.labelFor(context.categoryLanguageCode);
    return AppBar(
      title: Text(title),
      actions: [
        if (account != null)
          TextButton(
            onPressed: () => context.push(AppRoutes.editAccount(accountId)),
            child: Text(l10n.edit),
          ),
      ],
    );
  }
}
