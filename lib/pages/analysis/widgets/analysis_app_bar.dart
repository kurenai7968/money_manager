import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/pages/analysis/bloc/analysis_bloc.dart';
import 'package:money_manager/pages/analysis/bloc/analysis_event.dart';
import 'package:money_manager/pages/analysis/bloc/analysis_state.dart';
import 'package:money_manager/widgets/base_app_bar.dart';

class AnalysisAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AnalysisAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 48);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AnalysisBloc, AnalysisState, CategoryKind>(
      selector: (state) => state.kind,
      builder: (context, kind) => BaseAppBar(
        title: Text(context.l10n.analysis),
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
                  context.l10n.expense,
                  style: TextStyle(
                    color: kind == CategoryKind.expense
                        ? context.ledgerColor(income: false)
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.read<AnalysisBloc>().add(
                  const AnalysisKindSelected(CategoryKind.income),
                ),
                child: Text(
                  context.l10n.income,
                  style: TextStyle(
                    color: kind == CategoryKind.income
                        ? context.ledgerColor(income: true)
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
