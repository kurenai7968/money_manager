import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/pages/record/models/amount_expression.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/pages/record/bloc/record_bloc.dart';
import 'package:money_manager/pages/record/bloc/record_event.dart';
import 'package:money_manager/pages/record/bloc/record_state.dart';
import 'package:money_manager/pages/record/widgets/record_account_sheet.dart';
import 'package:money_manager/pages/record/widgets/record_category_grid.dart';
import 'package:money_manager/pages/record/widgets/record_keypad.dart';
import 'package:money_manager/pages/record/widgets/record_note_dialog.dart';
import 'package:money_manager/pages/record/widgets/record_transfer_fields.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/widgets/account_book_sheet.dart';

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
    final type = context.select((RecordBloc bloc) => bloc.state.type);
    final categories = context.select(
      (RecordBloc bloc) => bloc.state.visibleCategories,
    );
    final accounts = context.select((RecordBloc bloc) => bloc.state.accounts);
    final categoryId = context.select(
      (RecordBloc bloc) => bloc.state.categoryId,
    );
    final fromId = context.select((RecordBloc bloc) => bloc.state.fromId);
    final toId = context.select((RecordBloc bloc) => bloc.state.toId);
    if (type == TransactionType.transfer) {
      return RecordTransferFields(
        accounts: accounts,
        fromId: fromId,
        toId: toId,
        onFrom: (id) =>
            context.read<RecordBloc>().add(RecordTransferFromSelected(id)),
        onTo: (id) =>
            context.read<RecordBloc>().add(RecordTransferToSelected(id)),
      );
    }
    return RecordCategoryGrid(
      categories: categories,
      selectedId: categoryId,
      onSelected: (id) =>
          context.read<RecordBloc>().add(RecordCategorySelected(id)),
    );
  }
}

class _RecordError extends StatelessWidget {
  const _RecordError();

  @override
  Widget build(BuildContext context) {
    final message = _errorLabel(
      context.l10n,
      context.watch<RecordBloc>().state.error,
    );
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
    final expression = context.select<RecordBloc, AmountExpression>(
      (bloc) => bloc.state.expression,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      child: SizedBox(
        width: double.infinity,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerEnd,
          child: Text(
            expression.display,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
    );
  }
}

class _RecordMeta extends StatelessWidget {
  const _RecordMeta();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RecordBloc>().state;
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: () => _editNote(context, state.note),
                child: Text(
                  state.note.isEmpty ? l10n.remark : state.note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          if (state.type != TransactionType.transfer)
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: state.accounts.isEmpty
                      ? null
                      : () => _pickAccount(context, state),
                  child: Text(
                    _accountLabel(
                      state,
                      context.categoryLanguageCode,
                      l10n.chooseAccount,
                    ),
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

  Future<void> _editNote(BuildContext context, String note) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => RecordNoteDialog(initial: note),
    );
    if (result != null && context.mounted) {
      context.read<RecordBloc>().add(RecordNoteChanged(result.trim()));
    }
  }

  Future<void> _pickAccount(BuildContext context, RecordState state) async {
    final selected = await showAccountBookSheet<String>(
      context: context,
      maxHeightFactor: 0.5,
      builder: (context) {
        return RecordAccountSheet(
          accounts: state.accounts,
          selectedId: state.accountId,
        );
      },
    );
    if (selected != null && context.mounted) {
      context.read<RecordBloc>().add(RecordAccountSelected(selected));
    }
  }
}

class _RecordKeypad extends StatelessWidget {
  const _RecordKeypad();

  @override
  Widget build(BuildContext context) {
    final expression = context.select<RecordBloc, AmountExpression>(
      (bloc) => bloc.state.expression,
    );
    final bloc = context.read<RecordBloc>();
    return RecordKeypad(
      expression: expression,
      onDigit: (digit) => bloc.add(RecordDigitPressed(digit)),
      onDoubleZero: () => bloc.add(const RecordDoubleZeroPressed()),
      onDecimal: () => bloc.add(const RecordDecimalPressed()),
      onBackspace: () => bloc.add(const RecordBackspacePressed()),
      onClear: () => bloc.add(const RecordClearPressed()),
      onOperator: (operator) => bloc.add(RecordOperatorPressed(operator)),
      onEquals: () => bloc.add(const RecordEqualsPressed()),
      onSubmit: () => bloc.add(const RecordSavePressed()),
    );
  }
}

String _accountLabel(RecordState state, String languageCode, String fallback) {
  for (final account in state.accounts) {
    if (account.id == state.accountId) {
      return account.labelFor(languageCode);
    }
  }
  return fallback;
}

String? _errorLabel(AppLocalizations l10n, RecordError error) {
  return switch (error) {
    RecordError.none => null,
    RecordError.needAccount => l10n.needAccount,
    RecordError.invalid => l10n.invalidTransaction,
    RecordError.needDifferentAccounts => l10n.needDifferentAccounts,
    RecordError.needCategory => l10n.needCategory,
    RecordError.chooseAccount => l10n.chooseAccount,
  };
}
