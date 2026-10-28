import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/core/utils/amount_expression.dart';
import 'package:money_manager/themes/app_themes.dart';

class RecordKeypad extends StatelessWidget {
  const RecordKeypad({
    required this.expression,
    required this.onDigit,
    required this.onDoubleZero,
    required this.onDecimal,
    required this.onBackspace,
    required this.onClear,
    required this.onOperator,
    required this.onEquals,
    required this.onSubmit,
    super.key,
  });

  final AmountExpression expression;
  final ValueChanged<String> onDigit;
  final VoidCallback onDoubleZero;
  final VoidCallback onDecimal;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final ValueChanged<AmountOperator> onOperator;
  final VoidCallback onEquals;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color operatorColor(AmountOperator op) {
      return expression.operator == op
          ? scheme.primary
          : scheme.onSurfaceVariant;
    }

    Widget key(String label, VoidCallback? onPressed, {Color? color}) {
      return SizedBox(
        height: 48,
        child: TextButton(
          onPressed: onPressed,
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: color ?? scheme.onSurface),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s,
        AppSpacing.s,
        AppSpacing.s,
        AppSpacing.l,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: key(
                  '+',
                  () => onOperator(AmountOperator.add),
                  color: operatorColor(AmountOperator.add),
                ),
              ),
              Expanded(
                child: key(
                  '−',
                  () => onOperator(AmountOperator.subtract),
                  color: operatorColor(AmountOperator.subtract),
                ),
              ),
              Expanded(
                child: key(
                  '×',
                  () => onOperator(AmountOperator.multiply),
                  color: operatorColor(AmountOperator.multiply),
                ),
              ),
              Expanded(
                child: key(
                  '÷',
                  () => onOperator(AmountOperator.divide),
                  color: operatorColor(AmountOperator.divide),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: key('1', () => onDigit('1'))),
                        Expanded(child: key('2', () => onDigit('2'))),
                        Expanded(child: key('3', () => onDigit('3'))),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: key('4', () => onDigit('4'))),
                        Expanded(child: key('5', () => onDigit('5'))),
                        Expanded(child: key('6', () => onDigit('6'))),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: key('7', () => onDigit('7'))),
                        Expanded(child: key('8', () => onDigit('8'))),
                        Expanded(child: key('9', () => onDigit('9'))),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: key('0', () => onDigit('0'))),
                        Expanded(child: key('.', onDecimal)),
                        Expanded(child: key('00', onDoubleZero)),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    key('C', onClear, color: scheme.onSurfaceVariant),
                    key('←', onBackspace, color: scheme.onSurfaceVariant),
                    _CommitKey(
                      calculating: expression.hasOperator,
                      onEquals: onEquals,
                      onSubmit: onSubmit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommitKey extends StatelessWidget {
  const _CommitKey({
    required this.calculating,
    required this.onEquals,
    required this.onSubmit,
  });

  final bool calculating;
  final VoidCallback onEquals;
  final VoidCallback onSubmit;

  static const _height = 96.0;
  static const _maxWidth = 72.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < _maxWidth
            ? constraints.maxWidth
            : _maxWidth;
        return SizedBox(
          height: _height,
          width: double.infinity,
          child: Align(
            child: SizedBox(
              width: width,
              height: _height,
              child: Tooltip(
                message: calculating ? l10n.equals : l10n.save,
                child: FilledButton(
                  onPressed: calculating ? onEquals : onSubmit,
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.m),
                    ),
                  ),
                  child: calculating
                      ? Text(
                          '=',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: scheme.onPrimary),
                        )
                      : const Icon(Icons.check),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
