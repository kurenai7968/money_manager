import 'package:material_ui/material_ui.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/widgets/account_book_sheet.dart';

Future<void> showSettingsChoice<T>(
  BuildContext context, {
  required String title,
  required List<(T, String)> options,
  required T selected,
  required ValueChanged<T> onSelected,
  Widget Function(T value)? leading,
}) async {
  await showAccountBookSheet<void>(
    context: context,
    maxHeightFactor: 0.5,
    builder: (context) {
      return SafeArea(
        child: ListView(
          shrinkWrap: true,
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
                leading: leading?.call(option.$1),
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
