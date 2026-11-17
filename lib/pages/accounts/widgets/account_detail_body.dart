import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/core/utils/money_format.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/pages/accounts/bloc/account_detail_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/account_detail_state.dart';
import 'package:money_manager/pages/accounts/bloc/account_detail_event.dart';
import 'package:money_manager/routes/app_routes.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/widgets/transaction_item.dart';

class AccountDetailBody extends StatelessWidget {
  final int accountId;

  const AccountDetailBody({required this.accountId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountDetailBloc, AccountDetailState>(
      buildWhen: (previous, current) =>
          previous.account != current.account ||
          previous.balance != current.balance ||
          previous.history != current.history ||
          previous.days != current.days ||
          previous.categories != current.categories ||
          previous.accounts != current.accounts,
      builder: (context, state) {
        final account = state.account;
        if (account == null) {
          return const SizedBox.shrink();
        }
        final locale = Localizations.localeOf(context).toString();
        final isCredit = account.type == AccountType.credit;
        void reload() {
          context.read<AccountDetailBloc>().add(
            const AccountDetailInitialized(),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCredit ? context.l10n.owed : context.l10n.balance,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    formatAmount(state.balance, locale: locale),
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
              child: TransactionList(
                days: state.days,
                categories: state.categories,
                accounts: state.accounts,
                locale: locale,
                onReturned: reload,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    await context.push(
                      AppRoutes.recordLocation(
                        type: TransactionType.transfer.name,
                        from: account.id,
                      ),
                    );
                    if (!context.mounted) {
                      return;
                    }
                    reload();
                  },
                  child: Text(context.l10n.transfer),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
