import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';

class RecordNoteDialog extends StatefulWidget {
  const RecordNoteDialog({required this.initial, super.key});

  final String initial;

  @override
  State<RecordNoteDialog> createState() => _RecordNoteDialogState();
}

class _RecordNoteDialogState extends State<RecordNoteDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.remark),
      content: TextField(controller: _controller, autofocus: true),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
