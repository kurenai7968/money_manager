import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/pages/accounts/bloc/account_detail_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/account_detail_state.dart';
import 'package:money_manager/routes/app_routes.dart';
import 'package:money_manager/widgets/base_app_bar.dart';

class AccountDetailAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final int accountId;

  const AccountDetailAppBar({required this.accountId, super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AccountDetailBloc, AccountDetailState, AccountModel?>(
      selector: (state) => state.account,
      builder: (context, account) {
        final title = account == null
            ? context.l10n.accounts
            : account.labelFor(context.categoryLanguageCode);
        return BaseAppBar(
          title: Text(title),
          actions: [
            if (account != null)
              TextButton(
                onPressed: () => context.push(AppRoutes.editAccount(accountId)),
                child: Text(context.l10n.edit),
              ),
          ],
        );
      },
    );
  }
}
