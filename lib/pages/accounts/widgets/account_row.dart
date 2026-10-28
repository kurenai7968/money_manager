import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/core/utils/ledger_balance.dart';
import 'package:money_manager/core/utils/money_format.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/routes/app_routes.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/themes/ledger_palette.dart';

class AccountRow extends StatelessWidget {
  const AccountRow({
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
