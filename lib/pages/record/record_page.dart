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
import 'package:money_manager/pages/record/widgets/record_account_sheet.dart';
import 'package:money_manager/pages/record/widgets/record_category_grid.dart';
import 'package:money_manager/pages/record/widgets/record_keypad.dart';
import 'package:money_manager/pages/record/widgets/record_note_dialog.dart';
import 'package:money_manager/pages/record/widgets/record_transfer_fields.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/widgets/ledger_sheet.dart';

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
                    ? RecordTransferFields(
                        accounts: accounts,
                        fromId: _fromId,
                        toId: _toId,
                        onFrom: (id) => _change(() => _fromId = id),
                        onTo: (id) => _change(() => _toId = id),
                      )
                    : RecordCategoryGrid(
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
              RecordKeypad(
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
      builder: (context) => RecordNoteDialog(initial: _note),
    );
    if (result != null) {
      _change(() => _note = result.trim());
    }
  }

  Future<void> _pickAccount() async {
    final accounts = context.read<AccountsBloc>().state.active;
    final selected = await showLedgerSheet<String>(
      context: context,
      builder: (context) {
        return RecordAccountSheet(accounts: accounts, selectedId: _accountId);
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
