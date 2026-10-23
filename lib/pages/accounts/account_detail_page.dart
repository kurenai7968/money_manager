import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/core/utils/money_format.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_state.dart';
import 'package:money_manager/routes/app_routes.dart';
import 'package:money_manager/themes/app_themes.dart';

class AccountDetailPage extends StatelessWidget {
  const AccountDetailPage({required this.accountId, super.key});

  final String accountId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<AccountsBloc, AccountsState>(
      builder: (context, state) {
        final matches = state.accounts.where(
          (account) => account.id == accountId,
        );
        if (matches.isEmpty) {
          return Scaffold(appBar: AppBar(title: Text(l10n.accounts)));
        }
        final account = matches.first;
        final locale = Localizations.localeOf(context).toString();
        final isCredit = account.type == AccountType.credit;
        return Scaffold(
          appBar: AppBar(
            title: Text(account.name),
            actions: [
              TextButton(
                onPressed: () =>
                    context.push(AppRoutes.editAccount(account.id)),
                child: Text(l10n.edit),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCredit ? l10n.owed : l10n.openingBalance,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  formatMinor(account.openingBalanceMinor, locale: locale),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: isCredit
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
