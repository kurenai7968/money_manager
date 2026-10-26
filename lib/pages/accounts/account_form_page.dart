import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/core/utils/id.dart';
import 'package:money_manager/core/utils/ledger_balance.dart';
import 'package:money_manager/core/utils/money_format.dart';
import 'package:money_manager/models/account_model.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_event.dart';
import 'package:money_manager/pages/accounts/bloc/accounts_state.dart';
import 'package:money_manager/pages/transactions/bloc/transactions_bloc.dart';
import 'package:money_manager/themes/app_themes.dart';

class AccountFormPage extends StatefulWidget {
  const AccountFormPage({this.accountId, super.key});

  final String? accountId;

  @override
  State<AccountFormPage> createState() => _AccountFormPageState();
}

class _AccountFormPageState extends State<AccountFormPage> {
  final _name = TextEditingController();
  final _balance = TextEditingController();
  var _type = AccountType.cash;
  var _sortOrder = 0;
  var _archived = false;
  String? _languageEn;
  String? _languageZh;
  String? _languageZhCn;
  var _localized = false;
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
    final accounts = context.read<AccountsBloc>().state.accounts;
    final existing = accounts.where(
      (account) => account.id == widget.accountId,
    );
    if (existing.isNotEmpty) {
      final account = existing.first;
      _name.text = account.labelFor(context.categoryLanguageCode);
      _type = account.type;
      _sortOrder = account.sortOrder;
      _archived = account.archived;
      _languageEn = account.languageEn;
      _languageZh = account.languageZh;
      _languageZhCn = account.languageZhCn;
      _localized =
          account.languageEn != null ||
          account.languageZh != null ||
          account.languageZhCn != null;
      _balance.text = formatMinor(
        account.openingBalanceMinor,
        locale: Localizations.localeOf(context).toString(),
      ).replaceAll(',', '');
    } else {
      final orders = accounts.map((account) => account.sortOrder);
      _sortOrder = orders.isEmpty
          ? 0
          : orders.reduce((a, b) => a > b ? a : b) + 1;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _balance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final editing = widget.accountId != null;
    return BlocListener<AccountsBloc, AccountsState>(
      listener: (context, state) {
        if (!_waiting) {
          return;
        }
        if (state.status == AccountsStatus.success &&
            state.error == AccountsError.none) {
          context.pop();
        } else if (state.error == AccountsError.nameRequired) {
          setState(() => _error = l10n.nameRequired);
          _waiting = false;
        } else if (state.error == AccountsError.archiveBlocked) {
          setState(() => _error = l10n.archiveBlocked);
          _waiting = false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(editing ? l10n.editAccount : l10n.newAccount),
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.l),
          children: [
            Text(l10n.name, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.s),
            TextField(controller: _name, textInputAction: TextInputAction.next),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.openingBalance,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: AppSpacing.s),
            TextField(
              controller: _balance,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: [
                for (final type in AccountType.values)
                  ChoiceChip(
                    label: Text(_typeLabel(l10n, type)),
                    selected: _type == type,
                    onSelected: (_) => setState(() => _type = type),
                  ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.m),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            FilledButton(onPressed: _save, child: Text(l10n.save)),
            if (editing)
              TextButton(onPressed: _archive, child: Text(l10n.delete)),
          ],
        ),
      ),
    );
  }

  void _save() {
    final l10n = context.l10n;
    final minor = parseAmountMinor(_balance.text);
    if (_name.text.trim().isEmpty) {
      setState(() => _error = l10n.nameRequired);
      return;
    }
    if (minor == null) {
      setState(() => _error = l10n.amountInvalid);
      return;
    }
    final text = _name.text.trim();
    final code = context.categoryLanguageCode;
    _waiting = true;
    context.read<AccountsBloc>().add(
      AccountSavePressed(
        AccountModel(
          id: widget.accountId ?? createId(),
          name: _localized ? null : text,
          languageEn: _localized ? (code == 'en' ? text : _languageEn) : null,
          languageZh: _localized ? (code == 'zh' ? text : _languageZh) : null,
          languageZhCn: _localized
              ? (code == 'zh_CN' ? text : _languageZhCn)
              : null,
          type: _type,
          openingBalanceMinor: minor,
          sortOrder: _sortOrder,
          archived: _archived,
        ),
      ),
    );
  }

  void _archive() {
    final accounts = context.read<AccountsBloc>().state.accounts;
    final existing = accounts.where(
      (account) => account.id == widget.accountId,
    );
    if (existing.isEmpty) {
      return;
    }
    final transactions = context.watch<TransactionsBloc>().state.transactions;
    final balance = balanceOf(existing.first, transactions);
    _waiting = true;
    context.read<AccountsBloc>().add(
      AccountArchivePressed(existing.first, balanceMinor: balance),
    );
  }

  String _typeLabel(AppLocalizations l10n, AccountType type) {
    return switch (type) {
      AccountType.cash => l10n.cash,
      AccountType.bank => l10n.bank,
      AccountType.savings => l10n.savings,
      AccountType.credit => l10n.credit,
    };
  }
}
