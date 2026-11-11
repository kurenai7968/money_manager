import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/pages/analysis/bloc/analysis_bloc.dart';
import 'package:money_manager/pages/analysis/bloc/analysis_event.dart';
import 'package:money_manager/themes/account_book_palette.dart';
import 'package:money_manager/widgets/base_app_bar.dart';

class AnalysisAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AnalysisAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AnalysisBloc>().state;
    final l10n = context.l10n;
    return BaseAppBar(
      title: Text(l10n.analysis),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => context.read<AnalysisBloc>().add(
                const AnalysisKindSelected(CategoryKind.expense),
              ),
              child: Text(
                l10n.expense,
                style: TextStyle(
                  color: state.kind == CategoryKind.expense
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.read<AnalysisBloc>().add(
                const AnalysisKindSelected(CategoryKind.income),
              ),
              child: Text(
                l10n.income,
                style: TextStyle(
                  color: state.kind == CategoryKind.income
                      ? AccountBookPalette.green
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
