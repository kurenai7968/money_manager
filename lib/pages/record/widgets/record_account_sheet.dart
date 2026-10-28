import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/themes/app_themes.dart';

class RecordAccountSheet extends StatelessWidget {
  const RecordAccountSheet({
    required this.accounts,
    this.selectedId,
    super.key,
  });

  final List<AccountModel> accounts;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Text(
              l10n.chooseAccount,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final account in accounts)
            ListTile(
              title: Text(account.labelFor(context.categoryLanguageCode)),
              trailing: account.id == selectedId
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () => Navigator.pop(context, account.id),
            ),
        ],
      ),
    );
  }
}
