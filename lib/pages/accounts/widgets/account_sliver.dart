import 'package:material_ui/material_ui.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_list_state.dart';
import 'package:money_manager/pages/accounts/widgets/account_row.dart';
import 'package:money_manager/widgets/ledger_reorder.dart';

class AccountSliver extends StatefulWidget {
  const AccountSliver({
    required this.lines,
    required this.onReorder,
    super.key,
  });

  final List<AccountLine> lines;
  final ValueChanged<List<String>> onReorder;

  @override
  State<AccountSliver> createState() => _AccountSliverState();
}

class _AccountSliverState extends State<AccountSliver> {
  late List<AccountLine> _lines = widget.lines;

  @override
  void didUpdateWidget(AccountSliver oldWidget) {
    super.didUpdateWidget(oldWidget);
    _lines = syncReorder(_lines, widget.lines, (line) => line.account.id);
  }

  @override
  Widget build(BuildContext context) {
    return SliverReorderableList(
      itemCount: _lines.length,
      proxyDecorator: ledgerReorderProxy,
      onReorderItem: _reorder,
      itemBuilder: (context, index) {
        final line = _lines[index];
        return AccountRow(
          key: ValueKey(line.account.id),
          account: line.account,
          balance: line.balanceMinor,
          index: index,
        );
      },
    );
  }

  void _reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _lines.length || oldIndex == newIndex) {
      return;
    }
    final updated = [..._lines];
    final moved = updated.removeAt(oldIndex);
    var target = newIndex;
    if (target < 0) {
      target = 0;
    } else if (target > updated.length) {
      target = updated.length;
    }
    updated.insert(target, moved);
    setState(() => _lines = updated);
    widget.onReorder([for (final line in updated) line.account.id]);
  }
}
