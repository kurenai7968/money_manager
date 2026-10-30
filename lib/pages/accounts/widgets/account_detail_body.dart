import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/core/utils/ledger_balance.dart';
import 'package:money_manager/core/utils/money_format.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/route_reload.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_event.dart';
import 'package:money_manager/routes/app_routes.dart';
import 'package:money_manager/themes/app_themes.dart';

class AccountDetailBody extends StatefulWidget {
  const AccountDetailBody({required this.accountId, super.key});

  final String accountId;

  @override
  State<AccountDetailBody> createState() => _AccountDetailBodyState();
}

class _AccountDetailBodyState extends State<AccountDetailBody>
    with RouteReload {
  @override
  void reloadForRoute() {
    context.read<AccountsBloc>().add(const AccountsStarted());
    context.read<TransactionsBloc>().add(const TransactionsStarted());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final matches = context.watch<AccountsBloc>().state.accounts.where(
      (account) => account.id == widget.accountId,
    );
    if (matches.isEmpty) {
      return const SizedBox.shrink();
    }
    final account = matches.first;
    final locale = Localizations.localeOf(context).toString();
    final transactions = context.watch<TransactionsBloc>().state.transactions;
    final balance = balanceOf(account, transactions);
    final isCredit = account.type == AccountType.credit;
    final history = transactions.where((item) {
      return item.accountId == account.id ||
          item.fromAccountId == account.id ||
          item.toAccountId == account.id;
    }).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isCredit ? l10n.owed : l10n.balance,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                formatMinor(balance, locale: locale),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: isCredit
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: history.length,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              color: Theme.of(context).colorScheme.outline,
            ),
            itemBuilder: (context, index) {
              final item = history[index];
              return ListTile(
                title: Text(
                  item.note.isEmpty
                      ? switch (item.type) {
                          TransactionType.expense => l10n.expense,
                          TransactionType.income => l10n.income,
                          TransactionType.transfer => l10n.transfer,
                          TransactionType.opening => l10n.openingBalance,
                        }
                      : item.note,
                ),
                subtitle: Text(item.date.toString().split(' ').first),
                trailing: Text(formatMinor(item.amountMinor, locale: locale)),
                onTap: item.type == TransactionType.opening
                    ? null
                    : () => context.push(
                        '${AppRoutes.record.path}?id=${item.id}',
                      ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => context.push(
                '${AppRoutes.record.path}?type=transfer&from=${account.id}',
              ),
              child: Text(l10n.transfer),
            ),
          ),
        ),
      ],
    );
  }
}
