import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/core/utils/ledger_balance.dart';
import 'package:money_manager/core/utils/money_format.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_state.dart';
import 'package:money_manager/pages/accounts/widgets/account_section_label.dart';
import 'package:money_manager/pages/accounts/widgets/account_sliver.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/routes/app_routes.dart';
import 'package:money_manager/themes/app_themes.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accounts),
        actions: [
          TextButton(
            onPressed: () => context.push(AppRoutes.accountNew.path),
            child: Text(l10n.add),
          ),
        ],
      ),
      body: BlocConsumer<AccountsBloc, AccountsState>(
        listener: (context, state) {
          if (state.error == AccountsError.archiveBlocked) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(l10n.archiveBlocked)));
          }
        },
        builder: (context, state) {
          final transactions = context
              .watch<TransactionsBloc>()
              .state
              .transactions;
          final accounts = state.active;
          if (accounts.isEmpty) {
            return Center(child: Text(l10n.emptyAccounts));
          }
          final assets = accounts
              .where((account) => account.type != AccountType.credit)
              .toList();
          final liabilities = accounts
              .where((account) => account.type == AccountType.credit)
              .toList();
          final locale = Localizations.localeOf(context).toString();
          final worth = netWorthOf(accounts, transactions);
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.l,
                    AppSpacing.l,
                    AppSpacing.l,
                    AppSpacing.s,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.netWorth,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        formatMinor(worth, locale: locale),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
              ),
              if (assets.isNotEmpty) ...[
                SliverToBoxAdapter(child: AccountSectionLabel(l10n.assets)),
                AccountSliver(
                  key: const ValueKey('assets'),
                  accounts: assets,
                  transactions: transactions,
                  onReorder: (ids) => context.read<AccountsBloc>().add(
                    AccountsReorderPressed(ids),
                  ),
                ),
              ],
              if (liabilities.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: AccountSectionLabel(l10n.liabilities),
                ),
                AccountSliver(
                  key: const ValueKey('liabilities'),
                  accounts: liabilities,
                  transactions: transactions,
                  onReorder: (ids) => context.read<AccountsBloc>().add(
                    AccountsReorderPressed(ids),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
