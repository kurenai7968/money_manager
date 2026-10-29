import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/pages/record/widgets/record_category_grid.dart';
import 'package:money_manager/pages/record/widgets/record_frame.dart';
import 'package:money_manager/pages/record/widgets/record_keypad.dart';
import 'package:money_manager/pages/record/widgets/record_transfer_fields.dart';
import 'package:money_manager/themes/app_themes.dart';

class RecordBody extends StatelessWidget {
  const RecordBody({super.key});

  @override
  Widget build(BuildContext context) {
    final frame = RecordFrame.of(context);
    final l10n = context.l10n;
    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: frame.type == TransactionType.transfer
                ? RecordTransferFields(
                    accounts: frame.accounts,
                    fromId: frame.fromId,
                    toId: frame.toId,
                    onFrom: (id) => frame.change(() => frame.fromId = id),
                    onTo: (id) => frame.change(() => frame.toId = id),
                  )
                : RecordCategoryGrid(
                    categories: frame.visibleCategories,
                    selectedId: frame.categoryId,
                    onSelected: (id) =>
                        frame.change(() => frame.categoryId = id),
                  ),
          ),
          if (frame.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              child: Text(
                frame.error!,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            child: SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  frame.expression.display,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton(
                      onPressed: frame.editNote,
                      child: Text(
                        frame.note.isEmpty ? l10n.remark : frame.note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                if (frame.type != TransactionType.transfer)
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: frame.accounts.isEmpty
                            ? null
                            : frame.pickAccount,
                        child: Text(
                          frame.accountName(l10n.chooseAccount),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          RecordKeypad(
            expression: frame.expression,
            onDigit: (digit) => frame.change(
              () => frame.expression = frame.expression.appendDigit(digit),
            ),
            onDoubleZero: () => frame.change(
              () => frame.expression = frame.expression.appendDoubleZero(),
            ),
            onDecimal: () => frame.change(
              () => frame.expression = frame.expression.appendDecimal(),
            ),
            onBackspace: () => frame.change(
              () => frame.expression = frame.expression.backspace(),
            ),
            onClear: () =>
                frame.change(() => frame.expression = frame.expression.clear()),
            onOperator: (op) => frame.change(
              () => frame.expression = frame.expression.applyOperator(op),
            ),
            onEquals: frame.equals,
            onSubmit: frame.save,
          ),
        ],
      ),
    );
  }
}
