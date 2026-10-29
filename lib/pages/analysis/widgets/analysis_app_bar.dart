import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/pages/analysis/widgets/analysis_frame.dart';
import 'package:money_manager/themes/ledger_palette.dart';

class AnalysisAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AnalysisAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48);

  @override
  Widget build(BuildContext context) {
    final frame = AnalysisFrame.of(context);
    final l10n = context.l10n;
    return AppBar(
      title: Text(l10n.analysis),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => frame.setKind(CategoryKind.expense),
              child: Text(
                l10n.expense,
                style: TextStyle(
                  color: frame.kind == CategoryKind.expense
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () => frame.setKind(CategoryKind.income),
              child: Text(
                l10n.income,
                style: TextStyle(
                  color: frame.kind == CategoryKind.income
                      ? LedgerPalette.green
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
