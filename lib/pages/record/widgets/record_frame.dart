import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/core/utils/amount_expression.dart';
import 'package:money_manager/core/utils/id.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/models/transaction_model.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/categories/bloc/categories_bloc.dart';
import 'package:money_manager/pages/record/widgets/record_account_sheet.dart';
import 'package:money_manager/pages/record/widgets/record_note_dialog.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_event.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_state.dart';
import 'package:money_manager/widgets/ledger_sheet.dart';

class RecordFrame extends StatefulWidget {
  const RecordFrame({
    required this.child,
    this.transactionId,
    this.initialType,
    this.initialAccountId,
    super.key,
  });

  final Widget child;
  final String? transactionId;
  final TransactionType? initialType;
  final String? initialAccountId;

  static RecordFrameState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_RecordScope>();
    assert(scope != null, 'RecordFrame not found');
    return scope!.state;
  }

  @override
  State<RecordFrame> createState() => RecordFrameState();
}

class RecordFrameState extends State<RecordFrame> {
  var expression = const AmountExpression();
  var type = TransactionType.expense;
  DateTime date = DateTime.now();
  String note = '';
  String? accountId;
  String? categoryId;
  String? fromId;
  String? toId;
  var _opened = false;
  var _existingReady = false;
  var _waiting = false;
  String? error;
  List<AccountModel> accounts = const [];
  List<CategoryModel> visibleCategories = const [];

  int? get result => expression.resultMinor;

  String? get transactionId => widget.transactionId;

  void _prepare(List<AccountModel> loaded, TransactionsState transactions) {
    if (!_opened) {
      _opened = true;
      type = widget.initialType ?? TransactionType.expense;
      accountId = widget.initialAccountId;
      fromId = widget.initialAccountId;
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
        type = transaction.type;
        date = transaction.date;
        note = transaction.note;
        accountId = transaction.accountId;
        categoryId = transaction.categoryId;
        fromId = transaction.fromAccountId;
        toId = transaction.toAccountId;
        expression = AmountExpression.fromMinor(transaction.amountMinor);
        _existingReady = true;
      }
    }
    if (widget.transactionId != null || loaded.isEmpty) {
      return;
    }
    if (type != TransactionType.transfer && accountId == null) {
      accountId = _accountOn(loaded, widget.initialAccountId);
    }
    fromId ??= _accountOn(loaded, widget.initialAccountId);
  }

  String _accountOn(List<AccountModel> loaded, String? preferred) {
    final match = loaded.where((account) => account.id == preferred);
    return match.isEmpty ? loaded.first.id : match.first.id;
  }

  void change(VoidCallback update) {
    setState(() {
      update();
      error = null;
    });
  }

  void _ensureCategory(List<CategoryModel> categories) {
    if (type == TransactionType.transfer || categories.isEmpty) {
      return;
    }
    if (widget.transactionId != null && !_existingReady) {
      return;
    }
    final selected = categories.where((item) => item.id == categoryId);
    if (selected.isEmpty) {
      categoryId = categories.first.id;
    }
  }

  String accountName(String fallback) {
    final match = accounts.where((account) => account.id == accountId);
    return match.isEmpty
        ? fallback
        : match.first.labelFor(context.categoryLanguageCode);
  }

  void equals() {
    final next = expression.evaluate();
    if (next == null) {
      setState(() => error = context.l10n.invalidTransaction);
      return;
    }
    change(() => expression = next);
  }

  void setType(TransactionType next) {
    type = next;
    if (next == TransactionType.transfer) {
      categoryId = null;
      return;
    }
    final categories = context.read<CategoriesBloc>().state.categories;
    final selected = categories.where((item) => item.id == categoryId);
    if (selected.isNotEmpty && selected.first.kind.name != next.name) {
      categoryId = null;
    }
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      change(() => date = picked);
    }
  }

  Future<void> editNote() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => RecordNoteDialog(initial: note),
    );
    if (result != null) {
      change(() => note = result.trim());
    }
  }

  Future<void> pickAccount() async {
    final loaded = context.read<AccountsBloc>().state.active;
    final selected = await showLedgerSheet<String>(
      context: context,
      builder: (context) {
        return RecordAccountSheet(accounts: loaded, selectedId: accountId);
      },
    );
    if (selected != null) {
      change(() => accountId = selected);
    }
  }

  void save() {
    final l10n = context.l10n;
    final message = _validationError(result, accounts, l10n);
    if (message != null) {
      setState(() => error = message);
      return;
    }
    setState(() => error = null);
    _waiting = true;
    context.read<TransactionsBloc>().add(
      TransactionSavePressed(
        TransactionModel(
          id: widget.transactionId ?? createId(),
          type: type,
          amountMinor: result!,
          date: date,
          note: note,
          accountId: type == TransactionType.transfer ? null : accountId,
          categoryId: type == TransactionType.transfer ? null : categoryId,
          fromAccountId: type == TransactionType.transfer ? fromId : null,
          toAccountId: type == TransactionType.transfer ? toId : null,
        ),
      ),
    );
  }

  String? _validationError(
    int? amount,
    List<AccountModel> loaded,
    AppLocalizations l10n,
  ) {
    if (loaded.isEmpty) {
      return l10n.needAccount;
    }
    if (amount == null || amount <= 0) {
      return l10n.invalidTransaction;
    }
    final known = loaded.map((account) => account.id).toSet();
    if (type == TransactionType.transfer) {
      final pair =
          fromId != null &&
          toId != null &&
          fromId != toId &&
          known.contains(fromId) &&
          known.contains(toId);
      return pair ? null : l10n.needDifferentAccounts;
    }
    if (categoryId == null) {
      return l10n.needCategory;
    }
    if (accountId == null || !known.contains(accountId)) {
      return l10n.chooseAccount;
    }
    return null;
  }

  void delete() {
    final id = widget.transactionId;
    if (id == null) {
      return;
    }
    _waiting = true;
    context.read<TransactionsBloc>().add(TransactionDeletePressed(id));
  }

  String typeLabel(AppLocalizations l10n, TransactionType value) {
    return switch (value) {
      TransactionType.expense => l10n.expense,
      TransactionType.income => l10n.income,
      TransactionType.transfer => l10n.transfer,
    };
  }

  String titleFor(String locale) {
    return locale.startsWith('zh')
        ? DateFormat('M月d日', locale).format(date)
        : DateFormat.MMMd(locale).format(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final loaded = context.watch<AccountsBloc>().state.active;
    final transactions = context.watch<TransactionsBloc>().state;
    _prepare(loaded, transactions);
    final categories =
        context
            .watch<CategoriesBloc>()
            .state
            .active
            .where((category) => category.kind.name == type.name)
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _ensureCategory(categories);
    accounts = loaded;
    visibleCategories = categories;
    return BlocListener<TransactionsBloc, TransactionsState>(
      listener: (context, state) {
        if (!_waiting) {
          return;
        }
        if (state.status == TransactionsStatus.success &&
            state.error == TransactionsError.none) {
          context.pop();
        } else if (state.error == TransactionsError.invalid) {
          setState(() => error = l10n.invalidTransaction);
          _waiting = false;
        }
      },
      child: _RecordScope(state: this, child: widget.child),
    );
  }
}

class _RecordScope extends InheritedWidget {
  const _RecordScope({required this.state, required super.child});

  final RecordFrameState state;

  @override
  bool updateShouldNotify(_RecordScope oldWidget) => true;
}
