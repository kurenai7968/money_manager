import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/pages/home/models/home_account_pick.dart';
import 'package:money_manager/themes/app_themes.dart';

class HomeAccountSheet extends StatelessWidget {
  final List<AccountModel> accounts;
  final int? selectedId;

  const HomeAccountSheet({required this.accounts, this.selectedId, super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final primary = Theme.of(context).colorScheme.primary;
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Text(
              l10n.chooseAccount,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            title: Text(l10n.allAccounts),
            trailing: selectedId == null
                ? Icon(Icons.check, color: primary)
                : null,
            onTap: () => Navigator.pop(context, const HomeAccountPick(null)),
          ),
          for (final account in accounts)
            ListTile(
              title: Text(account.labelFor(context.categoryLanguageCode)),
              trailing: account.id == selectedId
                  ? Icon(Icons.check, color: primary)
                  : null,
              onTap: () => Navigator.pop(context, HomeAccountPick(account.id)),
            ),
        ],
      ),
    );
  }
}
