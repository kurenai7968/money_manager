import 'package:material_ui/material_ui.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/accounts/widgets/account_row.dart';
import 'package:money_manager/widgets/ledger_reorder.dart';

class AccountSliver extends StatefulWidget {
  const AccountSliver({
    required this.accounts,
    required this.transactions,
    required this.onReorder,
    super.key,
  });

  final List<AccountModel> accounts;
  final List<TransactionModel> transactions;
  final ValueChanged<List<String>> onReorder;

  @override
  State<AccountSliver> createState() => _AccountSliverState();
}

class _AccountSliverState extends State<AccountSliver> {
  late List<AccountModel> _accounts = widget.accounts;

  @override
  void didUpdateWidget(AccountSliver oldWidget) {
    super.didUpdateWidget(oldWidget);
    _accounts = syncReorder(
      _accounts,
      widget.accounts,
      (account) => account.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverReorderableList(
      itemCount: _accounts.length,
      proxyDecorator: ledgerReorderProxy,
      onReorderItem: _reorder,
      itemBuilder: (context, index) {
        final account = _accounts[index];
        return AccountRow(
          key: ValueKey(account.id),
          account: account,
          transactions: widget.transactions,
          index: index,
        );
      },
    );
  }

  void _reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _accounts.length || oldIndex == newIndex) {
      return;
    }
    final updated = [..._accounts];
    final moved = updated.removeAt(oldIndex);
    var target = newIndex;
    if (target < 0) {
      target = 0;
    } else if (target > updated.length) {
      target = updated.length;
    }
    updated.insert(target, moved);
    setState(() => _accounts = updated);
    widget.onReorder([for (final account in updated) account.id]);
  }
}
