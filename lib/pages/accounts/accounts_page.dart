import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/core/utils/ledger_balance.dart';
import 'package:money_manager/core/utils/money_format.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_state.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/routes/app_routes.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/themes/ledger_palette.dart';

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
                SliverToBoxAdapter(child: _SectionLabel(l10n.assets)),
                _AccountSliver(
                  accounts: assets,
                  transactions: transactions,
                  onReorder: (ids) => context.read<AccountsBloc>().add(
                    AccountsReorderPressed(ids),
                  ),
                ),
              ],
              if (liabilities.isNotEmpty) ...[
                SliverToBoxAdapter(child: _SectionLabel(l10n.liabilities)),
                _AccountSliver(
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.xl,
        AppSpacing.l,
        AppSpacing.s,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _AccountSliver extends StatelessWidget {
  const _AccountSliver({
    required this.accounts,
    required this.transactions,
    required this.onReorder,
  });

  final List<AccountModel> accounts;
  final List<TransactionModel> transactions;
  final ValueChanged<List<String>> onReorder;

  @override
  Widget build(BuildContext context) {
    return SliverReorderableList(
      itemCount: accounts.length,
      onReorderItem: (oldIndex, newIndex) {
        final updated = [...accounts];
        final moved = updated.removeAt(oldIndex);
        updated.insert(newIndex, moved);
        onReorder(updated.map((account) => account.id).toList());
      },
      itemBuilder: (context, index) {
        final account = accounts[index];
        return _AccountRow(
          key: ValueKey(account.id),
          account: account,
          transactions: transactions,
          index: index,
        );
      },
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.account,
    required this.transactions,
    required this.index,
    super.key,
  });

  final AccountModel account;
  final List<TransactionModel> transactions;
  final int index;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final scheme = Theme.of(context).colorScheme;
    final isCredit = account.type == AccountType.credit;
    final color = switch (account.type) {
      AccountType.bank => LedgerPalette.blue,
      AccountType.cash => LedgerPalette.coral,
      AccountType.savings => LedgerPalette.teal,
      AccountType.credit => LedgerPalette.slate,
    };
    return ListTile(
      onTap: () => context.push(AppRoutes.account(account.id)),
      leading: Icon(Icons.circle, color: color, size: 12),
      title: Text(account.labelFor(context.categoryLanguageCode)),
      subtitle: isCredit ? Text(l10n.owed) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatMinor(balanceOf(account, transactions), locale: locale),
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: isCredit ? scheme.primary : scheme.onSurface),
          ),
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: AppSpacing.s),
              child: Icon(Icons.drag_handle, color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
