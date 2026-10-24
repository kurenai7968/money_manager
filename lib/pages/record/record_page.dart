import 'package:flutter/material.dart';
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
  var _ready = false;
  var _waiting = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) {
      return;
    }
    _ready = true;
    final transactions = context.read<TransactionsBloc>().state.transactions;
    final existing = transactions.where(
      (item) => item.id == widget.transactionId,
    );
    if (existing.isEmpty) {
      _type = widget.initialType ?? TransactionType.expense;
      _accountId = widget.initialAccountId;
      _fromId = widget.initialAccountId;
      return;
    }
    final transaction = existing.first;
    _type = transaction.type;
    _date = transaction.date;
    _note = transaction.note;
    _accountId = transaction.accountId;
    _categoryId = transaction.categoryId;
    _fromId = transaction.fromAccountId;
    _toId = transaction.toAccountId;
    _expression = AmountExpression.fromMinor(transaction.amountMinor);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final title = locale.startsWith('zh')
        ? DateFormat('M月d日', locale).format(_date)
        : DateFormat.MMMd(locale).format(_date);
    final accounts = context.watch<AccountsBloc>().state.active;
    final categories = context
        .watch<CategoriesBloc>()
        .state
        .active
        .where((category) => category.kind.name == _type.name)
        .toList();
    final result = _expression.resultMinor;
    final canSave = _canSave(result, accounts);

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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final type in TransactionType.values)
                  TextButton(
                    onPressed: () => _setType(type),
                    child: Text(
                      _typeLabel(l10n, type),
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
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: _type == TransactionType.transfer
                  ? _TransferFields(
                      accounts: accounts,
                      fromId: _fromId,
                      toId: _toId,
                      onFrom: (id) => setState(() => _fromId = id),
                      onTo: (id) => setState(() => _toId = id),
                    )
                  : _CategoryGrid(
                      categories: categories,
                      selectedId: _categoryId,
                      onSelected: (id) => setState(() => _categoryId = id),
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
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  _expression.display,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _editNote,
                    child: Text(_note.isEmpty ? l10n.remark : _note),
                  ),
                  const Spacer(),
                  if (_type != TransactionType.transfer)
                    TextButton(
                      onPressed: accounts.isEmpty ? null : _pickAccount,
                      child: Text(_accountName(accounts, l10n.chooseAccount)),
                    ),
                ],
              ),
            ),
            _Keypad(
              expression: _expression,
              enabled: canSave,
              onDigit: (digit) =>
                  setState(() => _expression = _expression.appendDigit(digit)),
              onDoubleZero: () =>
                  setState(() => _expression = _expression.appendDoubleZero()),
              onDecimal: () =>
                  setState(() => _expression = _expression.appendDecimal()),
              onBackspace: () =>
                  setState(() => _expression = _expression.backspace()),
              onClear: () => setState(() => _expression = _expression.clear()),
              onOperator: (op) =>
                  setState(() => _expression = _expression.applyOperator(op)),
              onSubmit: () => _save(result, accounts),
            ),
          ],
        ),
      ),
    );
  }

  bool _canSave(int? result, List<AccountModel> accounts) {
    if (result == null || result <= 0) {
      return false;
    }
    if (_type == TransactionType.transfer) {
      return _fromId != null && _toId != null && _fromId != _toId;
    }
    return _accountId != null &&
        accounts.any((account) => account.id == _accountId) &&
        _categoryId != null;
  }

  String _accountName(List<AccountModel> accounts, String fallback) {
    final match = accounts.where((account) => account.id == _accountId);
    return match.isEmpty ? fallback : match.first.name;
  }

  void _setType(TransactionType type) {
    setState(() {
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
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _editNote() async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: _note);
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.remark),
          content: TextField(controller: controller, autofocus: true),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (result != null) {
      setState(() => _note = result.trim());
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
      setState(() => _accountId = selected);
    }
  }

  void _save(int? result, List<AccountModel> accounts) {
    final l10n = context.l10n;
    if (accounts.isEmpty) {
      setState(() => _error = l10n.needAccount);
      return;
    }
    if (!_canSave(result, accounts)) {
      setState(
        () => _error = _type == TransactionType.transfer
            ? l10n.invalidTransaction
            : (_categoryId == null
                  ? l10n.needCategory
                  : l10n.invalidTransaction),
      );
      return;
    }
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
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.l),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: AppSpacing.m,
        crossAxisSpacing: AppSpacing.m,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final selected = category.id == selectedId;
        return InkWell(
          onTap: () => onSelected(category.id),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: LedgerPalette.color(category.color),
                child: Icon(
                  LedgerPalette.icon(category.icon),
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                category.labelFor(context.categoryLanguageCode),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
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
          trailing: Text(_name(fromId, l10n.chooseAccount)),
          onTap: () => _pick(context, onFrom),
        ),
        ListTile(
          title: Text(l10n.toAccount),
          trailing: Text(_name(toId, l10n.chooseAccount)),
          onTap: () => _pick(context, onTo),
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

  String _name(String? id, String fallback) {
    final match = accounts.where((account) => account.id == id);
    return match.isEmpty ? fallback : match.first.name;
  }

  Future<void> _pick(
    BuildContext context,
    ValueChanged<String> onSelected,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => _AccountSheet(accounts: accounts),
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
              title: Text(account.name),
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
    required this.enabled,
    required this.onDigit,
    required this.onDoubleZero,
    required this.onDecimal,
    required this.onBackspace,
    required this.onClear,
    required this.onOperator,
    required this.onSubmit,
  });

  final AmountExpression expression;
  final bool enabled;
  final ValueChanged<String> onDigit;
  final VoidCallback onDoubleZero;
  final VoidCallback onDecimal;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final ValueChanged<AmountOperator> onOperator;
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
                    SizedBox(
                      height: 96,
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: enabled ? onSubmit : null,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.m),
                          ),
                        ),
                        child: const Icon(Icons.check),
                      ),
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
