import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/pages/record/widgets/record_account_sheet.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/widgets/ledger_sheet.dart';

class RecordTransferFields extends StatelessWidget {
  const RecordTransferFields({
    required this.accounts,
    required this.fromId,
    required this.toId,
    required this.onFrom,
    required this.onTo,
    super.key,
  });

  final List<AccountModel> accounts;
  final String? fromId;
  final String? toId;
  final ValueChanged<String> onFrom;
  final ValueChanged<String> onTo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      children: [
        ListTile(
          title: Text(l10n.fromAccount),
          trailing: Text(
            _name(fromId, l10n.chooseAccount, context.categoryLanguageCode),
          ),
          onTap: () => _pick(context, onFrom, fromId),
        ),
        ListTile(
          title: Text(l10n.toAccount),
          trailing: Text(
            _name(toId, l10n.chooseAccount, context.categoryLanguageCode),
          ),
          onTap: () => _pick(context, onTo, toId),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Text(
            l10n.netUnchanged,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  String _name(String? id, String fallback, String languageCode) {
    final match = accounts.where((account) => account.id == id);
    return match.isEmpty ? fallback : match.first.labelFor(languageCode);
  }

  Future<void> _pick(
    BuildContext context,
    ValueChanged<String> onSelected,
    String? selectedId,
  ) async {
    final selected = await showLedgerSheet<String>(
      context: context,
      builder: (context) =>
          RecordAccountSheet(accounts: accounts, selectedId: selectedId),
    );
    if (selected != null) {
      onSelected(selected);
    }
  }
}
