import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String message;

  const ConfirmDeleteDialog({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.delete),
        ),
      ],
    );
  }
}

Future<bool> showConfirmDeleteDialog(
  BuildContext context,
  String message,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => ConfirmDeleteDialog(message: message),
  );
  return confirmed ?? false;
}
