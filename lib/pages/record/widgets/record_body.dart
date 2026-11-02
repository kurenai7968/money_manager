import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/core/utils/amount_expression.dart';
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
    return const SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(child: _RecordPicker()),
          _RecordError(),
          _RecordAmount(),
          _RecordMeta(),
          _RecordKeypad(),
        ],
      ),
    );
  }
}

class _RecordPicker extends StatelessWidget {
  const _RecordPicker();

  @override
  Widget build(BuildContext context) {
    final frame = RecordFrame.of(context);
    if (frame.type == TransactionType.transfer) {
      return RecordTransferFields(
        accounts: frame.accounts,
        fromId: frame.fromId,
        toId: frame.toId,
        onFrom: (id) => frame.change(() => frame.fromId = id),
        onTo: (id) => frame.change(() => frame.toId = id),
      );
    }
    return RecordCategoryGrid(
      categories: frame.visibleCategories,
      selectedId: frame.categoryId,
      onSelected: (id) => frame.change(() => frame.categoryId = id),
    );
  }
}

class _RecordError extends StatelessWidget {
  const _RecordError();

  @override
  Widget build(BuildContext context) {
    final message = RecordFrame.of(context).error;
    if (message == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}

class _RecordAmount extends StatelessWidget {
  const _RecordAmount();

  @override
  Widget build(BuildContext context) {
    final frame = RecordFrame.of(context);
    return ListenableBuilder(
      listenable: frame.expressionListenable,
      builder: (context, _) {
        return Padding(
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
        );
      },
    );
  }
}

class _RecordMeta extends StatelessWidget {
  const _RecordMeta();

  @override
  Widget build(BuildContext context) {
    final frame = RecordFrame.of(context);
    final l10n = context.l10n;
    return Padding(
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
                  onPressed: frame.accounts.isEmpty ? null : frame.pickAccount,
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
    );
  }
}

class _RecordKeypad extends StatelessWidget {
  const _RecordKeypad();

  @override
  Widget build(BuildContext context) {
    final frame = RecordFrame.read(context);
    return ListenableBuilder(
      listenable: frame.expressionListenable,
      builder: (context, _) {
        final expression = frame.expression;
        return RecordKeypad(
          expression: expression,
          onDigit: (digit) =>
              frame.editExpression(expression.appendDigit(digit)),
          onDoubleZero: () =>
              frame.editExpression(expression.appendDoubleZero()),
          onDecimal: () => frame.editExpression(expression.appendDecimal()),
          onBackspace: () => frame.editExpression(expression.backspace()),
          onClear: () => frame.editExpression(expression.clear()),
          onOperator: (AmountOperator op) =>
              frame.editExpression(expression.applyOperator(op)),
          onEquals: frame.equals,
          onSubmit: frame.save,
        );
      },
    );
  }
}
