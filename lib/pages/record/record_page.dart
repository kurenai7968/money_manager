import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/core/utils/amount_expression.dart';
import 'package:money_manager/core/utils/id.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_event.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_state.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/themes/ledger_palette.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({
    this.transactionId,
    this.initialType,
    this.initialAccountId,
    super.key,
  });

  final String? transactionId;
  final TransactionType? initialType;
  final String? initialAccountId;

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  var _expression = const AmountExpression();
  var _type = TransactionType.expense;
  DateTime _date = DateTime.now();
  String _note = '';
  String? _accountId;
  String? _categoryId;
  String? _fromId;
  String? _toId;
  var _opened = false;
  var _existingReady = false;
  var _waiting = false;
  String? _error;

  void _prepare(List<AccountModel> accounts, TransactionsState transactions) {
    if (!_opened) {
      _opened = true;
      _type = widget.initialType ?? TransactionType.expense;
      _accountId = widget.initialAccountId;
      _fromId = widget.initialAccountId;
    }
    if (!_existingReady && widget.transactionId != null) {
      final existing = transactions.transactions.where(
        (item) => item.id == widget.transactionId,
      );
      if (existing.isEmpty) {
        if (transactions.status == TransactionsStatus.success ||
            transactions.status == TransactionsStatus.failure) {
          _existingReady = true;
        } else {
          return;
        }
      } else {
        final transaction = existing.first;
        _type = transaction.type;
        _date = transaction.date;
        _note = transaction.note;
        _accountId = transaction.accountId;
        _categoryId = transaction.categoryId;
        _fromId = transaction.fromAccountId;
        _toId = transaction.toAccountId;
        _expression = AmountExpression.fromMinor(transaction.amountMinor);
        _existingReady = true;
      }
    }
    if (widget.transactionId != null || accounts.isEmpty) {
      return;
    }
    if (_type != TransactionType.transfer && _accountId == null) {
      _accountId = _accountOn(accounts, widget.initialAccountId);
    }
    if (_fromId == null) {
      _fromId = _accountOn(accounts, widget.initialAccountId);
    }
  }

  String _accountOn(List<AccountModel> accounts, String? preferred) {
    final match = accounts.where((account) => account.id == preferred);
    return match.isEmpty ? accounts.first.id : match.first.id;
  }

  void _change(VoidCallback update) {
    setState(() {
      update();
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final title = locale.startsWith('zh')
        ? DateFormat('M月d日', locale).format(_date)
        : DateFormat.MMMd(locale).format(_date);
    final accounts = context.watch<AccountsBloc>().state.active;
    final transactions = context.watch<TransactionsBloc>().state;
    _prepare(accounts, transactions);
    final categories =
        context
            .watch<CategoriesBloc>()
            .state
            .active
            .where((category) => category.kind.name == _type.name)
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _ensureCategory(categories);
    final result = _expression.resultMinor;

    return BlocListener<TransactionsBloc, TransactionsState>(
      listener: (context, state) {
        if (!_waiting) {
          return;
        }
        if (state.status == TransactionsStatus.success &&
            state.error == TransactionsError.none) {
          context.pop();
        } else if (state.error == TransactionsError.invalid) {
          setState(() => _error = l10n.invalidTransaction);
          _waiting = false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: TextButton(
            onPressed: _pickDate,
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          actions: [
            if (widget.transactionId != null)
              TextButton(onPressed: _delete, child: Text(l10n.delete)),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Row(
              children: [
                for (final type in TransactionType.values)
                  Expanded(
                    child: TextButton(
                      onPressed: () => _change(() => _setType(type)),
                      child: Text(
                        _typeLabel(l10n, type),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _type == type
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: _type == type
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: _type == TransactionType.transfer
                    ? _TransferFields(
                        accounts: accounts,
                        fromId: _fromId,
                        toId: _toId,
                        onFrom: (id) => _change(() => _fromId = id),
                        onTo: (id) => _change(() => _toId = id),
                      )
                    : _CategoryGrid(
                        categories: categories,
                        selectedId: _categoryId,
                        onSelected: (id) => _change(() => _categoryId = id),
                      ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                  child: Text(
                    _error!,
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
                      _expression.display,
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
                          onPressed: _editNote,
                          child: Text(
                            _note.isEmpty ? l10n.remark : _note,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    if (_type != TransactionType.transfer)
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: TextButton(
                            onPressed: accounts.isEmpty ? null : _pickAccount,
                            child: Text(
                              _accountName(accounts, l10n.chooseAccount),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              _Keypad(
                expression: _expression,
                onDigit: (digit) =>
                    _change(() => _expression = _expression.appendDigit(digit)),
                onDoubleZero: () =>
                    _change(() => _expression = _expression.appendDoubleZero()),
                onDecimal: () =>
                    _change(() => _expression = _expression.appendDecimal()),
                onBackspace: () =>
                    _change(() => _expression = _expression.backspace()),
                onClear: () => _change(() => _expression = _expression.clear()),
                onOperator: (op) =>
                    _change(() => _expression = _expression.applyOperator(op)),
                onEquals: _equals,
                onSubmit: () => _save(result, accounts),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _accountName(List<AccountModel> accounts, String fallback) {
    final match = accounts.where((account) => account.id == _accountId);
    return match.isEmpty
        ? fallback
        : match.first.labelFor(context.categoryLanguageCode);
  }

  void _ensureCategory(List<CategoryModel> categories) {
    if (_type == TransactionType.transfer || categories.isEmpty) {
      return;
    }
    if (widget.transactionId != null && !_existingReady) {
      return;
    }
    final selected = categories.where((item) => item.id == _categoryId);
    if (selected.isEmpty) {
      _categoryId = categories.first.id;
    }
  }

  void _equals() {
    final next = _expression.evaluate();
    if (next == null) {
      setState(() => _error = context.l10n.invalidTransaction);
      return;
    }
    _change(() => _expression = next);
  }

  void _setType(TransactionType type) {
    _type = type;
    if (type == TransactionType.transfer) {
      _categoryId = null;
      return;
    }
    final categories = context.read<CategoriesBloc>().state.categories;
    final selected = categories.where((item) => item.id == _categoryId);
    if (selected.isNotEmpty && selected.first.kind.name != type.name) {
      _categoryId = null;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _change(() => _date = picked);
    }
  }

  Future<void> _editNote() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _NoteDialog(initial: _note),
    );
    if (result != null) {
      _change(() => _note = result.trim());
    }
  }

  Future<void> _pickAccount() async {
    final accounts = context.read<AccountsBloc>().state.active;
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return _AccountSheet(accounts: accounts, selectedId: _accountId);
      },
    );
    if (selected != null) {
      _change(() => _accountId = selected);
    }
  }

  void _save(int? result, List<AccountModel> accounts) {
    final l10n = context.l10n;
    final error = _validationError(result, accounts, l10n);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() => _error = null);
    _waiting = true;
    context.read<TransactionsBloc>().add(
      TransactionSavePressed(
        TransactionModel(
          id: widget.transactionId ?? createId(),
          type: _type,
          amountMinor: result!,
          date: _date,
          note: _note,
          accountId: _type == TransactionType.transfer ? null : _accountId,
          categoryId: _type == TransactionType.transfer ? null : _categoryId,
          fromAccountId: _type == TransactionType.transfer ? _fromId : null,
          toAccountId: _type == TransactionType.transfer ? _toId : null,
        ),
      ),
    );
  }

  String? _validationError(
    int? result,
    List<AccountModel> accounts,
    AppLocalizations l10n,
  ) {
    if (accounts.isEmpty) {
      return l10n.needAccount;
    }
    if (result == null || result <= 0) {
      return l10n.invalidTransaction;
    }
    final known = accounts.map((account) => account.id).toSet();
    if (_type == TransactionType.transfer) {
      final pair =
          _fromId != null &&
          _toId != null &&
          _fromId != _toId &&
          known.contains(_fromId) &&
          known.contains(_toId);
      return pair ? null : l10n.needDifferentAccounts;
    }
    if (_categoryId == null) {
      return l10n.needCategory;
    }
    if (_accountId == null || !known.contains(_accountId)) {
      return l10n.chooseAccount;
    }
    return null;
  }

  void _delete() {
    final id = widget.transactionId;
    if (id == null) {
      return;
    }
    _waiting = true;
    context.read<TransactionsBloc>().add(TransactionDeletePressed(id));
  }

  String _typeLabel(AppLocalizations l10n, TransactionType type) {
    return switch (type) {
      TransactionType.expense => l10n.expense,
      TransactionType.income => l10n.income,
      TransactionType.transfer => l10n.transfer,
    };
  }
}

class _NoteDialog extends StatefulWidget {
  const _NoteDialog({required this.initial});

  final String initial;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
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

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<CategoryModel> categories;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 4;
        const gap = AppSpacing.s;
        const maxCellWidth = 72.0;
        const cellHeight = 112.0;
        final horizontalPadding = AppSpacing.l * 2;
        final available = constraints.maxWidth - horizontalPadding;
        final stretched = available <= gap * (columns - 1)
            ? 0.0
            : (available - gap * (columns - 1)) / columns;
        final cellWidth = stretched < maxCellWidth ? stretched : maxCellWidth;
        final contentWidth = cellWidth * columns + gap * (columns - 1);
        final gridWidth = contentWidth + horizontalPadding;
        final width = gridWidth < constraints.maxWidth
            ? gridWidth
            : constraints.maxWidth;
        return Align(
          alignment: AlignmentDirectional.topCenter,
          child: SizedBox(
            width: width,
            height: constraints.maxHeight,
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.m,
                AppSpacing.l,
                AppSpacing.m,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: gap,
                crossAxisSpacing: gap,
                mainAxisExtent: cellHeight,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final selected = category.id == selectedId;
                final label = category.labelFor(context.categoryLanguageCode);
                final color = LedgerPalette.color(category.color);
                final scheme = Theme.of(context).colorScheme;
                return Semantics(
                  button: true,
                  selected: selected,
                  label: label,
                  excludeSemantics: true,
                  child: Material(
                    color: selected
                        ? color.withValues(alpha: 0.14)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.m),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.m),
                      onTap: () {
                        onSelected(category.id);
                        Scrollable.ensureVisible(context);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 52,
                            height: 52,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: selected
                                          ? color
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: color,
                                    child: Icon(
                                      LedgerPalette.icon(category.icon),
                                      color: scheme.onPrimary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                if (selected)
                                  Positioned(
                                    right: 0,
                                    bottom: 2,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: scheme.surface,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: color,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              label,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: selected ? color : scheme.onSurface,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _TransferFields extends StatelessWidget {
  const _TransferFields({
    required this.accounts,
    required this.fromId,
    required this.toId,
    required this.onFrom,
    required this.onTo,
  });

  final List<AccountModel> accounts;
  final String? fromId;
  final String? toId;
  final ValueChanged<String> onFrom;
  final ValueChanged<String> onTo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      children: [
        ListTile(
          title: Text(l10n.fromAccount),
          trailing: Text(
            _name(fromId, l10n.chooseAccount, context.categoryLanguageCode),
          ),
          onTap: () => _pick(context, onFrom, fromId),
        ),
        ListTile(
          title: Text(l10n.toAccount),
          trailing: Text(
            _name(toId, l10n.chooseAccount, context.categoryLanguageCode),
          ),
          onTap: () => _pick(context, onTo, toId),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Text(
            l10n.netUnchanged,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  String _name(String? id, String fallback, String languageCode) {
    final match = accounts.where((account) => account.id == id);
    return match.isEmpty ? fallback : match.first.labelFor(languageCode);
  }

  Future<void> _pick(
    BuildContext context,
    ValueChanged<String> onSelected,
    String? selectedId,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) =>
          _AccountSheet(accounts: accounts, selectedId: selectedId),
    );
    if (selected != null) {
      onSelected(selected);
    }
  }
}

class _AccountSheet extends StatelessWidget {
  const _AccountSheet({required this.accounts, this.selectedId});

  final List<AccountModel> accounts;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Text(
              l10n.chooseAccount,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final account in accounts)
            ListTile(
              title: Text(account.labelFor(context.categoryLanguageCode)),
              trailing: account.id == selectedId
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () => Navigator.pop(context, account.id),
            ),
        ],
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({
    required this.expression,
    required this.onDigit,
    required this.onDoubleZero,
    required this.onDecimal,
    required this.onBackspace,
    required this.onClear,
    required this.onOperator,
    required this.onEquals,
    required this.onSubmit,
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
