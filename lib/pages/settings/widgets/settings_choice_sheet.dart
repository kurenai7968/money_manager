import 'package:material_ui/material_ui.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/widgets/ledger_sheet.dart';

Future<void> showSettingsChoice<T>(
  BuildContext context, {
  required String title,
  required List<(T, String)> options,
  required T selected,
  required ValueChanged<T> onSelected,
}) async {
  await showLedgerSheet<void>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final option in options)
              ListTile(
                title: Text(option.$2),
                trailing: option.$1 == selected
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  onSelected(option.$1);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      );
    },
  );
}
