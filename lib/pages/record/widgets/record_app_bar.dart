import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/pages/record/widgets/record_frame.dart';

class RecordAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RecordAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48);

  @override
  Widget build(BuildContext context) {
    final frame = RecordFrame.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    return AppBar(
      title: TextButton(
        onPressed: frame.pickDate,
        child: Text(
          frame.titleFor(locale),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      actions: [
        if (frame.transactionId != null)
          TextButton(onPressed: frame.delete, child: Text(l10n.delete)),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Row(
          children: [
            for (final type in TransactionType.values.where(
              (type) => type != TransactionType.opening,
            ))
              Expanded(
                child: TextButton(
                  onPressed: () => frame.change(() => frame.setType(type)),
                  child: Text(
                    frame.typeLabel(l10n, type),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: frame.type == type
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: frame.type == type
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
