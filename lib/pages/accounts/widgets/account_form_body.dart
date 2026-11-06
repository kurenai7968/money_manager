import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/l10n/app_localizations.dart';
import 'package:money_manager/models/ledger_kinds.dart';
import 'package:money_manager/pages/accounts/bloc/account_form_bloc.dart';
import 'package:money_manager/pages/accounts/bloc/account_form_event.dart';
import 'package:money_manager/pages/accounts/bloc/account_form_state.dart';
import 'package:money_manager/themes/app_themes.dart';

class AccountFormBody extends StatefulWidget {
  final String? accountId;

  const AccountFormBody({this.accountId, super.key});

  @override
  State<AccountFormBody> createState() => _AccountFormBodyState();
}

class _AccountFormBodyState extends State<AccountFormBody> {
  final _name = TextEditingController();
  final _balance = TextEditingController();
  var _applied = false;

  @override
  void dispose() {
    _name.dispose();
    _balance.dispose();
    super.dispose();
  }

  void _apply(AccountFormState state) {
    if (_applied || !state.prepared) {
      return;
    }
    _applied = true;
    _name.text = state.name;
    _balance.text = state.balanceText;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<AccountFormBloc>().state;
    _apply(state);
    return BlocListener<AccountFormBloc, AccountFormState>(
      listenWhen: (previous, current) => current.saved && !previous.saved,
      listener: (context, state) => context.pop(),
      child: ListView(
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
              signed: true,
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
                  selected: state.type == type,
                  onSelected: (_) => context.read<AccountFormBloc>().add(
                    AccountFormTypeSelected(type),
                  ),
                ),
            ],
          ),
          if (state.error != AccountFormError.none) ...[
            const SizedBox(height: AppSpacing.m),
            Text(
              _errorLabel(l10n, state.error),
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: () => context.read<AccountFormBloc>().add(
              AccountFormSavePressed(
                name: _name.text,
                balanceText: _balance.text,
                languageCode: context.categoryLanguageCode,
              ),
            ),
            child: Text(l10n.save),
          ),
          if (widget.accountId != null)
            TextButton(
              onPressed: () => context.read<AccountFormBloc>().add(
                const AccountFormArchivePressed(),
              ),
              child: Text(l10n.delete),
            ),
        ],
      ),
    );
  }
}

String _typeLabel(AppLocalizations l10n, AccountType type) {
  return switch (type) {
    AccountType.cash => l10n.cash,
    AccountType.bank => l10n.bank,
    AccountType.savings => l10n.savings,
    AccountType.credit => l10n.credit,
  };
}

String _errorLabel(AppLocalizations l10n, AccountFormError error) {
  return switch (error) {
    AccountFormError.none => '',
    AccountFormError.nameRequired => l10n.nameRequired,
    AccountFormError.amountInvalid => l10n.amountInvalid,
    AccountFormError.archiveBlocked => l10n.archiveBlocked,
  };
}
